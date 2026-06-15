package com.jiangwu.service;

import com.jiangwu.entity.Order;
import com.jiangwu.enums.OrderStatus;
import com.jiangwu.exception.BusinessException;
import com.jiangwu.exception.ErrorCode;
import com.jiangwu.repository.OrderRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.flowable.engine.RuntimeService;
import org.flowable.engine.TaskService;
import org.flowable.engine.runtime.ProcessInstance;
import org.flowable.task.api.Task;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 工作流服务
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class WorkflowService {

    private final RuntimeService runtimeService;
    private final TaskService taskService;
    private final OrderRepository orderRepository;

    /**
     * 启动订单流程
     */
    @Transactional
    public void startOrderProcess(Long orderId) {
        Order order = orderRepository.findById(orderId);
        if (order == null) {
            throw new BusinessException(ErrorCode.ORDER_NOT_FOUND);
        }

        Map<String, Object> variables = new HashMap<>();
        variables.put("orderId", orderId);
        variables.put("userId", order.getUserId());
        variables.put("artisanId", order.getArtisanId());
        variables.put("status", "draft");

        ProcessInstance processInstance = runtimeService.startProcessInstanceByKey(
                "order_process", String.valueOf(orderId), variables);

        log.info("订单流程启动: orderId={}, processInstanceId={}", orderId, processInstance.getId());
    }

    /**
     * 推进订单流程到下一阶段
     */
    @Transactional
    public void completeCurrentStage(Long orderId) {
        List<Task> tasks = taskService.createTaskQuery()
                .processInstanceBusinessKey(String.valueOf(orderId))
                .list();

        if (tasks.isEmpty()) {
            log.warn("订单 {} 没有待处理的任务", orderId);
            return;
        }

        Task task = tasks.get(0);
        log.info("完成订单流程节点: orderId={}, task={}", orderId, task.getName());
        taskService.complete(task.getId());
    }

    /**
     * 获取当前流程阶段
     */
    public String getCurrentStage(Long orderId) {
        List<Task> tasks = taskService.createTaskQuery()
                .processInstanceBusinessKey(String.valueOf(orderId))
                .list();

        if (tasks.isEmpty()) {
            return "completed";
        }
        return tasks.get(0).getName();
    }

    /**
     * 取消订单流程
     */
    @Transactional
    public void cancelProcess(Long orderId) {
        List<ProcessInstance> instances = runtimeService.createProcessInstanceQuery()
                .processInstanceBusinessKey(String.valueOf(orderId))
                .list();

        for (ProcessInstance instance : instances) {
            runtimeService.deleteProcessInstance(instance.getId(), "订单取消");
            log.info("订单流程已取消: orderId={}, processInstanceId={}", orderId, instance.getId());
        }
    }
}
