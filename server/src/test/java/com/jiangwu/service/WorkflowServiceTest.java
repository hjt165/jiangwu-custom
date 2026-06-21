package com.jiangwu.service;

import com.jiangwu.entity.Order;
import com.jiangwu.enums.OrderStatus;
import com.jiangwu.exception.BusinessException;
import com.jiangwu.repository.OrderRepository;
import org.flowable.engine.RuntimeService;
import org.flowable.engine.TaskService;
import org.flowable.engine.runtime.ProcessInstance;
import org.flowable.engine.runtime.ProcessInstanceQuery;
import org.flowable.task.api.Task;
import org.flowable.task.api.TaskQuery;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class WorkflowServiceTest {

    @Mock private RuntimeService runtimeService;
    @Mock private TaskService taskService;
    @Mock private OrderRepository orderRepository;
    @Mock private TaskQuery taskQuery;
    @Mock private ProcessInstanceQuery processInstanceQuery;
    @InjectMocks private WorkflowService workflowService;

    private Order testOrder;

    @BeforeEach
    void setUp() {
        testOrder = new Order();
        testOrder.setId(1L);
        testOrder.setOrderNo("JW20260616001");
        testOrder.setUserId(1L);
        testOrder.setArtisanId(1L);
        testOrder.setStatus(OrderStatus.PENDING_PAYMENT);
        testOrder.setTotalAmount(new BigDecimal("599.00"));
    }

    @Test
    void startOrderProcess_ValidOrder_StartsProcess() {
        when(orderRepository.findById(1L)).thenReturn(testOrder);
        ProcessInstance mockInstance = mock(ProcessInstance.class);
        when(mockInstance.getId()).thenReturn("proc-001");
        when(runtimeService.startProcessInstanceByKey(eq("order_process"), eq("1"), any(Map.class))).thenReturn(mockInstance);

        workflowService.startOrderProcess(1L);

        verify(runtimeService).startProcessInstanceByKey(eq("order_process"), eq("1"), any(Map.class));
    }

    @Test
    void startOrderProcess_OrderNotFound_ThrowsException() {
        when(orderRepository.findById(anyLong())).thenReturn(null);
        assertThrows(BusinessException.class, () -> workflowService.startOrderProcess(1L));
    }

    @Test
    void completeCurrentStage_HasTasks_CompletesTask() {
        Task mockTask = mock(Task.class);
        when(mockTask.getId()).thenReturn("task-001");
        when(mockTask.getName()).thenReturn("确认订单");
        when(taskService.createTaskQuery()).thenReturn(taskQuery);
        when(taskQuery.processInstanceBusinessKey("1")).thenReturn(taskQuery);
        when(taskQuery.list()).thenReturn(List.of(mockTask));

        workflowService.completeCurrentStage(1L);

        verify(taskService).complete("task-001");
    }

    @Test
    void completeCurrentStage_NoTasks_DoesNothing() {
        when(taskService.createTaskQuery()).thenReturn(taskQuery);
        when(taskQuery.processInstanceBusinessKey("1")).thenReturn(taskQuery);
        when(taskQuery.list()).thenReturn(List.of());

        assertDoesNotThrow(() -> workflowService.completeCurrentStage(1L));
        verify(taskService, never()).complete(anyString());
    }

    @Test
    void getCurrentStage_HasTasks_ReturnsTaskName() {
        Task mockTask = mock(Task.class);
        when(mockTask.getName()).thenReturn("确认订单");
        when(taskService.createTaskQuery()).thenReturn(taskQuery);
        when(taskQuery.processInstanceBusinessKey("1")).thenReturn(taskQuery);
        when(taskQuery.list()).thenReturn(List.of(mockTask));

        String stage = workflowService.getCurrentStage(1L);
        assertEquals("确认订单", stage);
    }

    @Test
    void getCurrentStage_NoTasks_ReturnsCompleted() {
        when(taskService.createTaskQuery()).thenReturn(taskQuery);
        when(taskQuery.processInstanceBusinessKey("1")).thenReturn(taskQuery);
        when(taskQuery.list()).thenReturn(List.of());

        String stage = workflowService.getCurrentStage(1L);
        assertEquals("completed", stage);
    }

    @Test
    void cancelProcess_HasInstances_DeletesAll() {
        ProcessInstance mockInstance = mock(ProcessInstance.class);
        when(mockInstance.getId()).thenReturn("proc-001");
        when(runtimeService.createProcessInstanceQuery()).thenReturn(processInstanceQuery);
        when(processInstanceQuery.processInstanceBusinessKey("1")).thenReturn(processInstanceQuery);
        when(processInstanceQuery.list()).thenReturn(List.of(mockInstance));

        workflowService.cancelProcess(1L);

        verify(runtimeService).deleteProcessInstance("proc-001", "订单取消");
    }

    @Test
    void cancelProcess_NoInstances_DoesNothing() {
        when(runtimeService.createProcessInstanceQuery()).thenReturn(processInstanceQuery);
        when(processInstanceQuery.processInstanceBusinessKey("1")).thenReturn(processInstanceQuery);
        when(processInstanceQuery.list()).thenReturn(List.of());

        assertDoesNotThrow(() -> workflowService.cancelProcess(1L));
        verify(runtimeService, never()).deleteProcessInstance(anyString(), anyString());
    }
}
