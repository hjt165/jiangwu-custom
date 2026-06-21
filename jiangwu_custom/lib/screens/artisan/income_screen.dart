import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/constants.dart';
import '../../providers/artisan_income_provider.dart';
import '../../widgets/business/income_chart.dart';
import '../../widgets/business/withdraw_record_card.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_widget.dart';
import '../../widgets/common/button_widget.dart';

/// 手作人收入统计页面
/// 展示收入概览、收入趋势、提现记录

class IncomeScreen extends ConsumerStatefulWidget {
  const IncomeScreen({super.key});

  @override
  ConsumerState<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends ConsumerState<IncomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    Future.microtask(() {
      ref.read(artisanIncomeProvider.notifier).fetchIncomeStats();
      ref.read(artisanIncomeProvider.notifier).fetchIncomeRecords(refresh: true);
      ref.read(artisanIncomeProvider.notifier).fetchWithdrawRecords(refresh: true);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final incomeState = ref.watch(artisanIncomeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('收入统计'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '收入明细'),
            Tab(text: '提现记录'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: Column(
        children: [
          _buildIncomeOverview(incomeState),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildIncomeRecords(incomeState),
                _buildWithdrawRecords(incomeState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeOverview(ArtisanIncomeProvider incomeState) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      color: AppColors.white,
      child: Column(
        children: [
          Row(
            children: [
              _buildOverviewItem(
                label: '总收入',
                value: '¥${(incomeState.stats['totalIncome'] ?? 0.0).toStringAsFixed(2)}',
                color: AppColors.primary,
              ),
              _buildOverviewItem(
                label: '本月收入',
                value: '¥${(incomeState.stats['monthIncome'] ?? 0.0).toStringAsFixed(2)}',
                color: AppColors.blue,
              ),
              _buildOverviewItem(
                label: '待结算',
                value: '¥${(incomeState.stats['pendingIncome'] ?? 0.0).toStringAsFixed(2)}',
                color: AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          // 收入趋势图 - 从真实收入记录生成
          IncomeChart(
            data: _generateChartData(incomeState.incomeRecords),
            labels: _generateChartLabels(),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          SizedBox(
            width: double.infinity,
            child: ButtonWidget(
              text: '申请提现',
              onPressed: () => _showWithdrawDialog(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: AppSizes.spacingXSmall),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  List<double> _generateChartData(List<Map<String, dynamic>> records) {
    if (records.isEmpty) {
      return [0, 0, 0, 0, 0, 0, 0];
    }
    // 取最近7条记录的金额作为图表数据
    final recentRecords = records.take(7).toList();
    return recentRecords.map<double>((r) => (r['amount'] as num? ?? 0.0).toDouble()).toList();
  }

  List<String> _generateChartLabels() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return '${date.month}/${date.day}';
    });
  }

  Widget _buildIncomeRecords(ArtisanIncomeProvider incomeState) {
    if (incomeState.isLoading && incomeState.incomeRecords.isEmpty) {
      return const LoadingWidget();
    }

    if (incomeState.error != null && incomeState.incomeRecords.isEmpty) {
      return CustomErrorWidget(
        message: incomeState.error!,
        onRetry: () {
          ref.read(artisanIncomeProvider.notifier).fetchIncomeRecords(refresh: true);
        },
      );
    }

    if (incomeState.incomeRecords.isEmpty) {
      return const EmptyWidget(message: '暂无收入记录');
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(artisanIncomeProvider.notifier).fetchIncomeRecords(refresh: true);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        itemCount: incomeState.incomeRecords.length,
        itemBuilder: (context, index) {
          final record = incomeState.incomeRecords[index];
          return _buildIncomeRecordCard(record);
        },
      ),
    );
  }

  Widget _buildIncomeRecordCard(Map<String, dynamic> record) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: AppSizes.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
            ),
            child: const Icon(Icons.arrow_downward, size: 20, color: AppColors.success),
          ),
          const SizedBox(width: AppSizes.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record['description'] ?? '订单收入',
                  style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSizes.spacingXSmall),
                Text(
                  record['createdAt'] ?? '',
                  style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                ),
              ],
            ),
          ),
          Text(
            '+¥${(record['amount'] ?? 0.0).toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawRecords(ArtisanIncomeProvider incomeState) {
    if (incomeState.isLoading && incomeState.withdrawRecords.isEmpty) {
      return const LoadingWidget();
    }

    if (incomeState.error != null && incomeState.withdrawRecords.isEmpty) {
      return CustomErrorWidget(
        message: incomeState.error!,
        onRetry: () {
          ref.read(artisanIncomeProvider.notifier).fetchWithdrawRecords(refresh: true);
        },
      );
    }

    if (incomeState.withdrawRecords.isEmpty) {
      return const EmptyWidget(message: '暂无提现记录');
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(artisanIncomeProvider.notifier).fetchWithdrawRecords(refresh: true);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        itemCount: incomeState.withdrawRecords.length,
        itemBuilder: (context, index) {
          final record = incomeState.withdrawRecords[index];
          return WithdrawRecordCard(
            id: record['id'] ?? '',
            amount: (record['amount'] ?? 0.0).toDouble(),
            status: record['status'] ?? 'pending',
            accountType: record['accountType'] ?? 'alipay',
            accountInfo: record['accountInfo'] ?? '',
            createdAt: DateTime.tryParse(record['createdAt'] ?? '') ?? DateTime.now(),
          );
        },
      ),
    );
  }

  void _showWithdrawDialog() {
    final amountController = TextEditingController();
    final accountController = TextEditingController();
    String selectedAccount = 'alipay';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('申请提现'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '提现金额',
                    prefixText: '¥ ',
                    hintText: '请输入提现金额',
                  ),
                ),
                const SizedBox(height: AppSizes.paddingMedium),
                Row(
                  children: [
                    const Text('提现方式: '),
                    Expanded(
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'alipay', label: Text('支付宝')),
                          ButtonSegment(value: 'wechat', label: Text('微信')),
                          ButtonSegment(value: 'bank', label: Text('银行卡')),
                        ],
                        selected: {selectedAccount},
                        onSelectionChanged: (value) {
                          setDialogState(() {
                            selectedAccount = value.first;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingMedium),
                TextField(
                  controller: accountController,
                  decoration: InputDecoration(
                    labelText: selectedAccount == 'alipay' ? '支付宝账号'
                        : selectedAccount == 'wechat' ? '微信号'
                        : '银行卡号',
                    hintText: selectedAccount == 'alipay' ? '请输入支付宝账号'
                        : selectedAccount == 'wechat' ? '请输入微信号'
                        : '请输入银行卡号',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () async {
                  final amount = double.tryParse(amountController.text);
                  if (amount == null || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('请输入有效金额'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }
                  Navigator.of(context).pop();
                  final success = await ref
                      .read(artisanIncomeProvider.notifier)
                      .requestWithdraw(
                        amount: amount,
                        accountType: selectedAccount,
                        accountInfo: accountController.text,
                      );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success ? '提现申请已提交' : '提现失败'),
                        backgroundColor: success ? AppColors.success : AppColors.error,
                      ),
                    );
                  }
                },
                child: const Text('确定提现'),
              ),
            ],
          );
        },
      ),
    );
  }
}