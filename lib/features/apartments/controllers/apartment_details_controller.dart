import 'package:get/get.dart';
import 'package:my_havenly_application/core/controllers/base_controller.dart';
import 'package:my_havenly_application/core/controllers/auth_state_controller.dart';
import 'package:my_havenly_application/features/apartments/models/apartment_model.dart';
import 'package:my_havenly_application/features/apartments/models/apartment_photo_model.dart';
import 'package:my_havenly_application/features/apartments/models/apartment_filter_model.dart';
import 'package:my_havenly_application/features/apartments/repositories/apartments_repository.dart';
import 'package:my_havenly_application/features/apartments/repositories/apartment_media_repository.dart';
import 'package:my_havenly_application/features/reviews/controllers/review_controller.dart';

/// Apartment Details Controller
/// Manages apartment details display
/// Uses ApartmentsRepository for data operations
/// Uses ApartmentMediaRepository for photo operations (isolated logic)
/// 
/// IMPORTANT: Booking button is only shown when:
/// - User is NOT the owner of the apartment
/// - Navigation is from Home or Favorites (not from Owner Dashboard)
class ApartmentDetailsController extends BaseController {
  final ApartmentsRepository _repository = Get.find<ApartmentsRepository>();
  final ApartmentMediaRepository _mediaRepository = Get.find<ApartmentMediaRepository>();
  final AuthStateController _authStateController = Get.find<AuthStateController>();

  final Rx<ApartmentModel?> apartment = Rx<ApartmentModel?>(null);
  final RxList<ApartmentPhotoModel> photos = <ApartmentPhotoModel>[].obs;

  final ReviewController reviewController = Get.find<ReviewController>();

  // Whether to show booking button (default: true, set to false from Owner Dashboard)
  final RxBool showBookingButton = true.obs;
  
  // Whether current user is the owner of this apartment
  final RxBool isOwner = false.obs;
  
  // Cache of user's apartment IDs (to check ownership)
  Set<int>? _userApartmentIds;

  @override
  void onInit() {
    super.onInit();
    // Get arguments - can be int (apartmentId) or Map with apartmentId and showBookingButton
    final arguments = Get.arguments;
    
    int? apartmentId;
    bool shouldShowBooking = true;
    
    if (arguments is int) {
      apartmentId = arguments;
    } else if (arguments is Map) {
      apartmentId = arguments['apartmentId'] as int?;
      shouldShowBooking = arguments['showBookingButton'] as bool? ?? true;
    }
    
    // Set initial booking button visibility
    showBookingButton.value = shouldShowBooking;
    
    if (apartmentId != null) {
      fetchApartmentDetails(apartmentId);
      fetchApartmentPhotos(apartmentId);
      reviewController.fetchReviews(apartmentId);
      
      // Check if user owns this apartment (async, don't block)
      _checkApartmentOwnership(apartmentId);
    }
  }
  
  /// Check if apartment belongs to current user
  /// If yes, hide booking button and set isOwner to true
  Future<void> _checkApartmentOwnership(int apartmentId) async {
    final userId = _authStateController.user?.id;
    if (userId == null) {
      isOwner.value = false;
      return;
    }
    
    try {
      // Load user's apartment IDs if not cached
      if (_userApartmentIds == null) {
        final userFilter = ApartmentFilterModel(
          customFilters: {'user_id': userId},
        );
        final userApartmentsResponse = await _repository.getApartments(
          page: 1,
          perPage: 100,
          filters: userFilter,
        );
        _userApartmentIds = userApartmentsResponse.data
            .map((apt) => apt.id)
            .toSet();
      }
      
      // Check if user owns this apartment
      final ownsApartment = _userApartmentIds?.contains(apartmentId) ?? false;
      isOwner.value = ownsApartment;
      
      // If user owns this apartment, hide booking button
      if (ownsApartment) {
        showBookingButton.value = false;
      }
    } catch (e) {
      // Silently fail - keep current state
      isOwner.value = false;
    }
  }

  /// Fetch apartment details
  /// Uses ApartmentsRepository (handles string→number, localization)
  Future<void> fetchApartment(int id) async {
    try {
      setLoading(true);
      clearError();

      final result = await _repository.getApartmentDetails(id);
      apartment.value = result;
    } catch (e) {
      handleError(e, title: 'Error loading apartment details');
    } finally {
      setLoading(false);
    }
  }

  /// Fetch apartment details (alias for fetchApartment)
  Future<void> fetchApartmentDetails(int id) async {
    await fetchApartment(id);
  }

  /// Fetch apartment photos
  /// Uses Repository (isolated logic)
  Future<void> fetchApartmentPhotos(int id) async {
    try {
      final result = await _mediaRepository.getPhotos(id);
      photos.value = result;
    } catch (e) {
      // Photos are optional, don't set error for photos failure
      photos.value = [];
    }
  }
}

