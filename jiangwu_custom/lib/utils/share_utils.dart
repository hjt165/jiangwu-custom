import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../app/constants.dart';

/// 分享工具类
/// 封装系统分享功能
class ShareUtils {
  ShareUtils._();

  static Future<void> shareProduct(BuildContext context, {
    required String productId,
    required String productName,
    String? imageUrl,
  }) async {
    final text = '匠物定制 | $productName\n'
        '发现这件精美的手作艺术品，快来定制属于你的专属作品！\n'
        '链接: ${ApiConstants.webBaseUrl}/product/$productId';

    await Share.share(text, subject: productName);
  }

  static Future<void> shareOrder(BuildContext context, {
    required String orderNo,
    String? productName,
  }) async {
    final text = '匠物定制 | 我的定制订单\n'
        '订单号: $orderNo'
        '${productName != null ? '\n作品: $productName' : ''}\n'
        '通过匠物定制，发现独一无二的手作艺术品';

    await Share.share(text, subject: '我的定制订单');
  }

  static Future<void> shareArtisan(BuildContext context, {
    required String artisanId,
    required String artisanName,
  }) async {
    final text = '匠物定制 | 手作人 $artisanName\n'
        '来看看这位手作人的精美作品吧！\n'
        '链接: ${ApiConstants.webBaseUrl}/artisan/$artisanId';

    await Share.share(text, subject: artisanName);
  }

  static Future<void> shareText(BuildContext context, {
    required String text,
    String? subject,
  }) async {
    await Share.share(text, subject: subject);
  }

  static Future<void> copyLink(BuildContext context, String link) async {
    await Share.shareUri(Uri.parse(link));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('链接已复制')),
      );
    }
  }
}
