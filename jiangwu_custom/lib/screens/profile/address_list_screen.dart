import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/constants.dart';
import '../../models/address.dart';
import '../../providers/address_provider.dart';
import '../../widgets/common/async_data_view.dart';

/// 地址列表页
class AddressListScreen extends ConsumerStatefulWidget {
  const AddressListScreen({super.key});

  @override
  ConsumerState<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends ConsumerState<AddressListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(addressProvider.notifier).loadAddresses());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('收货地址'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.addressEdit),
          ),
        ],
      ),
      body: AsyncDataView(
        isLoading: state.isLoading,
        isEmpty: state.addresses.isEmpty,
        onRetry: () => ref.read(addressProvider.notifier).loadAddresses(),
        emptyIcon: Icons.location_off,
        emptyMessage: '暂无收货地址',
        emptyActionText: '新增地址',
        onEmptyAction: () => Navigator.pushNamed(context, AppRoutes.addressEdit),
        builder: (context) => _buildList(state.addresses),
      ),
    );
  }

  Widget _buildList(List<Address> addresses) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      itemCount: addresses.length,
      itemBuilder: (context, index) => _buildAddressItem(addresses[index]),
    );
  }

  Widget _buildAddressItem(Address address) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingSmall),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: address.isDefault ? Border.all(color: AppColors.primary, width: 1.5) : null,
        boxShadow: AppSizes.cardShadow,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSizes.paddingMedium),
        title: Row(
          children: [
            Text(address.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(width: AppSizes.spacingSmall),
            Text(address.phone, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            if (address.isDefault) ...[
              const SizedBox(width: AppSizes.spacingSmall),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('默认', style: TextStyle(fontSize: 11, color: AppColors.primary)),
              ),
            ],
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(address.fullAddress, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary), maxLines: 2),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleAction(value, address),
          itemBuilder: (context) => [
            if (!address.isDefault) const PopupMenuItem(value: 'default', child: Text('设为默认')),
            const PopupMenuItem(value: 'edit', child: Text('编辑')),
            const PopupMenuItem(value: 'delete', child: Text('删除', style: TextStyle(color: AppColors.error))),
          ],
        ),
        onTap: () => Navigator.pop(context, address),
      ),
    );
  }

  void _handleAction(String action, Address address) async {
    switch (action) {
      case 'default':
        await ref.read(addressProvider.notifier).setDefault(address.id);
        break;
      case 'edit':
        Navigator.pushNamed(context, AppRoutes.addressEdit, arguments: address);
        break;
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('删除地址'),
            content: const Text('确定删除该地址？'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('删除', style: TextStyle(color: AppColors.error))),
            ],
          ),
        );
        if (confirmed == true) {
          await ref.read(addressProvider.notifier).deleteAddress(address.id);
        }
        break;
    }
  }
}
