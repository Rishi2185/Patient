import 'package:flutter/foundation.dart';

import '../api/api_exception.dart';
import '../models/hospital.dart';
import 'services.dart';

/// Loads and caches the hospital directory from the backend.
class HospitalProvider extends ChangeNotifier {
  final Services _services;
  HospitalProvider(this._services);

  final List<Hospital> _all = [];
  bool _loading = false;
  bool _loaded = false;
  String? _error;

  List<Hospital> get hospitals => List.unmodifiable(_all);
  bool get loading => _loading;
  bool get loaded => _loaded;
  String? get error => _error;

  Future<void> load({bool force = false}) async {
    if (_loading || (_loaded && !force)) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final list = await _services.hospitals.list();
      _all
        ..clear()
        ..addAll(list);
      _loaded = true;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Lookup a loaded hospital by id (null if not cached yet).
  Hospital? byId(String id) {
    for (final h in _all) {
      if (h.id == id) return h;
    }
    return null;
  }
}
