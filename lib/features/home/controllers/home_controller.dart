import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/controllers/base_controller.dart';
import 'package:my_havenly_application/core/routes/app_routes.dart';
import 'package:my_havenly_application/features/apartments/models/apartment_model.dart';
import 'package:my_havenly_application/features/home/repositories/home_repository.dart';
import 'package:my_havenly_application/features/home/model/item_model.dart';
import 'package:my_havenly_application/features/governorates/controllers/governorate_controller.dart';
import 'package:my_havenly_application/features/governorates/models/governorate_model.dart';

class HomeController extends BaseController {
  final HomeRepository _repository = Get.find<HomeRepository>();

  final RxString searchText = ''.obs;

  final RxMap<String, dynamic> filters = <String, dynamic>{}.obs;

  final RxList<GovernorateModel> governorates = <GovernorateModel>[].obs;
  final Rx<GovernorateModel?> selectedGovernorate = Rx<GovernorateModel?>(null);

  final RxList<ApartmentModel> availableApartments = <ApartmentModel>[].obs;

  final RxList<ApartmentModel> allApartments = <ApartmentModel>[].obs;

  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt total = 0.obs;
  final RxBool hasMorePages = false.obs;
  final RxBool isLoadingMore = false.obs;

  String get currentLocale => Get.locale?.languageCode ?? 'ar';

  @override
  void onInit() {
    super.onInit();
    _loadGovernorates();
    loadAvailableApartments();
    loadAllApartments();
  }

  Future<void> _loadGovernorates() async {
    try {
      final governorateController = Get.find<GovernorateController>();
      if (governorateController.governorates.isEmpty) {
        await governorateController.fetchGovernorates();
      }
      governorates.value = governorateController.governorates;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('HomeController: Error loading governorates: $e');
      }
    }
  }

  Future<void> loadAvailableApartments({bool refresh = false}) async {
    try {
      if (refresh) {
        availableApartments.clear();
      }

      setLoading(true);
      clearError();

      final response = await _repository.getAvailableApartments();

      availableApartments.value = response.data.take(10).toList();
    } catch (e) {
      handleError(e, title: 'Error loading available apartments');
    } finally {
      setLoading(false);
    }
  }

  Future<void> loadAllApartments({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        allApartments.clear();
      }

      setLoading(true);
      clearError();

      Map<String, dynamic>? filtersToApply = Map<String, dynamic>.from(filters);
      if (selectedGovernorate.value != null) {
        filtersToApply['governorate'] = selectedGovernorate.value!.id;
      }

      final response = await _repository.getAllApartments(
        page: currentPage.value,
        perPage: 20,
        search: searchText.value.isNotEmpty ? searchText.value : null,
        filters: filtersToApply.isNotEmpty ? filtersToApply : null,
      );

      if (refresh) {
        allApartments.value = response.data;
      } else {
        final existingIds = allApartments.map((apt) => apt.id).toSet();
        final newApartments = response.data
            .where((apt) => !existingIds.contains(apt.id))
            .toList();
        allApartments.addAll(newApartments);
      }

      currentPage.value = response.page;
      lastPage.value = response.lastPage;
      total.value = response.total;
      hasMorePages.value = response.hasMorePages();
    } catch (e) {
      handleError(e, title: 'Error loading apartments');
    } finally {
      setLoading(false);
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMoreApartments() async {
    if (isLoadingMore.value || !hasMorePages.value) return;

    try {
      isLoadingMore.value = true;
      currentPage.value++;

      Map<String, dynamic>? filtersToApply = Map<String, dynamic>.from(filters);
      if (selectedGovernorate.value != null) {
        filtersToApply['governorate'] = selectedGovernorate.value!.id;
      }

      final response = await _repository.getAllApartments(
        page: currentPage.value,
        perPage: 20,
        search: searchText.value.isNotEmpty ? searchText.value : null,
        filters: filtersToApply.isNotEmpty ? filtersToApply : null,
      );

      final existingIds = allApartments.map((apt) => apt.id).toSet();
      final newApartments =
          response.data.where((apt) => !existingIds.contains(apt.id)).toList();
      allApartments.addAll(newApartments);

      lastPage.value = response.lastPage;
      if (response.total > 0) {
        total.value = response.total;
      }
      hasMorePages.value = response.hasMorePages();
    } catch (e) {
      handleError(e, title: 'Error loading more apartments');
      currentPage.value--;
    } finally {
      isLoadingMore.value = false;
    }
  }

  void updateSearchText(String text) {
    searchText.value = text;
    loadAllApartments(refresh: true);
  }

  void applyFilters(Map<String, dynamic> newFilters) {
    filters.value = Map<String, dynamic>.from(newFilters);
    loadAllApartments(refresh: true);
  }

  void clearFilters() {
    filters.clear();
    selectedGovernorate.value = null;
    loadAllApartments(refresh: true);
  }

  void selectGovernorate(GovernorateModel? governorate) {
    selectedGovernorate.value = governorate;
    currentPage.value = 1;
    loadAllApartments(refresh: true);
  }
  
  void navigateToSearchResults() {
    Get.toNamed(
      AppRoutes.searchResults,
      arguments: {
        'search': searchText.value,
        'filters': Map<String, dynamic>.from(filters),
        'governorateId': selectedGovernorate.value?.id,
      },
    );
  }

  ItemModel apartmentToItem(ApartmentModel apartment) {
    return ItemModel(
      id: apartment.id.toString(),
      title: apartment.getLocalizedTitle(currentLocale) ??
          'Apartment ${apartment.id}',
      category: 'apartment',
      location: _getLocationString(apartment),
      price: apartment.price,
      rating: apartment.rate ?? 0.0,
      reviewCount: 0,
      imageUrl: apartment.mainImage ?? '',
    );
  }

  String _getLocationString(ApartmentModel apartment) {
    final parts = <String>[];
    if (apartment.city != null && apartment.city!.isNotEmpty) {
      parts.add(apartment.city!);
    }
    if (apartment.governorate != null &&
        apartment.governorate!.isNotEmpty) {
      parts.add(apartment.governorate!);
    }
    return parts.isNotEmpty ? parts.join(', ') : 'Unknown Location';
  }

  List<ItemModel> get availableItems {
    return availableApartments.map((apt) => apartmentToItem(apt)).toList();
  }

  List<ItemModel> get allItems {
    return allApartments.map((apt) => apartmentToItem(apt)).toList();
  }

  Future<void> refreshApartments() async {
    await Future.wait([
      loadAvailableApartments(refresh: true),
      loadAllApartments(refresh: true),
    ]);
  }
}
