"""回调服务 - AI 任务完成后通知 Spring Boot"""
import httpx
from loguru import logger

from config import settings


class CallbackService:
    """回调服务"""

    async def notify_task_complete(
        self,
        task_id: str,
        status: str,
        result: dict,
        error: str = None,
    ):
        """通知 Spring Boot 任务完成"""
        payload = {
            "taskId": task_id,
            "status": status,  # "completed" 或 "failed"
            "result": result,
        }
        if error:
            payload["error"] = error

        callback_url = f"{settings.SPRING_BOOT_URL}/api/ai/task/complete"

        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                resp = await client.post(callback_url, json=payload)
                resp.raise_for_status()
                logger.info(f"回调通知成功: task_id={task_id}, status={status}")
        except Exception as e:
            logger.error(f"回调通知失败: task_id={task_id}, error={e}")

    async def notify_image_analysis_complete(
        self,
        task_id: str,
        analysis_result: dict,
    ):
        """通知图片分析完成"""
        await self.notify_task_complete(
            task_id=task_id,
            status="completed",
            result={"type": "image_analysis", "data": analysis_result},
        )

    async def notify_recommendation_complete(
        self,
        task_id: str,
        recommendation_result: dict,
    ):
        """通知推荐完成"""
        await self.notify_task_complete(
            task_id=task_id,
            status="completed",
            result={"type": "recommendation", "data": recommendation_result},
        )


callback_service = CallbackService()
