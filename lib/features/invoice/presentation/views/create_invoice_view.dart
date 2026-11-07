import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nhatro_management/core/theme/app_colors.dart';
import 'package:nhatro_management/core/utils/formatters.dart';
import 'package:nhatro_management/core/widgets/custom_text_field.dart';
import 'package:nhatro_management/features/invoice/presentation/bloc/invoice_bloc.dart';
import 'package:nhatro_management/features/invoice/presentation/bloc/invoice_event.dart';
import 'package:nhatro_management/features/invoice/presentation/bloc/invoice_state.dart';

class CreateInvoiceView extends StatefulWidget {
  final String roomNumber;
  final double roomPrice;
  final int contractId;
  final int propertyId;

  const CreateInvoiceView({
    super.key,
    required this.roomNumber,
    required this.roomPrice,
    required this.contractId,
    required this.propertyId,
  });

  @override
  State<CreateInvoiceView> createState() => _CreateInvoiceViewState();
}

class _CreateInvoiceViewState extends State<CreateInvoiceView> {
  String _reason = "Thu tiền tháng đầu tiên";
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 20));
  double _depositAmount = 0;
  bool _sendZalo = true;

  double get _proratedRent {
    int days = _endDate.difference(_startDate).inDays;
    if (days <= 0) return 0;
    return (days / 30) * widget.roomPrice;
  }

  double get _totalAmount => _proratedRent + _depositAmount;

  void _handleSubmit() {
    final monthYear = DateFormat('yyyy-MM').format(DateTime.now());

    context.read<InvoiceBloc>().add(CreateManualInvoice(
          contractId: widget.contractId,
          monthYear: monthYear,
          roomCharge: _proratedRent,
          otherFees: _depositAmount,
          propertyId: widget.propertyId,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InvoiceBloc, InvoiceState>(
      listener: (context, state) {
        if (state is InvoiceLoaded && state.message != null) {
          _showResultDialog(context, true, state.message!);
        } else if (state is InvoiceError) {
          _showResultDialog(context, false, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.lightGrayBg,
        appBar: AppBar(
          title: Text("Lập hóa đơn P.${widget.roomNumber}",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Lý do lập hóa đơn", Icons.info_outline),
              _buildReasonDropdown(),
              const SizedBox(height: 20),
              _buildSectionHeader(
                  "Tính tiền phòng lẻ ngày", Icons.calendar_month),
              _buildProratedSection(),
              const SizedBox(height: 20),
              _buildSectionHeader(
                  "Thu tiền cọc phát sinh", Icons.payments_outlined),
              CustomTextField(
                label: "Số tiền cọc",
                hintText: "3.000.000",
                isCurrency: true,
                keyboardType: TextInputType.number,
                onChanged: (v) => setState(() {
                  _depositAmount = double.tryParse(v.replaceAll('.', '')) ?? 0;
                }),
                suffixWidget: const Text("đ"),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomStickyBar(),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryGreen),
          const SizedBox(width: 8),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildReasonDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGreen, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _reason,
          isExpanded: true,
          items: [
            "Thu tiền hàng tháng",
            "Thu tiền tháng đầu tiên",
            "Thu tiền cọc",
            "Thu khi kết thúc HĐ"
          ]
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen)),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _reason = v!),
        ),
      ),
    );
  }

  Widget _buildProratedSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: _datePickerBox("Từ ngày", _startDate,
                      (d) => setState(() => _startDate = d))),
              const SizedBox(width: 12),
              Expanded(
                  child: _datePickerBox("Đến ngày", _endDate,
                      (d) => setState(() => _endDate = d))),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Tiền phòng lẻ ngày:",
                  style: TextStyle(color: Colors.grey)),
              Text(AppFormatters.formatCurrency(_proratedRent),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          Text(
              "${_endDate.difference(_startDate).inDays} ngày lẻ x ${AppFormatters.formatCurrency(widget.roomPrice)}/tháng",
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _datePickerBox(
      String label, DateTime date, Function(DateTime) onPick) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030));
        if (d != null) onPick(d);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(AppFormatters.formatDate(date),
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBottomStickyBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Checkbox(
                  value: _sendZalo,
                  activeColor: AppColors.primaryGreen,
                  onChanged: (v) => setState(() => _sendZalo = v!),
                ),
                const Text("Gửi ZALO & APP khách thuê",
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("TỔNG CỘNG",
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold)),
                    Text(AppFormatters.formatCurrency(_totalAmount),
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen)),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("+ Lập hóa đơn",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showResultDialog(BuildContext context, bool success, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(success ? Icons.check_circle_rounded : Icons.error_rounded,
                color: success ? AppColors.primaryGreen : AppColors.dangerRed,
                size: 80),
            const SizedBox(height: 16),
            Text(success ? "Thành công!" : "Thất bại!",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  if (success) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightGrayBg, elevation: 0),
                child: const Text("Đóng",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
