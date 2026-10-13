import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:nhatro_management/core/theme/app_colors.dart';
import 'package:nhatro_management/features/invoice/services/invoice_bluetooth_print_service.dart';

class BluetoothPrinterDialog extends StatefulWidget {
  final Map<String, dynamic> invoiceData;

  const BluetoothPrinterDialog({super.key, required this.invoiceData});

  @override
  State<BluetoothPrinterDialog> createState() => _BluetoothPrinterDialogState();
}

class _BluetoothPrinterDialogState extends State<BluetoothPrinterDialog> {
  List<BluetoothInfo> _devices = [];
  bool _isSearching = false;
  bool _isPrinting = false;
  String? _connectedMac;

  @override
  void initState() {
    super.initState();
    _searchDevices();
  }

  Future<void> _searchDevices() async {
    setState(() => _isSearching = true);
    try {
      final devices = await InvoiceBluetoothPrintService.getPairedDevices();
      setState(() => _devices = devices);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi quét thiết bị: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  Future<void> _printInvoice(String macAddress) async {
    setState(() => _isPrinting = true);
    try {
      bool connected = await InvoiceBluetoothPrintService.connect(macAddress);
      if (connected) {
        setState(() => _connectedMac = macAddress);
        bool printed = await InvoiceBluetoothPrintService.printInvoice(
          roomNumber: widget.invoiceData['roomNumber'],
          tenantName: widget.invoiceData['tenantName'],
          phoneNumber: widget.invoiceData['phoneNumber'],
          monthYear: widget.invoiceData['monthYear'],
          dueDate: widget.invoiceData['dueDate'],
          roomRent: widget.invoiceData['roomRent'],
          serviceFee: widget.invoiceData['serviceFee'],
          elecUsage: widget.invoiceData['elecUsage'],
          elecRate: widget.invoiceData['elecRate'],
          elecBefore: widget.invoiceData['elecBefore'],
          elecAfter: widget.invoiceData['elecAfter'],
        );
        
        if (mounted) {
          if (printed) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã in thành công!')));
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi khi gửi dữ liệu in.')));
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể kết nối máy in.')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi in: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Chọn máy in Bluetooth',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_isSearching)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              )
            else if (_devices.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Không tìm thấy thiết bị nào đã ghép nối.', style: TextStyle(color: Colors.grey)),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _devices.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final device = _devices[index];
                    final isConnected = _connectedMac == device.macAdress;
                    return ListTile(
                      leading: Icon(Icons.print_outlined, color: isConnected ? AppColors.primaryGreen : Colors.black87),
                      title: Text(device.name, style: TextStyle(fontWeight: isConnected ? FontWeight.bold : FontWeight.normal)),
                      subtitle: Text(device.macAdress, style: const TextStyle(fontSize: 11)),
                      trailing: _isPrinting && _connectedMac == device.macAdress
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen))
                          : null,
                      onTap: _isPrinting ? null : () => _printInvoice(device.macAdress),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _searchDevices,
                  child: const Text('Làm mới', style: TextStyle(color: AppColors.primaryGreen)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng', style: TextStyle(color: Colors.grey)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
