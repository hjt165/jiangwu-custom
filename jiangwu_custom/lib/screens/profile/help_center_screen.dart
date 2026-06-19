import 'package:flutter/material.dart';
import '../../app/constants.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('帮助中心')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        children: const [
          _HelpItem(
            question: '如何下单购买定制商品？',
            answer: '浏览首页或发现页找到心仪的手作人或商品，进入商品详情页点击"立即定制"，填写定制需求后提交订单。支付成功后手作人将开始制作。订单进度可在"我的订单"中查看。',
          ),
          _HelpItem(
            question: '如何发布定制需求？',
            answer: '点击底部导航栏中间的"发布"按钮，填写定制类型、描述、预算和期望交付时间，上传参考图片后提交。平台手作人看到后可主动联系您，您也可在手作人主页直接发起定制。',
          ),
          _HelpItem(
            question: '如何成为手作人？',
            answer: '进入"我的"页面，点击"申请成为手作人"，填写个人简介、擅长领域、作品案例等信息提交审核。审核通过后即可在平台上接单、发布作品。审核通常需要 1-3 个工作日。',
          ),
          _HelpItem(
            question: '如何支付订单？',
            answer: '提交订单后进入支付页面，支持微信支付和支付宝支付。请在 30 分钟内完成支付，超时订单将自动取消。支付成功后可在订单详情中查看支付凭证。',
          ),
          _HelpItem(
            question: '如何申请退款？',
            answer: '在"我的订单"中找到对应订单，点击"申请退款"。如果手作人尚未开始制作，可全额退款；如已开始制作，需与手作人协商退款金额。平台将在 1-3 个工作日内处理退款申请。',
          ),
          _HelpItem(
            question: '如何修改收货地址？',
            answer: '在订单未发货前，可在"我的订单"→订单详情中修改收货地址。订单已发货后如需修改，请联系手作人协商处理。',
          ),
          _HelpItem(
            question: '如何修改个人资料？',
            answer: '进入"我的"页面，点击头像或用户名进入个人资料页，点击"编辑资料"可修改昵称、头像、简介等信息，修改后点击"保存"即可。',
          ),
          _HelpItem(
            question: '如何收货确认？',
            answer: '收到定制商品后，在"我的订单"中找到对应订单，点击"确认收货"。确认收货后，交易完成，手作人将收到货款。如有问题，请在收货前联系手作人或申请平台介入。',
          ),
          SizedBox(height: AppSizes.spacingMedium),
        ],
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final String question;
  final String answer;

  const _HelpItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingSmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.spacingXSmall,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          AppSizes.paddingMedium, 0, AppSizes.paddingMedium, AppSizes.paddingMedium,
        ),
        title: Text(
          question,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        ),
        iconColor: AppColors.primary,
        children: [
          Text(
            answer,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}
