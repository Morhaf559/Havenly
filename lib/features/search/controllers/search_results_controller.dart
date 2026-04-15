import 'package:get/get.dart';
import 'package:my_havenly_application/core/controllers/base_controller.dart';
import 'package:my_havenly_application/features/apartments/models/apartment_model.dart';
import 'package:my_havenly_application/features/home/repositories/home_repository.dart';

class SearchResultsController extends BaseController {
  final HomeRepository _repository = Get.find<HomeRepository>();
  final RxString searchQuery = ''.obs;
  final RxMap<String, dynamic> filters = <String, dynamic>{}.obs;
  final Rx<int?> governorateId = Rx<int?>(null);
  final RxList<ApartmentModel> apartments = <ApartmentModel>[].obs;
  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt total = 0.obs;
  final RxBool hasMorePages = false.obs;
  final RxBool isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      searchQuery.value = arguments['search'] as String? ?? '';
      filters.value = Map<String, dynamic>.from(
        arguments['filters'] as Map? ?? {},
      );
      final govId = arguments['governorateId'] as int?;
      if (govId != null) {
        governorateId.value = govId;
        filters['governorate'] = govId;
      }
    }
    loadApartments();
  }

  Future<void> loadApartments({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        apartments.clear();
      }

      setLoading(true);
      clearError();
      Map<String, dynamic>? filtersToApply = Map<String, dynamic>.from(filters);
      if (governorateId.value != null) {
        filtersToApply['governorate'] = governorateId.value;
      }
      final response = await _repository.getAllApartments(
        page: currentPage.value,
        perPage: 20,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        filters: filtersToApply.isNotEmpty ? filtersToApply : null,
      );
      if (refresh) {
        apartments.value = response.data;
      } else {
        final existingIds = apartments.map((apt) => apt.id).toSet();
        final newApartments = response.data
            .where((apt) => !existingIds.contains(apt.id))
            .toList();
        apartments.addAll(newApartments);
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
      if (governorateId.value != null) {
        filtersToApply['governorate'] = governorateId.value;
      }
      final response = await _repository.getAllApartments(
        page: currentPage.value,
        perPage: 20,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        filters: filtersToApply.isNotEmpty ? filtersToApply : null,
      );
      final existingIds = apartments.map((apt) => apt.id).toSet();
      final newApartments = response.data
          .where((apt) => !existingIds.contains(apt.id))
          .toList();
      apartments.addAll(newApartments);
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

  @override
  Future<void> refresh() async {
    await loadApartments(refresh: true);
  }

  String getSearchSummary() {
    final parts = <String>[];
    if (searchQuery.value.isNotEmpty) {
      parts.add('"${searchQuery.value}"');
    }
    if (governorateId.value != null && governorateId.value! > 0) {
      parts.add('Governorate filter'.tr);
    }
    if (filters.isNotEmpty) {
      parts.add('${filters.length} ${'filters'.tr}');
    }
    return parts.isEmpty ? 'All Apartments'.tr : parts.join(' • ');
  }
}
