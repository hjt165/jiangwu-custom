package com.jiangwu.workflow;

import lombok.extern.slf4j.Slf4j;
import org.flowable.engine.delegate.DelegateExecution;
import org.flowable.engine.delegate.JavaDelegate;
import org.springframework.stereotype.Component;

/**
 * 订单流程监听器
 * Flowable 执行每个节点时调用
 */
@Slf4j
@Component("orderProcess")
public class OrderProcess implements JavaDelegate {

    @Override
    public void execute(DelegateExecution execution) {
        String activityName = execution.getEventName();
        Long orderId = (Long) execution.getVariable("orderId");
        log.info("订单流程节点执行: orderId={}, activity={}", orderId, activityName);

        switch (activityName) {
            case "草稿确认" -> handleDraftConfirm(execution);
            case "制作中" -> handleProduction(execution);
            case "阶段交付" -> handleStageDeliver(execution);
            case "最终确认" -> handleFinalConfirm(execution);
            default -> log.warn("未知流程节点: {}", activityName);
        }
    }

    private void handleDraftConfirm(DelegateExecution execution) {
        log.info("草稿确认节点 - 用户确认定制方案");
        execution.setVariable("status", "confirmed");
    }

    private void handleProduction(DelegateExecution execution) {
        log.info("制作中节点 - 手作人开始制作");
        execution.setVariable("status", "producing");
    }

    private void handleStageDeliver(DelegateExecution execution) {
        log.info("阶段交付节点 - 手作人交付阶段成果");
        execution.setVariable("status", "delivered");
    }

    private void handleFinalConfirm(DelegateExecution execution) {
        log.info("最终确认节点 - 用户确认收货，订单完成");
        execution.setVariable("status", "completed");
    }
}
