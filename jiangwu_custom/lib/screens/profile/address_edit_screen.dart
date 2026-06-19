import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/constants.dart';
import '../../models/address.dart';
import '../../providers/address_provider.dart';

/// 新增/编辑地址页
class AddressEditScreen extends ConsumerStatefulWidget {
  final Address? address;

  const AddressEditScreen({super.key, this.address});

  @override
  ConsumerState<AddressEditScreen> createState() => _AddressEditScreenState();
}

class _AddressEditScreenState extends ConsumerState<AddressEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _provinceController;
  late TextEditingController _cityController;
  late TextEditingController _districtController;
  late TextEditingController _detailController;
  bool _isDefault = false;
  bool _isLoading = false;

  bool get _isEditing => widget.address != null;

  @override
  void initState() {
    super.initState();
    final addr = widget.address;
    _nameController = TextEditingController(text: addr?.name ?? '');
    _phoneController = TextEditingController(text: addr?.phone ?? '');
    _provinceController = TextEditingController(text: addr?.province ?? '');
    _cityController = TextEditingController(text: addr?.city ?? '');
    _districtController = TextEditingController(text: addr?.district ?? '');
    _detailController = TextEditingController(text: addr?.detail ?? '');
    _isDefault = addr?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _provinceController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      bool success;
      if (_isEditing) {
        success = await ref.read(addressProvider.notifier).updateAddress(
          id: widget.address!.id,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          province: _provinceController.text.trim(),
          city: _cityController.text.trim(),
          district: _districtController.text.trim(),
          detail: _detailController.text.trim(),
          isDefault: _isDefault,
        );
      } else {
        success = await ref.read(addressProvider.notifier).createAddress(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          province: _provinceController.text.trim(),
          city: _cityController.text.trim(),
          district: _districtController.text.trim(),
          detail: _detailController.text.trim(),
          isDefault: _isDefault,
        );
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? '地址已更新' : '地址已添加'), backgroundColor: AppColors.success),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败：$e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? '编辑地址' : '新增地址')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField(_nameController, '收货人', Icons.person, '请输入收货人姓名'),
              _buildField(_phoneController, '手机号', Icons.phone, '请输入手机号'),
              _buildField(_provinceController, '省份', Icons.location_city, '请输入省份'),
              _buildField(_cityController, '城市', Icons.location_city, '请输入城市'),
              _buildField(_districtController, '区县', Icons.location_on, '请输入区县'),
              _buildField(_detailController, '详细地址', Icons.home, '请输入详细地址', maxLines: 2),
              const SizedBox(height: AppSizes.spacingMedium),

              SwitchListTile(
                title: const Text('设为默认地址', style: TextStyle(fontSize: 14)),
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v),
                activeThumbColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: AppSizes.spacingLarge),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('保存', style: TextStyle(fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, String hint, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingMedium),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
        ),
        validator: (v) => v == null || v.trim().isEmpty ? '请输入$label' : null,
      ),
    );
  }
}
