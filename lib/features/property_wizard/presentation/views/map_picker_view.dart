import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';

class MapPickerView extends StatefulWidget {
  const MapPickerView({super.key});

  @override
  State<MapPickerView> createState() => _MapPickerViewState();
}

class _MapPickerViewState extends State<MapPickerView> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  LatLng _point = const LatLng(10.8231, 106.6297);
  String _address = 'Đang lấy địa chỉ…';
  bool _loadingAddress = false;
  Timer? _debounce;

  String get _selectedAddress {
    if (_address.startsWith('Không thể lấy địa chỉ') ||
        _address.startsWith('Không tìm thấy') ||
        _address.startsWith('Tìm kiếm thất bại')) {
      return 'Tọa độ ${_point.latitude.toStringAsFixed(6)}, ${_point.longitude.toStringAsFixed(6)}';
    }
    return _address;
  }

  @override
  void initState() {
    super.initState();
    _reverseGeocode(_point);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reverseGeocode(LatLng point) async {
    setState(() => _loadingAddress = true);
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'format': 'jsonv2',
        'lat': '${point.latitude}',
        'lon': '${point.longitude}',
      });
      final response = await http.get(uri, headers: {
        'User-Agent': 'LOZIDO-Rental-Manager/1.0'
      }).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (mounted)
          setState(() => _address =
              data['display_name'] as String? ?? 'Không tìm thấy địa chỉ');
      } else if (mounted) {
        setState(() => _address = 'Không tìm thấy địa chỉ cho vị trí này');
      }
    } catch (_) {
      if (mounted)
        setState(() => _address =
            'Không thể lấy địa chỉ. Bạn vẫn có thể chọn tọa độ này.');
    } finally {
      if (mounted) setState(() => _loadingAddress = false);
    }
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    final normalizedCoordinates = query.replaceAll(',', '.');
    final coordinateMatch = RegExp(
          r'^\s*(-?\d+(?:\.\d+)?)\s*[,; ]\s*(-?\d+(?:\.\d+)?)\s*$',
        ).firstMatch(query) ??
        RegExp(
          r'^\s*(-?\d+(?:\.\d+)?)\s+(-?\d+(?:\.\d+)?)\s*$',
        ).firstMatch(normalizedCoordinates);
    if (coordinateMatch != null) {
      final latitude =
          double.parse(coordinateMatch.group(1)!.replaceAll(',', '.'));
      final longitude =
          double.parse(coordinateMatch.group(2)!.replaceAll(',', '.'));
      if (latitude < -90 ||
          latitude > 90 ||
          longitude < -180 ||
          longitude > 180) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Tọa độ phải nằm trong khoảng vĩ độ −90..90, kinh độ −180..180.')));
        return;
      }
      final point = LatLng(latitude, longitude);
      _mapController.move(point, 17);
      setState(() => _point = point);
      await _reverseGeocode(point);
      return;
    }
    setState(() => _loadingAddress = true);
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'format': 'jsonv2',
        'q': query,
        'limit': '1',
      });
      final response = await http.get(uri, headers: {
        'User-Agent': 'LOZIDO-Rental-Manager/1.0'
      }).timeout(const Duration(seconds: 8));
      final results = jsonDecode(response.body) as List<dynamic>;
      if (results.isEmpty) {
        if (mounted)
          setState(() => _address = 'Không tìm thấy địa chỉ phù hợp');
        return;
      }
      final result = results.first as Map<String, dynamic>;
      final point = LatLng(double.parse(result['lat'] as String),
          double.parse(result['lon'] as String));
      _mapController.move(point, 16);
      if (mounted)
        setState(() {
          _point = point;
          _address = result['display_name'] as String;
        });
    } catch (_) {
      if (mounted)
        setState(() =>
            _address = 'Tìm kiếm thất bại. Kiểm tra kết nối mạng rồi thử lại.');
    } finally {
      if (mounted) setState(() => _loadingAddress = false);
    }
  }

  Future<void> _useCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content:
                  Text('Bật Location trong Android/LDPlayer rồi thử lại.')));
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied)
        permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Cần cấp quyền vị trí để dùng GPS.')));
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 15)),
      );
      final point = LatLng(position.latitude, position.longitude);
      _mapController.move(point, 17);
      if (mounted) setState(() => _point = point);
      await _reverseGeocode(point);
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không lấy được GPS: $error')));
    }
  }

  Future<void> _enterCoordinates() async {
    final latitudeController =
        TextEditingController(text: _point.latitude.toStringAsFixed(6));
    final longitudeController =
        TextEditingController(text: _point.longitude.toStringAsFixed(6));
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<LatLng>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nhập tọa độ vị trí'),
        content: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
                controller: latitudeController,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: true),
                decoration:
                    const InputDecoration(labelText: 'Vĩ độ (latitude)'),
                validator: (v) {
                  final n =
                      double.tryParse((v ?? '').trim().replaceAll(',', '.'));
                  return n == null || n < -90 || n > 90
                      ? 'Nhập vĩ độ từ −90 đến 90'
                      : null;
                }),
            TextFormField(
                controller: longitudeController,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: true),
                decoration:
                    const InputDecoration(labelText: 'Kinh độ (longitude)'),
                validator: (v) {
                  final n =
                      double.tryParse((v ?? '').trim().replaceAll(',', '.'));
                  return n == null || n < -180 || n > 180
                      ? 'Nhập kinh độ từ −180 đến 180'
                      : null;
                }),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy')),
          FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate())
                  Navigator.pop(
                      dialogContext,
                      LatLng(
                        double.parse(latitudeController.text
                            .trim()
                            .replaceAll(',', '.')),
                        double.parse(longitudeController.text
                            .trim()
                            .replaceAll(',', '.')),
                      ));
              },
              child: const Text('Định vị')),
        ],
      ),
    );
    latitudeController.dispose();
    longitudeController.dispose();
    if (result == null || !mounted) return;
    _mapController.move(result, 17);
    setState(() => _point = result);
    await _reverseGeocode(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Chọn vị trí nhà trọ',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
      body: Stack(children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
              initialCenter: _point,
              initialZoom: 15,
              onPositionChanged: (camera, hasGesture) {
                if (!hasGesture) return;
                _point = camera.center;
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 700),
                    () => _reverseGeocode(_point));
              }),
          children: [
            TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.lozido.nhatro_management'),
            const RichAttributionWidget(attributions: [
              TextSourceAttribution('© OpenStreetMap contributors')
            ]),
          ],
        ),
        const Center(
            child: Padding(
                padding: EdgeInsets.only(bottom: 34),
                child: Icon(Icons.location_pin,
                    size: 48, color: AppColors.dangerRed))),
        Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(14),
              color: Colors.white,
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _search(),
                decoration: InputDecoration(
                  hintText: 'Tìm địa chỉ nhà trọ…',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                      onPressed: _search,
                      icon: const Icon(Icons.arrow_forward)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            )),
        Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 12)
                  ]),
              child: SafeArea(
                  top: false,
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ĐỊA CHỈ ĐÃ CHỌN',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                letterSpacing: 1)),
                        const SizedBox(height: 8),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on,
                                  color: AppColors.primaryGreen),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(_selectedAddress,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600))),
                              if (_loadingAddress)
                                const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2)),
                            ]),
                        const SizedBox(height: 4),
                        Text(
                            '${_point.latitude.toStringAsFixed(6)}, ${_point.longitude.toStringAsFixed(6)}',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(
                              child: OutlinedButton.icon(
                                  onPressed: _useCurrentLocation,
                                  icon: const Icon(Icons.my_location),
                                  label: const Text('Vị trí hiện tại'))),
                          const SizedBox(width: 12),
                          Expanded(
                              child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context, {
                                        'lat': _point.latitude,
                                        'lng': _point.longitude,
                                        'address': _selectedAddress
                                      }),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryGreen,
                                      foregroundColor: Colors.white),
                                  child: const Text('Chọn vị trí'))),
                        ]),
                        Align(
                          alignment: Alignment.center,
                          child: TextButton.icon(
                            onPressed: _enterCoordinates,
                            icon: const Icon(Icons.pin_drop_outlined, size: 18),
                            label: const Text('Nhập tọa độ thủ công'),
                          ),
                        ),
                      ])),
            )),
      ]),
    );
  }
}
