import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nhatro_management/features/room/data/models/property_model.dart';
import 'package:nhatro_management/features/room/presentation/widgets/invoice_preview_dialog.dart';
import 'package:nhatro_management/features/invoice/data/models/invoice_detail_model.dart';
import 'package:nhatro_management/features/invoice/presentation/bloc/invoice_bloc.dart';
import 'package:nhatro_management/features/invoice/presentation/bloc/invoice_event.dart';
import 'package:nhatro_management/features/invoice/presentation/bloc/invoice_state.dart';

/// Màn hình Lịch sử hóa đơn — truy vấn từ bảng `invoices` trên Supabase.
class InvoiceListView extends StatefulWidget {
  final PropertyModel property;

  const InvoiceListView({super.key, required this.property});

  @override
  State<InvoiceListView> createState() => _InvoiceListViewState();
}

class _InvoiceListViewState extends State<InvoiceListView> {
  static const Color primaryBlue = Color(0xFF2E7D32);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color mutedText = Color(0xFF64748B);
  static const Color successGreen = Color(0xFF16A34A);
  static const Color alertRed = Color(0xFFDC2626);

  final _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
  int _filterIndex = 0;

  @override
  void initState() {
    super.initState();
    // Đảm bảo FetchInvoices được gọi thông qua BlocProvider đã được chuẩn hóa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<InvoiceBloc>().add(FetchInvoices(widget.property.id));
      }
    });
  }

  List<InvoiceDetailModel> _filter(List<InvoiceDetailModel> invoices) {
    if (_filterIndex == 1) return invoices.where((i) => i.invoice.status == 'PAID').toList();
    if (_filterIndex == 2) return invoices.where((i) => i.invoice.status == 'UNPAID').toList();
    return invoices;
  }

  String _formatMonthYear(String my) {
    try {
      final parts = my.split('-');
      if (parts.length == 2) return 'Tháng ${int.parse(parts[1])}/${parts[0]}';
    } catch (_) {}
    return my;
  }

  void _openInvoiceDetail(InvoiceDetailModel detail) {
    final inv = detail.invoice;
    showDialog(
      context: context,
      builder: (ctx) => InvoicePreviewDialog(
        roomNumber: detail.room.roomNumber,
        tenantName: detail.tenant?.fullName ?? '---',
        phoneNumber: detail.tenant?.phone ?? '---',
        monthYear: inv.monthYear,
        dueDate: 'Ngày 5 hàng tháng',
        roomRent: inv.roomCharge,
        serviceFee: detail.serviceFee,
        elecUsage: detail.elecUsage,
        elecRate: detail.room.elecRate,
        elecBefore: detail.reading?.oldElec ?? 0,
        elecAfter: detail.reading?.newElec ?? 0,
        invoiceId: inv.id,
        propertyId: widget.property.id,
        status: inv.status,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Lịch sử Hóa đơn', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      body: BlocConsumer<InvoiceBloc, InvoiceState>(
        listener: (context, state) {
          if (state is InvoiceLoaded && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message!)));
          }
        },
        builder: (context, state) {
          if (state is InvoiceLoading) {
            return const Center(child: CircularProgressIndicator(color: primaryBlue));
          }
          if (state is InvoiceError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Lỗi: ${state.message}'),
                  TextButton(
                    onPressed: () => context.read<InvoiceBloc>().add(FetchInvoices(widget.property.id)),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }
          if (state is InvoiceLoaded) {
            final filtered = _filter(state.invoices);
            return Column(
              children: [
                _buildFilterTabs(state.invoices),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('Chưa có hóa đơn nào', style: TextStyle(color: mutedText)))
                      : RefreshIndicator(
                          color: primaryBlue,
                          onRefresh: () async {
                            context.read<InvoiceBloc>().add(FetchInvoices(widget.property.id));
                          },
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) => _buildInvoiceCard(filtered[index]),
                          ),
                        ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildFilterTabs(List<InvoiceDetailModel> invoices) {
    final tabs = [
      {'label': 'Tất cả', 'count': invoices.length},
      {'label': 'Đã thu', 'count': invoices.where((i) => i.invoice.status == 'PAID').length},
      {'label': 'Chưa thu', 'count': invoices.where((i) => i.invoice.status == 'UNPAID').length},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: tabs.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final selected = _filterIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _filterIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? primaryBlue : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: selected ? null : Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  '${tabs[index]['label']} ${tabs[index]['count']}',
                  style: TextStyle(
                    color: selected ? Colors.white : mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(InvoiceDetailModel detail) {
    final inv = detail.invoice;
    final isPaid = inv.status == 'PAID';

    return GestureDetector(
      onTap: () => _openInvoiceDetail(detail),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Phòng ${detail.room.roomNumber}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPaid ? const Color(0xFFDCFCE7) : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isPaid ? '✅ Đã thu' : '🔴 Chưa thu',
                    style: TextStyle(
                      color: isPaid ? successGreen : alertRed,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${_formatMonthYear(inv.monthYear)} • ${detail.tenant?.fullName ?? "Không rõ"}',
              style: const TextStyle(fontSize: 13, color: mutedText),
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng cộng', style: TextStyle(fontSize: 14, color: mutedText)),
                Text(
                  _currencyFormat.format(inv.totalAmount),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<InvoiceBloc>().add(UpdateInvoiceStatus(
                            invoiceId: inv.id,
                            status: isPaid ? 'UNPAID' : 'PAID',
                            propertyId: widget.property.id,
                          ));
                    },
                    icon: Icon(isPaid ? Icons.undo_rounded : Icons.check_circle_outline, size: 16),
                    label: Text(isPaid ? 'Hoàn tác' : 'Đã thu tiền', style: const TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openInvoiceDetail(detail),
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('Chi tiết', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
