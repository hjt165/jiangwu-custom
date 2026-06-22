package com.jiangwu.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.jiangwu.entity.Order;
import com.jiangwu.entity.User;
import com.jiangwu.enums.OrderStatus;
import com.jiangwu.enums.UserRole;
import com.jiangwu.exception.BusinessException;
import com.jiangwu.exception.ErrorCode;
import com.jiangwu.repository.OrderRepository;
import com.jiangwu.repository.UserRepository;
import com.jiangwu.utils.JWTUtil;
import com.jiangwu.utils.PasswordUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 管理后台服务
 */
@Service
@RequiredArgsConstructor
public class AdminService {

    private final UserRepository userRepository;
    private final OrderRepository orderRepository;
    private final JWTUtil jwtUtil;

    /**
     * 管理员登录
     */
    public Map<String, Object> login(String phone, String password) {
        User user = userRepository.findByPhone(phone);
        if (user == null || !PasswordUtil.verify(password, user.getPassword())) {
            throw new BusinessException(ErrorCode.USER_PASSWORD_ERROR);
        }
        if (user.getRole() != UserRole.ADMIN) {
            throw new BusinessException(ErrorCode.FORBIDDEN);
        }

        String token = jwtUtil.generateToken(user.getId());
        Map<String, Object> data = new HashMap<>();
        data.put("token", token);
        Map<String, Object> userInfo = new HashMap<>();
        userInfo.put("id", user.getId());
        userInfo.put("nickname", user.getNickname());
        userInfo.put("avatar", user.getAvatar());
        userInfo.put("role", user.getRole());
        data.put("user", userInfo);
        return data;
    }

    /**
     * 获取用户列表（MyBatis-Plus 分页，避免 SQL 注入）
     */
    public List<User> getUserList(String keyword, Integer status, int page, int size) {
        QueryWrapper<User> wrapper = new QueryWrapper<>();
        wrapper.eq("deleted", 0);
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.and(w -> w
                    .like("nickname", keyword)
                    .or()
                    .like("phone", keyword));
        }
        if (status != null) {
            wrapper.eq("status", status);
        }
        wrapper.orderByDesc("created_at");
        Page<User> pageParam = new Page<>(page, size);
        return userRepository.selectPage(pageParam, wrapper).getRecords();
    }

    /**
     * 获取用户详情
     */
    public User getUserDetail(Long id) {
        User user = userRepository.findById(id);
        if (user == null) {
            throw new BusinessException(ErrorCode.USER_NOT_FOUND);
        }
        return user;
    }

    /**
     * 更新用户状态
     */
    public void updateUserStatus(Long id, Integer status) {
        userRepository.updateStatus(id, status);
    }

    /**
     * 更新用户信用分
     */
    public void updateUserCredit(Long id, Integer creditScore) {
        User user = userRepository.findById(id);
        if (user != null) {
            user.setCreditScore(creditScore);
            userRepository.updateById(user);
        }
    }

    /**
     * 获取订单列表（MyBatis-Plus 分页，避免 SQL 注入）
     */
    public List<Order> getOrderList(String status, String keyword, int page, int size) {
        QueryWrapper<Order> wrapper = new QueryWrapper<>();
        wrapper.eq("deleted", 0);
        if (status != null && !status.isEmpty()) {
            wrapper.eq("status", status);
        }
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.like("order_no", keyword);
        }
        wrapper.orderByDesc("created_at");
        Page<Order> pageParam = new Page<>(page, size);
        return orderRepository.selectPage(pageParam, wrapper).getRecords();
    }

    /**
     * 获取订单详情
     */
    public Order getOrderDetail(Long id) {
        Order order = orderRepository.findById(id);
        if (order == null) {
            throw new BusinessException(ErrorCode.ORDER_NOT_FOUND);
        }
        return order;
    }

    /**
     * 获取争议订单列表（MyBatis-Plus 分页，避免 SQL 注入）
     */
    public List<Order> getDisputeList(int page, int size) {
        QueryWrapper<Order> wrapper = new QueryWrapper<>();
        wrapper.eq("deleted", 0)
                .in("status", List.of("dispute", "cancelled"));
        wrapper.orderByDesc("created_at");
        Page<Order> pageParam = new Page<>(page, size);
        return orderRepository.selectPage(pageParam, wrapper).getRecords();
    }

    /**
     * 仲裁争议订单
     */
    public void resolveDispute(Long id, String resolution) {
        Order order = orderRepository.findById(id);
        if (order != null) {
            if ("user".equals(resolution)) {
                // 支持用户：退款
                order.setStatus(OrderStatus.CANCELLED);
            } else if ("artisan".equals(resolution)) {
                // 支持手作人：继续完成
                order.setStatus(OrderStatus.PRODUCING);
            } else {
                // 默认完成
                order.setStatus(OrderStatus.COMPLETED);
            }
            orderRepository.updateById(order);
        }
    }
}
