import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/doctor.dart';

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

/// Holds discovery state: search query, specialty filter, availability filter
/// and sort order. Computes the filtered + sorted doctor list.
class DoctorProvider extends ChangeNotifier {
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
    var list = [...MockData.doctors];

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
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
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

  /// Top-rated doctors for the home "Top Doctors" rail.
  List<Doctor> get topRated {
    final list = [...MockData.doctors]
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return list.take(6).toList();
  }
}
