package com.jiangwu.config;

import org.springframework.amqp.core.*;
import org.springframework.amqp.rabbit.connection.ConnectionFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;
import org.springframework.amqp.support.converter.MessageConverter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * RabbitMQ 配置 - AI 任务消息队列
 */
@Configuration
public class RabbitMQConfig {

    // AI 任务队列
    public static final String AI_TASK_EXCHANGE = "ai.task.exchange";
    public static final String AI_TASK_QUEUE = "ai.task.queue";
    public static final String AI_TASK_ROUTING_KEY = "ai.task.image";

    // AI 任务完成回调队列
    public static final String AI_TASK_COMPLETE_EXCHANGE = "ai.task.complete.exchange";
    public static final String AI_TASK_COMPLETE_QUEUE = "ai.task.complete.queue";
    public static final String AI_TASK_COMPLETE_ROUTING_KEY = "ai.task.complete";

    @Bean
    public DirectExchange aiTaskExchange() {
        return new DirectExchange(AI_TASK_EXCHANGE);
    }

    @Bean
    public Queue aiTaskQueue() {
        return QueueBuilder.durable(AI_TASK_QUEUE).build();
    }

    @Bean
    public Binding aiTaskBinding(Queue aiTaskQueue, DirectExchange aiTaskExchange) {
        return BindingBuilder.bind(aiTaskQueue).to(aiTaskExchange).with(AI_TASK_ROUTING_KEY);
    }

    @Bean
    public DirectExchange aiTaskCompleteExchange() {
        return new DirectExchange(AI_TASK_COMPLETE_EXCHANGE);
    }

    @Bean
    public Queue aiTaskCompleteQueue() {
        return QueueBuilder.durable(AI_TASK_COMPLETE_QUEUE).build();
    }

    @Bean
    public Binding aiTaskCompleteBinding(Queue aiTaskCompleteQueue, DirectExchange aiTaskCompleteExchange) {
        return BindingBuilder.bind(aiTaskCompleteQueue).to(aiTaskCompleteExchange).with(AI_TASK_COMPLETE_ROUTING_KEY);
    }

    @Bean
    public MessageConverter jsonMessageConverter() {
        return new Jackson2JsonMessageConverter();
    }

    @Bean
    public RabbitTemplate rabbitTemplate(ConnectionFactory connectionFactory) {
        RabbitTemplate rabbitTemplate = new RabbitTemplate(connectionFactory);
        rabbitTemplate.setMessageConverter(jsonMessageConverter());
        return rabbitTemplate;
    }
}
