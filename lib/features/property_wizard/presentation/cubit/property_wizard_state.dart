import 'package:equatable/equatable.dart';

enum PropertyType { nhaTro, ktx, chungCuMini, nhaNguyenCan, vanPhong }

enum RentalModel { theoPhong, theoGiuong }

class PropertyWizardState extends Equatable {
  final int currentStep;
  final PropertyType propertyType;
  final RentalModel rentalModel;
  final String propertyName;
  final bool autoCreateRooms;
  final int floorCount;
  final int roomCount;
  final double area;
  final double basePrice;
  final int billingDate;
  final int maxTenants;
  
  // Step 2: Services
  final String electricityType;
  final String waterType;
  final String trashType;
  final String internetType;

  // Step 2: Features
  final bool hasGuestApp;
  final bool sendZaloInvoice;
  final bool manageAssets;
  final bool manageVehicles;
  final bool findTenants; // Tên biến khớp với View: state.findTenants
  final bool manageContracts;
  final bool autoSms;

  // Step 2: Location
  final double latitude;
  final double longitude;
  final String address;

  // Validation Errors
  final String? propertyNameError;
  final String? roomCountError;
  final String? areaError;
  final String? addressError;

  const PropertyWizardState({
    this.currentStep = 1,
    this.propertyType = PropertyType.nhaTro,
    this.rentalModel = RentalModel.theoPhong,
    this.propertyName = '',
    this.autoCreateRooms = true,
    this.floorCount = 0,
    this.roomCount = 0,
    this.area = 0,
    this.basePrice = 0,
    this.billingDate = 1,
    this.maxTenants = 1,
    this.electricityType = 'Đồng hồ',
    this.waterType = 'Khối',
    this.trashType = 'Tháng',
    this.internetType = 'Tháng',
    this.hasGuestApp = true,
    this.sendZaloInvoice = true,
    this.manageAssets = false,
    this.manageVehicles = false,
    this.findTenants = false,
    this.manageContracts = true,
    this.autoSms = false,
    this.latitude = 0,
    this.longitude = 0,
    this.address = '',
    this.propertyNameError,
    this.roomCountError,
    this.areaError,
    this.addressError,
  });

  PropertyWizardState copyWith({
    int? currentStep,
    PropertyType? propertyType,
    RentalModel? rentalModel,
    String? propertyName,
    bool? autoCreateRooms,
    int? floorCount,
    int? roomCount,
    double? area,
    double? basePrice,
    int? billingDate,
    int? maxTenants,
    String? electricityType,
    String? waterType,
    String? trashType,
    String? internetType,
    bool? hasGuestApp,
    bool? sendZaloInvoice,
    bool? manageAssets,
    bool? manageVehicles,
    bool? findTenants,
    bool? manageContracts,
    bool? autoSms,
    double? latitude,
    double? longitude,
    String? address,
    String? propertyNameError,
    String? roomCountError,
    String? areaError,
    String? addressError,
    bool clearPropertyNameError = false,
    bool clearRoomCountError = false,
    bool clearAreaError = false,
    bool clearAddressError = false,
  }) {
    return PropertyWizardState(
      currentStep: currentStep ?? this.currentStep,
      propertyType: propertyType ?? this.propertyType,
      rentalModel: rentalModel ?? this.rentalModel,
      propertyName: propertyName ?? this.propertyName,
      autoCreateRooms: autoCreateRooms ?? this.autoCreateRooms,
      floorCount: floorCount ?? this.floorCount,
      roomCount: roomCount ?? this.roomCount,
      area: area ?? this.area,
      basePrice: basePrice ?? this.basePrice,
      billingDate: billingDate ?? this.billingDate,
      maxTenants: maxTenants ?? this.maxTenants,
      electricityType: electricityType ?? this.electricityType,
      waterType: waterType ?? this.waterType,
      trashType: trashType ?? this.trashType,
      internetType: internetType ?? this.internetType,
      hasGuestApp: hasGuestApp ?? this.hasGuestApp,
      sendZaloInvoice: sendZaloInvoice ?? this.sendZaloInvoice,
      manageAssets: manageAssets ?? this.manageAssets,
      manageVehicles: manageVehicles ?? this.manageVehicles,
      findTenants: findTenants ?? this.findTenants,
      manageContracts: manageContracts ?? this.manageContracts,
      autoSms: autoSms ?? this.autoSms,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      propertyNameError: clearPropertyNameError ? null : (propertyNameError ?? this.propertyNameError),
      roomCountError: clearRoomCountError ? null : (roomCountError ?? this.roomCountError),
      areaError: clearAreaError ? null : (areaError ?? this.areaError),
      addressError: clearAddressError ? null : (addressError ?? this.addressError),
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        propertyType,
        rentalModel,
        propertyName,
        autoCreateRooms,
        floorCount,
        roomCount,
        area,
        basePrice,
        billingDate,
        maxTenants,
        electricityType,
        waterType,
        trashType,
        internetType,
        hasGuestApp,
        sendZaloInvoice,
        manageAssets,
        manageVehicles,
        findTenants,
        manageContracts,
        autoSms,
        latitude,
        longitude,
        address,
        propertyNameError,
        roomCountError,
        areaError,
        addressError,
      ];
}
