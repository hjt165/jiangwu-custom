import 'package:flutter/material.dart';
import '../../app/constants.dart';

class AgreementScreen extends StatelessWidget {
  const AgreementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('用户协议')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              '一、服务协议的接受',
              '欢迎使用匠物定制平台（以下简称"本平台"）。本平台由匠物定制科技有限公司运营。请您在使用本平台服务之前，仔细阅读并充分理解本协议的全部内容。一旦您注册、登录、使用本平台服务，即视为您已阅读并同意接受本协议的约束。如果您不同意本协议的任何条款，请停止使用本平台服务。',
            ),
            _buildSection(
              '二、账号注册与管理',
              '1. 您在注册账号时，应提供真实、准确、完整的个人信息，并在信息变更时及时更新。\n\n'
              '2. 您应妥善保管账号及密码，因您的保管不当导致的账号安全问题，由您自行承担全部责任。\n\n'
              '3. 您不得以任何方式转让、借用、赠与或出租账号，亦不得盗用他人账号。\n\n'
              '4. 如发现未经授权使用您的账号，应立即通知本平台。',
            ),
            _buildSection(
              '三、商品交易规则',
              '1. 本平台上的商品信息（包括但不限于价格、图片、描述）仅供参考，实际以手作人提供的商品详情为准。\n\n'
              '2. 下单前请仔细确认商品信息和定制需求，订单提交后将进入制作流程。\n\n'
              '3. 定制商品因具有个性化特征，非质量问题不支持无理由退货。\n\n'
              '4. 交易过程中产生的争议，本平台将依据本协议及相关规则进行处理。',
            ),
            _buildSection(
              '四、知识产权声明',
              '1. 本平台的所有内容（包括但不限于文字、图片、标识、软件）的知识产权归本平台或相关权利人所有。\n\n'
              '2. 用户在本平台发布的原创内容，知识产权归用户所有，但用户同意授予本平台在平台范围内展示、推广该内容的非独占许可。\n\n'
              '3. 未经授权，任何人均不得擅自复制、修改、传播本平台的内容。',
            ),
            _buildSection(
              '五、免责声明',
              '1. 因不可抗力（包括但不限于自然灾害、政策变化、网络故障）导致的服务中断，本平台不承担责任。\n\n'
              '2. 手作人发布的商品信息及承诺由手作人本人负责，本平台不承担连带责任。\n\n'
              '3. 用户因使用本平台服务产生的损失，本平台的赔偿范围以该笔交易金额为限。',
            ),
            _buildSection(
              '六、协议的修改与终止',
              '1. 本平台有权根据需要修改本协议的内容，并通过平台公告或站内信等方式通知您。\n\n'
              '2. 修改后的协议一经公布即生效，继续使用本平台服务即视为接受修改后的协议。\n\n'
              '3. 您可随时申请注销账号以终止本平台服务，注销前应处理完毕所有未完成的交易和纠纷。\n\n'
              '4. 本平台有权在您违反本协议时暂停或终止为您提供服务。',
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
