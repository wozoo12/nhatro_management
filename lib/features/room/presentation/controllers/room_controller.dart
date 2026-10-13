import 'package:flutter/material.dart';
import '../../data/models/property_model.dart';
import '../../data/models/room_model.dart';
import '../../data/repositories/room_repository.dart';

class RoomController extends ChangeNotifier {
  final RoomRepository _repository;

  RoomController(this._repository);

  // State
  List<PropertyModel> _properties = [];
  List<RoomModel> _rooms = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<PropertyModel> get properties => _properties;
  List<RoomModel> get rooms => _rooms;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- ACTIONS ---

  /// Tải danh sách tất cả khu nhà
  Future<void> fetchProperties() async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      _properties = await _repository.getProperties();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Thêm khu nhà mới
  Future<bool> addProperty(String name, String? address, String userId) async {
    _setLoading(true);
    try {
      final newProperty = PropertyModel(
        id: 0, // Server will generate this
        userId: userId,
        name: name,
        address: address,
        createdAt: DateTime.now(),
      );
      await _repository.addProperty(newProperty);
      await fetchProperties(); // Refresh list
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Cập nhật khu nhà
  Future<bool> updateProperty(int id, String name, String? address) async {
    _setLoading(true);
    try {
      await _repository.updateProperty(id, name, address);
      await fetchProperties();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Xóa khu nhà
  Future<bool> deleteProperty(int id) async {
    _setLoading(true);
    try {
      await _repository.deleteProperty(id);
      await fetchProperties();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Tải danh sách phòng của một khu nhà
  Future<void> fetchRoomsByProperty(int propertyId) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      _rooms = await _repository.getRoomsByProperty(propertyId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Thêm phòng mới
  Future<bool> addRoom(RoomModel room) async {
    _setLoading(true);
    try {
      await _repository.addRoom(room);
      await fetchRoomsByProperty(room.propertyId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Cập nhật phòng
  Future<bool> updateRoom(RoomModel room) async {
    _setLoading(true);
    try {
      await _repository.updateRoom(room);
      await fetchRoomsByProperty(room.propertyId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Xóa phòng
  Future<bool> deleteRoom(int roomId, int propertyId) async {
    _setLoading(true);
    try {
      await _repository.deleteRoom(roomId);
      await fetchRoomsByProperty(propertyId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
