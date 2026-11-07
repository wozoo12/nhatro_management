import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/property_wizard_cubit.dart';
import '../cubit/property_wizard_state.dart';
import 'property_step1_view.dart';
import 'property_step2_view.dart';
import 'success_onboarding_view.dart';
import 'package:nhatro_management/features/room/data/repositories/room_repository.dart';
import 'package:nhatro_management/features/room/data/models/property_model.dart';
import 'package:nhatro_management/features/room/data/models/room_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PropertyWizardView extends StatelessWidget {
  const PropertyWizardView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PropertyWizardCubit(),
      child: const PropertyWizardBody(),
    );
  }
}

class PropertyWizardBody extends StatelessWidget {
  const PropertyWizardBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PropertyWizardCubit, PropertyWizardState>(
      builder: (context, state) {
        final cubit = context.read<PropertyWizardCubit>();

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                if (state.currentStep > 1) {
                  cubit.previousStep();
                } else {
                  Navigator.pop(context);
                }
              },
            ),
            title: const Text(
              "Thêm mới nhà cho thuê",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline, color: Colors.grey),
                onPressed: () {},
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: state.currentStep - 1,
                  children: const [
                    PropertyStep1View(),
                    PropertyStep2View(),
                  ],
                ),
              ),

              // Bottom Action Bar & Step Progress
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5))
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Linear Progress Indicator (Step 1/2)
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: state.currentStep >= 2
                                    ? AppColors.primaryGreen
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[200],
                                foregroundColor: Colors.black87,
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text("Đóng",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (state.currentStep < 2) {
                                  cubit.nextStep();
                                } else {
                                  if (!cubit.validateStep2()) return;
                                  // Lưu property thật vào Supabase
                                  try {
                                    final repo = context.read<RoomRepository>();
                                    final userId = Supabase
                                        .instance.client.auth.currentUser?.id;

                                    if (userId == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Lỗi: Bạn chưa đăng nhập (Session đã hết hạn)')));
                                      return;
                                    }

                                    final newProperty =
                                        await repo.addProperty(PropertyModel(
                                      id: 0,
                                      userId: userId,
                                      name: state.propertyName,
                                      address: state.address,
                                      latitude: state.latitude,
                                      longitude: state.longitude,
                                      createdAt: DateTime.now(),
                                    ));

                                    // Tự động tạo danh sách phòng dựa theo state.roomCount
                                    if (state.autoCreateRooms &&
                                        state.roomCount > 0) {
                                      for (int i = 1;
                                          i <= state.roomCount;
                                          i++) {
                                        await repo.addRoom(
                                          RoomModel(
                                            id: 0,
                                            propertyId: newProperty.id,
                                            roomNumber:
                                                'Phòng ${i.toString().padLeft(2, '0')}',
                                            basePrice: state.basePrice,
                                            area: state.area,
                                            depositDefault: state.basePrice,
                                            elecRate: 3500, // Giá điện mặc định
                                            waterRate:
                                                20000, // Giá nước mặc định
                                            status: RoomStatus.AVAILABLE,
                                            createdAt: DateTime.now(),
                                          ),
                                        );
                                      }
                                    }
                                    if (context.mounted) {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const SuccessOnboardingView()),
                                        (route) => false,
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content:
                                                  Text('Lỗi tạo nhà: $e')));
                                    }
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(
                                state.currentStep < 2
                                    ? "Tiếp theo"
                                    : "Lưu thông tin",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
