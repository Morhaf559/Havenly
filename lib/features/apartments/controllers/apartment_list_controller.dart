import 'package:get/get.dart';
import 'package:my_havenly_application/core/controllers/base_controller.dart';
import 'package:my_havenly_application/features/apartments/models/apartment_model.dart';
import 'package:my_havenly_application/features/apartments/models/apartment_filter_model.dart';
import 'package:my_havenly_application/features/apartments/repositories/apartments_repository.dart';

/// Apartment List Controller
/// Manages apartment list with search, filter, sort, and pagination
/// Uses ApartmentsRepository for all data operations
class ApartmentListController extends BaseController {
  final ApartmentsRepository _repository = Get.find<ApartmentsRepository>();

  final RxList<ApartmentModel> apartments = <ApartmentModel>[].obs;
  
  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt total = 0.obs;
  final RxBool hasMore = true.obs;
  final RxBool isLoadingMore = false.obs;
  
  // Search and Filters
  final RxString searchQuery = ''.obs;
  final Rx<ApartmentFilterModel?> filters = Rx<ApartmentFilterModel?>(null);

  // Sort
  // Note: API only supports 'price' as order field (based on Postman collection)
  // If other fields are needed, we can sort client-side after fetching
  final RxString sortBy = 'price'.obs; // Changed from 'created_at' (API limitation)
  final RxString sortDirection = 'desc'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchApartments();
  }

  /// Fetch apartments from repository
  /// Uses ApartmentsRepository (handles string→number, localization)
  Future<void> fetchApartments({bool loadMore = false}) async {
    try {
      if (loadMore) {
        isLoadingMore.value = true;
      } else {
        setLoading(true);
        currentPage.value = 1;
        hasMore.value = true;
      }
      clearError();

      final page = loadMore ? currentPage.value + 1 : 1;
      
      // Convert filters to ApartmentFilterModel if needed
      ApartmentFilterModel? filterModel = filters.value;
      
      // Exclude user's own apartments (tenant view)
      // Note: This can be added as a filter or handled in repository
      // For now, we'll let the repository handle it based on context
      
      final response = await _repository.getApartments(
        page: page,
        perPage: 10,
        keyword: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        filters: filterModel,
        sortBy: sortBy.value,
        sortDirection: sortDirection.value,
      );

      final newApartments = response.data;
      lastPage.value = response.lastPage;
      total.value = response.total;

      if (loadMore) {
        // Prevent duplicates
        final existingIds = apartments.map((apt) => apt.id).toSet();
        final uniqueNew = newApartments
            .where((apt) => !existingIds.contains(apt.id))
            .toList();
        apartments.addAll(uniqueNew);
        currentPage.value = page;
      } else {
        apartments.value = newApartments;
        currentPage.value = page;
      }

      hasMore.value = currentPage.value < lastPage.value;
    } catch (e) {
      handleError(e, title: 'Error loading apartments');
    } finally {
      setLoading(false);
      isLoadingMore.value = false;
    }
  }

  /// Refresh list (reset and fetch first page)
  Future<void> refreshList() async {
    currentPage.value = 1;
    hasMore.value = true;
    await fetchApartments(loadMore: false);
  }

  /// Apply search query
  Future<void> applySearch(String value) async {
    searchQuery.value = value;
    await refreshList();
  }

  /// Apply filters (ApartmentFilterModel)
  Future<void> applyFilters(ApartmentFilterModel newFilters) async {
    filters.value = newFilters;
    await refreshList();
  }

  /// Apply filters from Map (convenience method)
  Future<void> applyFiltersFromMap(Map<String, dynamic> newFilters) async {
    filters.value = ApartmentFilterModel.fromMap(newFilters);
    await refreshList();
  }

  /// Clear all filters
  Future<void> clearFilters() async {
    filters.value = null;
    await refreshList();
  }

  /// Set sort order
  Future<void> setSort(String field, String direction) async {
    sortBy.value = field;
    sortDirection.value = direction;
    await refreshList();
  }

  /// Load more apartments (pagination)
  Future<void> loadMore() async {
    if (!isLoadingMore.value && hasMore.value) {
      await fetchApartments(loadMore: true);
    }
  }
}
