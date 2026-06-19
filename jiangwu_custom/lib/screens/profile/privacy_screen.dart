import 'package:flutter/material.dart';
import '../../app/constants.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('隐私政策')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              '一、信息收集',
              '为向您提供服务，我们可能需要收集以下信息：\n\n'
              '1. 账号信息：注册时提供的手机号、昵称、头像等基本信息。\n\n'
              '2. 交易信息：下单时的收货地址、订单内容、支付记录等。\n\n'
              '3. 设备信息：设备型号、操作系统版本、唯一设备标识符等，用于保障服务安全。\n\n'
              '4. 位置信息：经您授权后，可能获取您的地理位置，用于推荐附近的手作人或服务。',
            ),
            _buildSection(
              '二、信息使用',
              '我们收集的信息将用于以下目的：\n\n'
              '1. 提供、维护和改进本平台的服务功能。\n\n'
              '2. 处理您的订单和交易，包括发货、退款、售后服务。\n\n'
              '3. 向您发送服务通知、活动信息（您可选择退订）。\n\n'
              '4. 保障平台安全，防范欺诈和违规行为。\n\n'
              '5. 进行数据分析，以优化产品和用户体验。',
            ),
            _buildSection(
              '三、信息存储与保护',
              '1. 您的个人信息存储在安全的服务器上，我们采用加密技术传输和存储敏感信息。\n\n'
              '2. 我们仅在实现服务目的所需的期限内保留您的个人信息，超出期限后将予以删除或匿名化处理。\n\n'
              '3. 我们采取严格的安全措施防止信息泄露、篡改或丢失，包括访问控制、安全审计等。\n\n'
              '4. 如发生个人信息安全事件，我们将及时通知您并向主管部门报告。',
            ),
            _buildSection(
              '四、信息共享',
              '未经您的同意，我们不会与第三方共享您的个人信息，以下情况除外：\n\n'
              '1. 为完成交易，需将订单信息（含收货信息）提供给手作人和物流方。\n\n'
              '2. 根据法律法规、政府主管部门的要求或司法机关的裁定。\n\n'
              '3. 为维护本平台及其关联公司的合法权益所必需。\n\n'
              '4. 在法律法规允许的范围内，为配合审计、合规等要求。',
            ),
            _buildSection(
              '五、未成年人保护',
              '1. 本平台重视未成年人个人信息的保护。如您为未满 18 周岁的未成年人，请在监护人的陪同下阅读本政策。\n\n'
              '2. 未经监护人同意，我们不会收集未成年人的个人信息。\n\n'
              '3. 如发现我们在未获得监护人同意的情况下收集了未成年人信息，我们将尽快删除相关信息。',
            ),
            const SizedBox(height: AppSizes.spacingLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            content,
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
