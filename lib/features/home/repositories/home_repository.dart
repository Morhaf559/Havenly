import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/models/api_response.dart';
import 'package:my_havenly_application/core/controllers/auth_state_controller.dart';
import 'package:my_havenly_application/features/apartments/models/apartment_model.dart';
import 'package:my_havenly_application/features/apartments/models/apartment_filter_model.dart';
import 'package:my_havenly_application/features/apartments/repositories/apartments_repository.dart';

class HomeRepository {
  final ApartmentsRepository _apartmentsRepository = Get.find<ApartmentsRepository>();
  final AuthStateController _authStateController = Get.find<AuthStateController>();

  Future<ApiResponse<ApartmentModel>> getAvailableApartments() async {
    try {
      final currentUser = _authStateController.user;
      final userId = currentUser?.id;

      if (kDebugMode) {
        debugPrint('HomeRepository: Getting available apartments');
        debugPrint('HomeRepository: Current user ID: $userId');
      }

      final response = await _apartmentsRepository.getAvailableApartments();

      if (userId != null) {
        try {
          final userFilter = ApartmentFilterModel(
            customFilters: {'user_id': userId},
          );
          final userApartmentsResponse = await _apartmentsRepository.getApartments(
            page: 1,
            perPage: 100,
            filters: userFilter,
          );
          
          final userApartmentIds = userApartmentsResponse.data
              .map((apt) => apt.id)
              .toSet();
          
          final filteredApartments = response.data
              .where((apartment) => !userApartmentIds.contains(apartment.id))
              .toList();
          
          return ApiResponse<ApartmentModel>(
            data: filteredApartments,
            page: response.page,
            perPage: response.perPage,
            lastPage: response.lastPage,
            total: filteredApartments.length,
          );
        } catch (e) {
          if (kDebugMode) {
            debugPrint('HomeRepository: Error fetching user apartments for exclusion: $e');
          }
        }
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('HomeRepository: Error getting available apartments: $e');
      }
      rethrow;
    }
  }

  Future<ApiResponse<ApartmentModel>> getAllApartments({
    int page = 1,
    int perPage = 10,
    String? search,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final currentUser = _authStateController.user;
      final userId = currentUser?.id;

      if (kDebugMode) {
        debugPrint('HomeRepository: Getting all apartments');
        debugPrint('HomeRepository: Current user ID: $userId');
        debugPrint('HomeRepository: Page: $page, PerPage: $perPage');
        debugPrint('HomeRepository: Search: $search');
        debugPrint('HomeRepository: Filters: $filters');
      }

      ApartmentFilterModel? filterModel;
      if (filters != null && filters.isNotEmpty) {
        filterModel = ApartmentFilterModel.fromMap(filters);
      }

      final response = await _apartmentsRepository.getApartments(
        page: page,
        perPage: perPage,
        keyword: search,
        filters: filterModel,
        sortBy: 'price',
        sortDirection: 'desc',
      );

      if (userId != null) {
        try {
          final userFilter = ApartmentFilterModel(
            customFilters: {'user_id': userId},
          );
          final userApartmentsResponse = await _apartmentsRepository.getApartments(
            page: 1,
            perPage: 100,
            filters: userFilter,
          );
          
          final userApartmentIds = userApartmentsResponse.data
              .map((apt) => apt.id)
              .toSet();
          
          final filteredApartments = response.data
              .where((apartment) => !userApartmentIds.contains(apartment.id))
              .toList();
          
          return ApiResponse<ApartmentModel>(
            data: filteredApartments,
            page: response.page,
            perPage: response.perPage,
            lastPage: response.lastPage,
            total: filteredApartments.length,
          );
        } catch (e) {
          if (kDebugMode) {
            debugPrint('HomeRepository: Error fetching user apartments for exclusion: $e');
          }
        }
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('HomeRepository: Error getting all apartments: $e');
      }
      rethrow;
    }
  }
}
