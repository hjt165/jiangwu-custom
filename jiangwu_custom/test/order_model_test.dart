import 'package:flutter_test/flutter_test.dart';
import 'package:jiangwu_custom/models/order.dart';

void main() {
  group('OrderStatus', () {
    test('has correct labels', () {
      expect(OrderStatus.pendingPayment.label, '待支付');
      expect(OrderStatus.paid.label, '已支付');
      expect(OrderStatus.producing.label, '制作中');
      expect(OrderStatus.stageDelivering.label, '阶段交付中');
      expect(OrderStatus.completed.label, '已完成');
      expect(OrderStatus.cancelled.label, '已取消');
      expect(OrderStatus.refunding.label, '退款中');
      expect(OrderStatus.delayed.label, '延期中');
      expect(OrderStatus.disputed.label, '争议中');
    });

    test('fromString matches by name', () {
      expect(OrderStatus.fromString('paid'), OrderStatus.paid);
      expect(OrderStatus.fromString('completed'), OrderStatus.completed);
    });

    test('fromString matches by label', () {
      expect(OrderStatus.fromString('待支付'), OrderStatus.pendingPayment);
      expect(OrderStatus.fromString('制作中'), OrderStatus.producing);
    });

    test('fromString returns pendingPayment for unknown', () {
      expect(OrderStatus.fromString('unknown'), OrderStatus.pendingPayment);
    });
  });
}
