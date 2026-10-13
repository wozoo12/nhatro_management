import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/tenant_bloc.dart';
import '../bloc/tenant_event.dart';
import '../bloc/tenant_state.dart';
import '../../data/models/tenant_model.dart';
import '../../data/models/contract_model.dart';
import '../../data/models/cccd_qr_model.dart';
import '../../data/repositories/tenant_repository.dart';
import '../../../room/data/models/room_model.dart';
import 'cccd_scanner_view.dart';
import 'add_tenant_view.dart';

/// [CreateContractView] cho phép chủ trọ ký hợp đồng mới cho một phòng trống.
/// Sau khi ký thành công, trạng thái phòng sẽ tự động chuyển sang "Đã thuê".
class CreateContractView extends StatefulWidget {
  final RoomModel room; // Phòng đang thực hiện ký hợp đồng

  const CreateContractView({super.key, required this.room});

  @override
  State<CreateContractView> createState() => _CreateContractViewState();
}

class _CreateContractViewState extends State<CreateContractView> {
  // --- QUẢN LÝ TRẠNG THÁI FORM ---
  final _formKey = GlobalKey<FormState>();
  final _depositController = TextEditingController();
  
  int? _selectedTenantId;    // Khách thuê được chọn
  DateTime _startDate = DateTime.now(); // Ngày bắt đầu hợp đồng
  CccdQrModel? _scannedCccd;

  // --- THIẾT KẾ ---
  static const Color primaryBlue = Color(0xFF2E7D32);
  static const Color backgroundColor = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    // Tải danh sách khách thuê ngay khi mở màn hình để người dùng chọn
    context.read<TenantBloc>().add(FetchTenants());
    // Mặc định tiền cọc bằng số tiền cọc mặc định của phòng
    _depositController.text = widget.room.depositDefault.toStringAsFixed(0);
  }

  /// Hàm mở cửa sổ chọn ngày (DatePicker)
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _startDate) {
      setState(() => _startDate = picked);
    }
  }

  /// Thực hiện gửi yêu cầu ký hợp đồng
  void _submitContract() {
    if (_formKey.currentState!.validate()) {
      if (_selectedTenantId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn khách thuê!')));
        return;
      }

      final double deposit = double.tryParse(_depositController.text) ?? 0;

      // Tạo đối tượng hợp đồng mới theo Schema 3NF
      final newContract = ContractModel(
        id: 0, // Database tự tăng
        roomId: widget.room.id,
        representativeTenantId: _selectedTenantId!,
        startDate: _startDate,
        actualDeposit: deposit,
        status: ContractStatus.ACTIVE, // Trạng thái ban đầu là hiệu lực
        createdAt: DateTime.now(),
      );

      // Gửi sự kiện tới BLoC
      context.read<TenantBloc>().add(CreateContract(newContract));
    }
  }

  @override
  void dispose() {
    _depositController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Ký hợp đồng mới', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: BlocListener<TenantBloc, TenantState>(
        listener: (context, state) {
          if (state is TenantLoaded && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message!)));
            // Thành công thì quay về Dashboard (Dashboard sẽ tự tải lại dữ liệu mới)
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
          if (state is TenantError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // THẺ THÔNG TIN PHÒNG (READ-ONLY)
                _buildInfoCard('Thông tin phòng', [
                  _infoRow('Số phòng:', 'Phòng ${widget.room.roomNumber}', isBold: true),
                  _infoRow('Giá thuê:', '${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(widget.room.basePrice)}/tháng'),
                ]),

                const SizedBox(height: 24),
                _buildSectionTitle('Chọn khách thuê đại diện'),
                
                // Ô CHỌN KHÁCH THUÊ
                _buildTenantSelector(),

                const SizedBox(height: 24),
                _buildSectionTitle('Chi tiết hợp đồng'),
                
                // THẺ NHẬP LIỆU
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      // Chọn ngày bắt đầu
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today_rounded, color: primaryBlue),
                        title: const Text('Ngày bắt đầu ở', style: TextStyle(fontSize: 14)),
                        trailing: Text(DateFormat('dd/MM/yyyy').format(_startDate), 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: primaryBlue)),
                        onTap: () => _selectDate(context),
                      ),
                      const Divider(),
                      // Nhập tiền cọc
                      TextFormField(
                        controller: _depositController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Số tiền cọc thực tế (đ)',
                          prefixIcon: Icon(Icons.payments_outlined, color: primaryBlue),
                          border: InputBorder.none,
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập tiền cọc' : null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Tiêu đề từng phần
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
    );
  }

  /// Card hiển thị thông tin dạng nhãn - giá trị
  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primaryBlue)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
        ],
      ),
    );
  }

  /// Quét mã QR CCCD gắn chip để tự động nhận diện hoặc thêm nhanh khách thuê
  Future<void> _scanCccdForContract() async {
    final result = await Navigator.push<CccdQrModel>(
      context,
      MaterialPageRoute(builder: (_) => const CccdScannerView()),
    );

    if (result == null) return;
    if (!mounted) return;

    setState(() => _scannedCccd = result);

    // Kiểm tra xem khách thuê đã có trong danh sách hiện tại chưa
    final state = context.read<TenantBloc>().state;
    List<TenantModel> currentTenants = [];
    if (state is TenantLoaded) {
      currentTenants = state.tenants;
    }

    // Tìm theo số CCCD hoặc họ tên
    final existing = currentTenants.cast<TenantModel?>().firstWhere(
      (t) => (t?.identityCard != null && t!.identityCard == result.cccdNumber) ||
             (t?.fullName.toLowerCase() == result.fullName.toLowerCase()),
      orElse: () => null,
    );

    if (existing != null) {
      setState(() => _selectedTenantId = existing.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã nhận diện và chọn khách thuê: ${existing.fullName}'),
            backgroundColor: AppColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      // Chưa có trong hệ thống -> Mở dialog hỏi số điện thoại để tạo nhanh
      _showFastCreateTenantDialog(result);
    }
  }

  void _showFastCreateTenantDialog(CccdQrModel cccd) {
    final phoneCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.person_add_alt_1, color: AppColors.primaryGreen),
            SizedBox(width: 8),
            Text('Tạo nhanh khách thuê', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Họ tên: ${cccd.fullName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Text('Số CCCD: ${cccd.cccdNumber}', style: const TextStyle(color: Colors.black87, fontSize: 13)),
              const SizedBox(height: 4),
              Text('Thường trú: ${cccd.address}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Số điện thoại *',
                  hintText: 'Nhập số điện thoại liên hệ',
                  prefixIcon: const Icon(Icons.phone_android, color: AppColors.primaryGreen),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (v) => (v == null || v.trim().length < 10) ? 'Vui lòng nhập SĐT hợp lệ' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final phone = phoneCtrl.text.trim();
                Navigator.pop(ctx);
                try {
                  final newTenant = TenantModel(
                    id: 0,
                    fullName: cccd.fullName,
                    phone: phone,
                    identityCard: cccd.cccdNumber,
                    createdAt: DateTime.now(),
                  );
                  final repo = context.read<TenantRepository>();
                  final created = await repo.addTenant(newTenant);
                  // Refresh danh sách trong Bloc
                  if (mounted) {
                    context.read<TenantBloc>().add(FetchTenants());
                    setState(() => _selectedTenantId = created.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã tạo khách thuê ${created.fullName} và chọn vào hợp đồng!'),
                        backgroundColor: AppColors.primaryGreen,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi tạo khách thuê: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Tạo & Chọn'),
          ),
        ],
      ),
    );
  }

  /// Widget Dropdown chọn khách thuê từ dữ liệu thật kèm nút Quét QR CCCD
  Widget _buildTenantSelector() {
    return BlocBuilder<TenantBloc, TenantState>(
      builder: (context, state) {
        List<TenantModel> tenants = [];
        if (state is TenantLoaded) tenants = state.tenants;

        return Column(
          children: [
            // Nút Quét mã QR CCCD gắn chip
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00A86B), Color(0xFF00C853)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _scanCccdForContract,
                  borderRadius: BorderRadius.circular(14),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 24),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Quét mã QR CCCD của khách thuê',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.white70),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Dropdown chọn khách có sẵn
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedTenantId,
                      isExpanded: true, // Chống tràn viền chữ
                      hint: const Text('Hoặc chọn từ danh sách khách cũ', overflow: TextOverflow.ellipsis),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.person_search_rounded, color: primaryBlue),
                      ),
                      items: tenants.map((t) => DropdownMenuItem(value: t.id, child: Text(t.fullName))).toList(),
                      onChanged: (val) => setState(() => _selectedTenantId = val),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_add_alt, color: primaryBlue),
                    tooltip: 'Thêm khách thuê mới thủ công',
                    onPressed: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTenantView()));
                      if (context.mounted) {
                        context.read<TenantBloc>().add(FetchTenants());
                      }
                    },
                  ),
                ],
              ),
            ),

            if (_scannedCccd != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.mintBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified, color: AppColors.primaryGreen, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Đã xác thực CCCD: ${_scannedCccd!.fullName} - ${_scannedCccd!.cccdNumber}',
                        style: const TextStyle(fontSize: 12, color: AppColors.primaryGreen, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  /// Nút bấm thực hiện ký hợp đồng
  Widget _buildSubmitButton() {
    return BlocBuilder<TenantBloc, TenantState>(
      builder: (context, state) {
        final bool isLoading = state is TenantLoading;
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : _submitContract,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('XÁC NHẬN KÝ HỢP ĐỒNG', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }
}
