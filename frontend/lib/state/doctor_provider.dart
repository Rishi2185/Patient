import 'package:flutter/foundation.dart';

import '../api/api_exception.dart';
import '../models/doctor.dart';
import 'services.dart';

enum DoctorSort { relevance, ratingHigh, feeLow, feeHigh, experience }

extension DoctorSortX on DoctorSort {
  String get label {
    switch (this) {
      case DoctorSort.relevance:
        return 'Relevance';
      case DoctorSort.ratingHigh:
        return 'Top rated';
      case DoctorSort.feeLow:
        return 'Fee: Low to High';
      case DoctorSort.feeHigh:
        return 'Fee: High to Low';
      case DoctorSort.experience:
        return 'Most experienced';
    }
  }
}

/// Loads the doctor roster from the backend once, then holds the discovery
/// state (search query, specialty filter, availability filter and sort order)
/// and computes the filtered + sorted list client-side.
class DoctorProvider extends ChangeNotifier {
  final Services _services;
  DoctorProvider(this._services);

  final List<Doctor> _all = [];
  bool _loading = false;
  bool _loaded = false;
  String? _error;

  bool get loading => _loading;
  bool get loaded => _loaded;
  String? get error => _error;

  String _query = '';
  String? _specialtyId; // null = all
  bool _availableTodayOnly = false;
  double _minRating = 0;
  DoctorSort _sort = DoctorSort.relevance;

  String get query => _query;
  String? get specialtyId => _specialtyId;
  bool get availableTodayOnly => _availableTodayOnly;
  double get minRating => _minRating;
  DoctorSort get sort => _sort;

  bool get hasActiveFilters =>
      _specialtyId != null ||
      _availableTodayOnly ||
      _minRating > 0 ||
      _sort != DoctorSort.relevance;

  /// Fetch the full roster from the backend (cached after the first success).
  Future<void> load({bool force = false}) async {
    if (_loading || (_loaded && !force)) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final page = await _services.doctors.list(limit: 100, sort: 'relevance');
      _all
        ..clear()
        ..addAll(page.data);
      _loaded = true;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setSpecialty(String? id) {
    _specialtyId = (_specialtyId == id) ? null : id;
    notifyListeners();
  }

  void setSort(DoctorSort sort) {
    _sort = sort;
    notifyListeners();
  }

  void setAvailableTodayOnly(bool value) {
    _availableTodayOnly = value;
    notifyListeners();
  }

  void setMinRating(double value) {
    _minRating = value;
    notifyListeners();
  }

  void clearFilters() {
    _specialtyId = null;
    _availableTodayOnly = false;
    _minRating = 0;
    _sort = DoctorSort.relevance;
    notifyListeners();
  }

  List<Doctor> get doctors {
    var list = [..._all];

    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase();
      list = list
          .where((d) =>
              d.name.toLowerCase().contains(q) ||
              d.specialty.name.toLowerCase().contains(q) ||
              d.qualifications.toLowerCase().contains(q))
          .toList();
    }

    if (_specialtyId != null) {
      list = list.where((d) => d.specialty.id == _specialtyId).toList();
    }

    if (_availableTodayOnly) {
      list = list.where((d) => d.availableToday).toList();
    }

    if (_minRating > 0) {
      list = list.where((d) => d.rating >= _minRating).toList();
    }

    switch (_sort) {
      case DoctorSort.relevance:
      case DoctorSort.ratingHigh:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case DoctorSort.feeLow:
        list.sort((a, b) => a.consultationFee.compareTo(b.consultationFee));
        break;
      case DoctorSort.feeHigh:
        list.sort((a, b) => b.consultationFee.compareTo(a.consultationFee));
        break;
      case DoctorSort.experience:
        list.sort((a, b) => b.experienceYears.compareTo(a.experienceYears));
        break;
    }

    return list;
  }

  /// Top-rated doctors for the home "Top doctors" rail.
  List<Doctor> get topRated {
    final list = [..._all]..sort((a, b) => b.rating.compareTo(a.rating));
    return list.take(6).toList();
  }

  /// Doctors available today, for the home "Available today" section.
  List<Doctor> get availableToday =>
      _all.where((d) => d.availableToday).take(5).toList();

  /// Lookup a loaded doctor by id (null if not in the roster).
  Doctor? byId(String id) {
    for (final d in _all) {
      if (d.id == id) return d;
    }
    return null;
  }

  /// Doctors affiliated with a given hospital.
  List<Doctor> byHospital(String hospitalId) =>
      _all.where((d) => d.hospitalId == hospitalId).toList();
}
