import 'package:nhatro_management/features/room/data/models/invoice_model.dart';
import 'package:nhatro_management/features/room/data/models/room_model.dart';
import 'package:nhatro_management/features/room/data/models/utility_reading_model.dart';
import 'package:nhatro_management/features/tenant/data/models/tenant_model.dart';

/// Model gộp hóa đơn kèm thông tin phòng, khách thuê và chỉ số điện.
class InvoiceDetailModel {
  final InvoiceModel invoice;
  final RoomModel room;
  final TenantModel? tenant;
  final UtilityReadingModel? reading;

  const InvoiceDetailModel({
    required this.invoice,
    required this.room,
    this.tenant,
    this.reading,
  });

  factory InvoiceDetailModel.fromJson(Map<String, dynamic> json) {
    final contract = json['contracts'] as Map<String, dynamic>;
    final room = RoomModel.fromJson(contract['rooms'] as Map<String, dynamic>);
    final tenantData = contract['tenants'];
    final readingData = json['utility_readings'];

    return InvoiceDetailModel(
      invoice: InvoiceModel.fromJson(json),
      room: room,
      tenant: tenantData != null ? TenantModel.fromJson(tenantData as Map<String, dynamic>) : null,
      reading: readingData != null
          ? UtilityReadingModel.fromJson(readingData as Map<String, dynamic>)
          : null,
    );
  }

  int get elecUsage {
    if (reading != null) return reading!.newElec - reading!.oldElec;
    if (room.elecRate > 0) return (invoice.elecCharge / room.elecRate).round();
    return 0;
  }

  double get serviceFee => invoice.otherFees;
}
