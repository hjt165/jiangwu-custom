package com.jiangwu.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.jiangwu.dto.request.CreateOrderRequest;
import com.jiangwu.dto.response.OrderResponse;
import com.jiangwu.dto.response.ProductResponse;
import com.jiangwu.entity.*;
import com.jiangwu.enums.OrderStatus;
import com.jiangwu.exception.BusinessException;
import com.jiangwu.exception.ErrorCode;
import com.jiangwu.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ThreadLocalRandom;
import java.util.stream.Collectors;

/**
 * 订单服务
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderRepository orderRepository;
    private final OrderStageRepository orderStageRepository;
    private final CustomizationRepository customizationRepository;
    private final ReviewRepository reviewRepository;
    private final ProductRepository productRepository;
    private final ArtisanRepository artisanRepository;
    private final AiService aiService;
    private final ObjectMapper objectMapper;
    private final WorkflowService workflowService;

    /**
     * 创建订单
     */
    @Transactional
    public OrderResponse createOrder(Long userId, CreateOrderRequest request) {
        // 生成订单号: JW + 年月日 + 6位随机数
        String orderNo = generateOrderNo();

        // 创建订单
        Order order = new Order();
        order.setOrderNo(orderNo);
        order.setUserId(userId);
        order.setArtisanId(request.getArtisanId());
        order.setProductId(request.getProductId());
        order.setStatus(OrderStatus.PENDING_PAYMENT);
        order.setTotalAmount(BigDecimal.ZERO);
        order.setPaidAmount(BigDecimal.ZERO);
        order.setDepositAmount(BigDecimal.ZERO);
        order.setCurrentStage(0);
        order.setRemark(request.getRemark());
        orderRepository.insert(order);

        // 创建定制参数
        Customization customization = new Customization();
        customization.setOrderId(order.getId());
        customization.setProductId(request.getProductId());
        customization.setMaterial(request.getMaterial());
        customization.setSize(request.getSize());
        customization.setColor(request.getColor());
        customization.setEngraving(request.getEngraving());
        customization.setReferenceImages(request.getReferenceImages());
        customization.setSpecialRequests(request.getSpecialRequests());

        // 异步调用 AI 服务生成定制建议
        try {
            Map<String, Object> solutionResult = aiService.recommendSolution(
                    request.getSpecialRequests(),
                    null,
                    null,
                    5000,
                    3
            );
            if (solutionResult != null && !solutionResult.containsKey("error")) {
                customization.setAiSuggestion(objectMapper.writeValueAsString(solutionResult));
            }
        } catch (Exception e) {
            log.warn("AI 定制建议生成失败，继续创建订单: {}", e.getMessage());
        }

        customizationRepository.insert(customization);

        // 创建订单阶段
        createDefaultStages(order.getId());

        // 启动 Flowable 工作流
        try {
            workflowService.startOrderProcess(order.getId());
        } catch (Exception e) {
            log.warn("工作流启动失败，订单仍可正常使用: {}", e.getMessage());
        }

        return getOrderDetail(order.getId());
    }

    /**
     * 获取订单列表（批量查询优化，避免 N+1）
     */
    public List<OrderResponse> getOrderList(Long userId, String status) {
        List<Order> orders;
        if (status != null && !status.isEmpty()) {
            OrderStatus orderStatus = OrderStatus.valueOf(status.toUpperCase());
            orders = orderRepository.findByUserIdAndStatus(userId, orderStatus);
        } else {
            orders = orderRepository.findByUserId(userId);
        }

        if (orders.isEmpty()) {
            return List.of();
        }

        // 批量加载关联数据，避免 N+1 查询
        List<Long> orderIds = orders.stream().map(Order::getId).toList();

        // 批量查询阶段
        Map<Long, List<OrderStage>> stagesMap = orderStageRepository.findByOrderIds(orderIds)
                .stream()
                .collect(Collectors.groupingBy(OrderStage::getOrderId));

        // 批量查询定制参数
        Map<Long, Customization> customizationMap = new java.util.HashMap<>();
        // 批量查询作品
        Map<Long, Product> productMap = new java.util.HashMap<>();
        // 批量查询手作人
        Map<Long, Artisan> artisanMap = new java.util.HashMap<>();

        for (Order order : orders) {
            if (customizationRepository.findByOrderId(order.getId()) != null) {
                customizationMap.put(order.getId(), customizationRepository.findByOrderId(order.getId()));
            }
            if (order.getProductId() != null && !productMap.containsKey(order.getProductId())) {
                Product p = productRepository.findById(order.getProductId());
                if (p != null) productMap.put(order.getProductId(), p);
            }
            if (order.getArtisanId() != null && !artisanMap.containsKey(order.getArtisanId())) {
                Artisan a = artisanRepository.findById(order.getArtisanId());
                if (a != null) artisanMap.put(order.getArtisanId(), a);
            }
        }

        // 组装结果
        return orders.stream().map(order -> {
            OrderResponse response = OrderResponse.fromEntity(order);
            response.setStagesFromEntities(stagesMap.getOrDefault(order.getId(), List.of()));
            if (customizationMap.containsKey(order.getId())) {
                response.setCustomization(OrderResponse.CustomizationResponse.fromEntity(customizationMap.get(order.getId())));
            }
            if (order.getProductId() != null && productMap.containsKey(order.getProductId())) {
                response.setProduct(ProductResponse.fromEntity(productMap.get(order.getProductId())));
            }
            if (order.getArtisanId() != null && artisanMap.containsKey(order.getArtisanId())) {
                response.setArtisan(OrderResponse.ArtisanResponse.fromEntity(artisanMap.get(order.getArtisanId())));
            }
            return response;
        }).collect(Collectors.toList());
    }

    /**
     * 获取订单详情（带权限校验）
     */
    public OrderResponse getOrderDetail(Long orderId, Long userId) {
        Order order = orderRepository.findById(orderId);
        if (order == null) {
            throw new BusinessException(ErrorCode.ORDER_NOT_FOUND);
        }

        // 权限校验：只能查看自己的订单（管理员可查看所有）
        if (!order.getUserId().equals(userId)) {
            throw new BusinessException(ErrorCode.FORBIDDEN);
        }

        return getOrderDetail(orderId);
    }

    /**
     * 获取订单详情（内部调用，无权限校验）
     */
    public OrderResponse getOrderDetail(Long orderId) {
        Order order = orderRepository.findById(orderId);
        if (order == null) {
            throw new BusinessException(ErrorCode.ORDER_NOT_FOUND);
        }

        OrderResponse response = OrderResponse.fromEntity(order);

        // 查询阶段列表
        List<OrderStage> stages = orderStageRepository.findByOrderId(orderId);
        response.setStagesFromEntities(stages);

        // 查询定制参数
        Customization customization = customizationRepository.findByOrderId(orderId);
        response.setCustomization(OrderResponse.CustomizationResponse.fromEntity(customization));

        // 查询作品信息
        if (order.getProductId() != null) {
            Product product = productRepository.findById(order.getProductId());
            response.setProduct(com.jiangwu.dto.response.ProductResponse.fromEntity(product));
        }

        // 查询手作人信息
        if (order.getArtisanId() != null) {
            Artisan artisan = artisanRepository.findById(order.getArtisanId());
            response.setArtisan(OrderResponse.ArtisanResponse.fromEntity(artisan));
        }

        return response;
    }

    /**
     * 取消订单
     */
    @Transactional
    public void cancelOrder(Long orderId, Long userId, String reason) {
        Order order = orderRepository.findById(orderId);
        if (order == null) {
            throw new BusinessException(ErrorCode.ORDER_NOT_FOUND);
        }

        if (!order.getUserId().equals(userId)) {
            throw new BusinessException(ErrorCode.FORBIDDEN);
        }

        if (!order.getStatus().equals(OrderStatus.PENDING_PAYMENT)) {
            throw new BusinessException(ErrorCode.ORDER_STATUS_ERROR);
        }

        orderRepository.updateCancelled(orderId, OrderStatus.CANCELLED, LocalDateTime.now(), reason);
    }

    /**
     * 确认阶段交付（带权限校验）
     */
    @Transactional
    public void confirmStage(Long orderId, Long stageId, List<String> images, String note, Long userId) {
        Order order = orderRepository.findById(orderId);
        if (order == null) {
            throw new BusinessException(ErrorCode.ORDER_NOT_FOUND);
        }

        // 权限校验：只有订单所有者可以确认阶段
        if (!order.getUserId().equals(userId)) {
            throw new BusinessException(ErrorCode.FORBIDDEN);
        }

        confirmStageInternal(orderId, stageId, images, note);
    }

    /**
     * 确认阶段交付（内部调用）
     */
    @Transactional
    public void confirmStage(Long orderId, Long stageId, List<String> images, String note) {
        confirmStageInternal(orderId, stageId, images, note);
    }

    private void confirmStageInternal(Long orderId, Long stageId, List<String> images, String note) {
        Order order = orderRepository.findById(orderId);
        if (order == null) {
            throw new BusinessException(ErrorCode.ORDER_NOT_FOUND);
        }

        OrderStage stage = orderStageRepository.findById(stageId);
        if (stage == null) {
            throw new BusinessException(ErrorCode.ORDER_STAGE_NOT_FOUND);
        }

        // 更新阶段信息（JSON数组格式）
        String imagesJson = null;
        if (images != null && !images.isEmpty()) {
            try {
                imagesJson = objectMapper.writeValueAsString(images);
            } catch (Exception e) {
                log.warn("序列化交付图片失败: {}", e.getMessage());
                imagesJson = "[]";
            }
        }
        orderStageRepository.updateDeliverInfo(stageId, imagesJson, note);
        orderStageRepository.updateStatus(stageId, "completed", LocalDateTime.now());

        // 更新订单状态
        List<OrderStage> stages = orderStageRepository.findByOrderId(orderId);
        int currentStageIndex = order.getCurrentStage();

        if (currentStageIndex < stages.size() - 1) {
            // 还有下一阶段
            orderRepository.updateCurrentStage(orderId, currentStageIndex + 1);
            orderRepository.updateStatus(orderId, OrderStatus.PRODUCING);
            // 推进工作流
            try {
                workflowService.completeCurrentStage(orderId);
            } catch (Exception e) {
                log.warn("工作流推进失败: {}", e.getMessage());
            }
        } else {
            // 所有阶段完成，订单完成
            orderRepository.updateCompleted(orderId, OrderStatus.COMPLETED, LocalDateTime.now());
            // 完成工作流
            try {
                workflowService.completeCurrentStage(orderId);
            } catch (Exception e) {
                log.warn("工作流完成失败: {}", e.getMessage());
            }
        }
    }

    /**
     * 提交评价
     */
    @Transactional
    public void submitReview(Long orderId, Long userId, Integer rating, String content,
                             List<String> images, List<String> tags, Boolean isAnonymous) {
        Order order = orderRepository.findById(orderId);
        if (order == null) {
            throw new BusinessException(ErrorCode.ORDER_NOT_FOUND);
        }

        if (!order.getUserId().equals(userId)) {
            throw new BusinessException(ErrorCode.FORBIDDEN);
        }

        if (!order.getStatus().equals(OrderStatus.COMPLETED)) {
            throw new BusinessException(ErrorCode.ORDER_STATUS_ERROR);
        }

        // 检查是否已评价
        Review existingReview = reviewRepository.findByOrderId(orderId);
        if (existingReview != null) {
            throw new BusinessException(ErrorCode.REVIEW_ALREADY_EXISTS);
        }

        // 创建评价
        Review review = new Review();
        review.setOrderId(orderId);
        review.setUserId(userId);
        review.setArtisanId(order.getArtisanId());
        review.setRating(rating);
        review.setContent(content);
        review.setImages(images);
        review.setTags(tags);
        review.setIsAnonymous(isAnonymous != null ? isAnonymous : false);
        reviewRepository.insert(review);

        // 更新作品评分
        updateProductRating(order.getProductId());

        // 更新手作人评分
        updateArtisanRating(order.getArtisanId());
    }

    /**
     * 创建默认订单阶段
     */
    private void createDefaultStages(Long orderId) {
        String[] stageNames = {"草稿确认", "制作中", "阶段交付", "最终确认"};
        String[] stageDescs = {"确认定制方案", "手作人制作作品", "分阶段交付确认", "最终验收完成"};

        for (int i = 0; i < stageNames.length; i++) {
            OrderStage stage = new OrderStage();
            stage.setOrderId(orderId);
            stage.setName(stageNames[i]);
            stage.setDescription(stageDescs[i]);
            stage.setStatus(i == 0 ? "active" : "pending");
            stage.setSortOrder(i);
            orderStageRepository.insert(stage);
        }
    }

    /**
     * 生成订单号（使用 ThreadLocalRandom 避免并发冲突）
     */
    private String generateOrderNo() {
        String dateStr = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        String random = String.format("%06d", ThreadLocalRandom.current().nextInt(1000000));
        return "JW" + dateStr + random;
    }

    /**
     * 更新作品评分（取平均值）- 修复：使用 findByProductId 而非 findByArtisanId
     */
    private void updateProductRating(Long productId) {
        List<Review> reviews = reviewRepository.findByProductId(productId);
        if (!reviews.isEmpty()) {
            double avg = reviews.stream()
                    .mapToInt(Review::getRating)
                    .average()
                    .orElse(0);
            productRepository.updateRating(productId, BigDecimal.valueOf(avg));
        }
    }

    /**
     * 更新手作人评分（取平均值）
     */
    private void updateArtisanRating(Long artisanId) {
        List<Review> reviews = reviewRepository.findByArtisanId(artisanId);
        if (!reviews.isEmpty()) {
            double avg = reviews.stream()
                    .mapToInt(Review::getRating)
                    .average()
                    .orElse(0);
            artisanRepository.updateRating(artisanId, new BigDecimal(avg));
        }
    }
}
