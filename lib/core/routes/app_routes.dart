import 'package:get/get.dart';
import 'package:my_havenly_application/core/routes/route_transitions.dart';
import 'package:my_havenly_application/features/notifications/bindings/notifications_binding.dart';
import 'package:my_havenly_application/features/onboarding/view/screens/splash_screen.dart';
import 'package:my_havenly_application/features/auth/view/screens/login_screen.dart';
import 'package:my_havenly_application/features/auth/view/screens/register_screen.dart';
import 'package:my_havenly_application/features/auth/view/screens/reset_password_screen.dart';
import 'package:my_havenly_application/features/apartments/views/screens/apartment_list_screen.dart';
import 'package:my_havenly_application/features/apartments/views/screens/apartment_details_screen.dart';
import 'package:my_havenly_application/features/reservations/views/screens/reservation_request_details_screen.dart';
import 'package:my_havenly_application/features/reservations/views/screens/reservation_request_list_screen.dart';
import 'package:my_havenly_application/features/reservations/views/screens/create_reservation_request_screen.dart';
import 'package:my_havenly_application/features/reservations/views/screens/reservation_list_screen.dart';
import 'package:my_havenly_application/features/reservations/views/screens/reservation_details_screen.dart';
import 'package:my_havenly_application/features/notifications/views/screens/notifications_screen.dart';
import 'package:my_havenly_application/features/apartments/views/screens/add_apartment_screen.dart';
import 'package:my_havenly_application/features/apartments/views/screens/edit_apartment_screen.dart';
import 'package:my_havenly_application/features/apartments/views/screens/manage_apartment_photos_screen.dart';
import 'package:my_havenly_application/features/apartments/views/screens/apartment_photos_gallery_screen.dart';
import 'package:my_havenly_application/features/favorites/views/screens/favorite_list_screen.dart';
import 'package:my_havenly_application/features/main/view/screens/main_wrapper_screen.dart';
import 'package:my_havenly_application/features/search/views/screens/search_results_screen.dart';
import 'package:my_havenly_application/features/search/bindings/search_binding.dart';
import 'package:my_havenly_application/features/owner/views/screens/owner_reservation_requests_screen.dart';
import 'package:my_havenly_application/features/owner/views/screens/owner_reservation_request_details_screen.dart';
import 'package:my_havenly_application/features/owner/views/screens/owner_active_reservations_screen.dart';
import 'package:my_havenly_application/features/owner/views/screens/owner_reservation_details_screen.dart';
import 'package:my_havenly_application/features/owner/views/screens/owner_reservation_modifications_screen.dart';
import 'package:my_havenly_application/features/owner/views/screens/owner_reservation_modification_details_screen.dart';
import 'package:my_havenly_application/features/owner/views/screens/owner_properties_list_screen.dart';
import 'package:my_havenly_application/features/owner/views/screens/owner_dashboard_screen.dart';
import 'package:my_havenly_application/features/owner/owner_binding.dart';
import 'package:my_havenly_application/features/auth/bindings/auth_binding.dart';
import 'package:my_havenly_application/features/apartments/bindings/apartments_binding.dart';
import 'package:my_havenly_application/features/favorites/bindings/favorites_binding.dart';
import 'package:my_havenly_application/features/reservations/bindings/reservations_binding.dart';
import 'package:my_havenly_application/features/main/bindings/main_binding.dart';
import 'package:my_havenly_application/features/profile/bindings/profile_binding.dart';
import 'package:my_havenly_application/features/main/view/widgets/profile_content_widget.dart';
import 'package:my_havenly_application/features/profile/views/screens/profile_edit_screen.dart';
import 'package:my_havenly_application/features/onboarding/bindings/onboarding_binding.dart';
import 'package:my_havenly_application/features/onboarding/view/screens/onboarding_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String resetPassword = '/reset-password';
  static const String main = '/main';
  static const String home = '/home';
  static const String apartments = '/apartments';
  static const String apartmentDetails = '/apartment-details';
  static const String searchResults = '/search-results';

  static const String reservationRequests = '/reservation-requests';
  static const String createReservationRequest = '/reservation-requests/create';
  static const String reservationRequestDetails = '/reservation-requests/:id';
  static const String editReservationRequest = '/reservation-requests/:id/edit';
  static const String reservations = '/reservations';
  static const String reservationDetails = '/reservations/:id';

  static const String notifications = '/notifications';
  static const String addApartment = '/apartments/add';
  static const String editApartment = '/apartments/edit/:id';
  static const String apartmentPhotosGallery = '/apartments/:id/photos-gallery';
  static const String favorites = '/favorites';

  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';

  static const String ownerDashboard = '/owner/dashboard';
  static const String ownerPropertiesList = '/owner/properties';
  static const String ownerReservationRequests = '/owner/reservation-requests';
  static const String ownerReservationRequestDetails =
      '/owner/reservation-requests/:id';
  static const String ownerActiveReservations = '/owner/reservations';
  static const String ownerReservationDetails = '/owner/reservations/:id';
  static const String ownerReservationModifications = '/owner/modifications';
  static const String ownerReservationModificationDetails =
      '/owner/modifications/:id';
  static const String manageApartmentPhotos = '/apartments/:id/photos';
  static List<GetPage> getPages = [
    RouteTransitions.buildPageRoute(
      name: splash,
      page: () => SplashScreen(forceShowOnboarding: false),
    ),
    RouteTransitions.buildPageRoute(
      name: onboarding,
      page: () => const OnboardingScreen(),
      binding: OnboardingBinding(),
    ),
    RouteTransitions.buildPageRoute(
      name: login,
      page: () => LoginScreen(),
      binding: AuthBinding(),
    ),
    RouteTransitions.buildPageRoute(
      name: register,
      page: () => RegisterScreen(),
      binding: AuthBinding(),
    ),
    RouteTransitions.buildPageRoute(
      name: resetPassword,
      page: () => ResetPasswordScreen(),
      binding: AuthBinding(),
    ),
    RouteTransitions.buildPageRoute(
      name: main,
      page: () => const MainWrapperScreen(),
      binding: MainBinding(),
    ),
    RouteTransitions.buildPageRoute(
      name: apartments,
      page: () => const ApartmentListScreen(),
      binding: ApartmentsBinding(),
    ),
    RouteTransitions.buildPageRoute(
      name: apartmentDetails,
      page: () => const ApartmentDetailsScreen(),
      binding: ApartmentsBinding(),
    ),

    RouteTransitions.buildPageRoute(
      name: searchResults,
      page: () => const SearchResultsScreen(),
      binding: SearchBinding(),
    ),

    RouteTransitions.buildPageRoute(
      name: reservationRequests,
      page: () => const ReservationRequestListScreen(),
      binding: ReservationsBinding(),
    ),
    RouteTransitions.buildPageRoute(
      name: createReservationRequest,
      page: () {
        final apartmentId = Get.arguments as int? ?? 0;
        return CreateReservationRequestScreen(apartmentId: apartmentId);
      },
      binding: ReservationsBinding(),
    ),
    RouteTransitions.buildPageRoute(
      name: reservationRequestDetails,
      page: () {
        final parameters = Get.parameters;
        final idParam = parameters['id'] ?? '';
        final id = int.tryParse(idParam);
        return ReservationRequestDetailsScreen(requestId: id ?? 0);
      },
      binding: ReservationsBinding(),
    ),
    RouteTransitions.buildPageRoute(
      name: reservations,
      page: () => const ReservationListScreen(),
      binding: ReservationsBinding(),
    ),
    RouteTransitions.buildPageRoute(
      name: reservationDetails,
      page: () {
        final parameters = Get.parameters;
        final idParam = parameters['id'] ?? '';
        final id = int.tryParse(idParam);

        return ReservationDetailsScreen(reservationId: id ?? 0);
      },
      binding: ReservationsBinding(),
    ),

    RouteTransitions.buildPageRoute(
      name: notifications,
      page: () => const NotificationsScreen(),
      binding: NotificationsBinding(),
    ),

    RouteTransitions.buildPageRoute(
      name: addApartment,
      page: () => const AddApartmentScreen(),
      binding: ApartmentsBinding(),
    ),
    RouteTransitions.buildPageRoute(
      name: editApartment,
      page: () {
        final parameters = Get.parameters;
        final idParam = parameters['id'] ?? '';
        final id = int.tryParse(idParam);

        return EditApartmentScreen(apartmentId: id ?? 0);
      },
      binding: ApartmentsBinding(),
    ),
    RouteTransitions.buildPageRoute(
      name: manageApartmentPhotos,
      page: () {
        final parameters = Get.parameters;
        final idParam = parameters['id'] ?? '';
        final id = int.tryParse(idParam);

        return ManageApartmentPhotosScreen(apartmentId: id ?? 0);
      },
      binding: ApartmentsBinding(),
    ),
    RouteTransitions.buildPageRoute(
      name: apartmentPhotosGallery,
      page: () => const ApartmentPhotosGalleryScreen(),
      binding: ApartmentsBinding(),
    ),
    RouteTransitions.buildPageRoute(
      name: favorites,
      page: () => const FavoriteListScreen(),
      binding: FavoritesBinding(),
    ),

    RouteTransitions.buildPageRoute(
      name: profile,
      page: () => const ProfileContentWidget(),
      binding: ProfileBinding(),
    ),
    RouteTransitions.buildPageRoute(
      name: profileEdit,
      page: () => const ProfileEditScreen(),
      binding: ProfileBinding(),
    ),
    RouteTransitions.buildPageRoute(
      name: ownerDashboard,
      page: () => const OwnerDashboardScreen(),
      binding: OwnerBinding(),
    ),
    RouteTransitions.buildPageRoute(
      name: ownerPropertiesList,
      page: () => const OwnerPropertiesListScreen(),
      binding: OwnerBinding(),
    ),
    RouteTransitions.buildPageRoute(
      name: ownerReservationRequests,
      page: () => const OwnerReservationRequestsScreen(),
      binding: OwnerBinding(),
    ),
    RouteTransitions.buildPageRoute(
      name: ownerReservationRequestDetails,
      page: () {
        final parameters = Get.parameters;
        final idParam = parameters['id'] ?? '';
        final requestId = int.tryParse(idParam);
        return OwnerReservationRequestDetailsScreen(requestId: requestId ?? 0);
      },
      binding: OwnerBinding(),
    ),
    RouteTransitions.buildPageRoute(
      name: ownerActiveReservations,
      page: () => const OwnerActiveReservationsScreen(),
      binding: OwnerBinding(),
    ),
    RouteTransitions.buildPageRoute(
      name: ownerReservationDetails,
      page: () {
        final id = int.tryParse(Get.parameters['id'] ?? '0') ?? 0;
        return OwnerReservationDetailsScreen(reservationId: id);
      },
      binding: OwnerBinding(),
    ),
    RouteTransitions.buildPageRoute(
      name: ownerReservationModifications,
      page: () => const OwnerReservationModificationsScreen(),
      binding: OwnerBinding(),
    ),
    RouteTransitions.buildPageRoute(
      name: ownerReservationModificationDetails,
      page: () {
        final id = int.tryParse(Get.parameters['id'] ?? '0') ?? 0;
        return OwnerReservationModificationDetailsScreen(modificationId: id);
      },
      binding: OwnerBinding(),
    ),
  ];
}
