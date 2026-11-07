import 'package:flutter_bloc/flutter_bloc.dart';
import 'property_wizard_state.dart';

class PropertyWizardCubit extends Cubit<PropertyWizardState> {
  PropertyWizardCubit() : super(const PropertyWizardState());

  void updatePropertyName(String name) {
    emit(state.copyWith(
      propertyName: name,
      propertyNameError: name.trim().isEmpty ? 'Tên nhà không được để trống' : null,
      clearPropertyNameError: name.trim().isNotEmpty,
    ));
  }

  void updatePropertyType(PropertyType type) => emit(state.copyWith(propertyType: type));

  void updateRentalModel(RentalModel model) => emit(state.copyWith(rentalModel: model));

  void toggleAutoCreate(bool value) => emit(state.copyWith(autoCreateRooms: value));

  void updateFloorCount(int count) => emit(state.copyWith(floorCount: count));

  void updateRoomCount(int count) {
    emit(state.copyWith(
      roomCount: count,
      roomCountError: count <= 0 ? 'Số lượng phòng phải lớn hơn 0' : null,
      clearRoomCountError: count > 0,
    ));
  }

  void updateArea(double area) {
    emit(state.copyWith(
      area: area,
      areaError: area <= 0 ? 'Diện tích phải lớn hơn 0' : null,
      clearAreaError: area > 0,
    ));
  }

  void updateBasePrice(double price) => emit(state.copyWith(basePrice: price));

  void updateBillingDate(int day) => emit(state.copyWith(billingDate: day));

  void updateMaxTenants(int count) => emit(state.copyWith(maxTenants: count));

  // Cài đặt dịch vụ (Sửa lỗi thiếu method)
  void updateElectricityType(String type) => emit(state.copyWith(electricityType: type));
  void updateWaterType(String type) => emit(state.copyWith(waterType: type));

  // Toggles từ Spec (Sửa lỗi đồng bộ tên với View)
  void toggleGuestApp(bool value) => emit(state.copyWith(hasGuestApp: value));
  void toggleZaloInvoice(bool value) => emit(state.copyWith(sendZaloInvoice: value));
  void toggleAssets(bool value) => emit(state.copyWith(manageAssets: value));
  void toggleVehicles(bool value) => emit(state.copyWith(manageVehicles: value));
  void toggleJobManagement(bool value) => emit(state.copyWith(findTenants: value));
  void toggleSms(bool value) => emit(state.copyWith(autoSms: value));

  // Ảnh nhà trọ
  void updateCoverImage(String path) => emit(state.copyWith(coverImagePath: path));
  void clearImage() => emit(state.copyWith(clearCoverImage: true));

  void updateLocation(double lat, double lng, String address) {
    emit(state.copyWith(
      latitude: lat,
      longitude: lng,
      address: address,
      addressError: address.isEmpty ? 'Vui lòng chọn địa chỉ' : null,
      clearAddressError: address.isNotEmpty,
    ));
  }

  bool validateStep1() {
    final nameError = state.propertyName.trim().isEmpty ? 'Tên nhà không được để trống' : null;
    final roomError = (state.autoCreateRooms && state.roomCount <= 0) ? 'Số lượng phòng phải lớn hơn 0' : null;
    final areaError = (state.autoCreateRooms && state.area <= 0) ? 'Diện tích phải lớn hơn 0' : null;

    emit(state.copyWith(
      propertyNameError: nameError,
      roomCountError: roomError,
      areaError: areaError,
      clearPropertyNameError: nameError == null,
      clearRoomCountError: roomError == null,
      clearAreaError: areaError == null,
    ));

    return nameError == null && roomError == null && areaError == null;
  }

  bool validateStep2() {
    final addrError = state.address.isEmpty ? 'Vui lòng chọn địa chỉ' : null;
    emit(state.copyWith(
      addressError: addrError,
      clearAddressError: addrError == null,
    ));
    return addrError == null;
  }

  void nextStep() {
    if (state.currentStep == 1) {
      if (validateStep1()) {
        emit(state.copyWith(currentStep: 2));
      }
    }
  }

  void previousStep() {
    if (state.currentStep > 1) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }
}
