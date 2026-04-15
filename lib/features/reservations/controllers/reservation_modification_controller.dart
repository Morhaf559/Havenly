import 'package:get/get.dart';
import 'package:my_havenly_application/core/controllers/base_controller.dart';
import 'package:my_havenly_application/features/reservations/models/reservation_modification_model.dart';
import 'package:my_havenly_application/features/reservations/repositories/reservation_modifications_repository.dart';

class ReservationModificationController extends BaseController {
  final ReservationModificationsRepository _repository =
      Get.find<ReservationModificationsRepository>();

  final RxList<ReservationModificationModel> modifications =
      <ReservationModificationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchModifications();
  }

  Future<void> fetchModifications() async {
    try {
      setLoading(true);
      clearError();

      final result = await _repository.getModifications();
      modifications.value = result;
    } catch (e) {
      handleError(e, title: 'Error loading modifications');
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchTenantSentModifications() async {
    try {
      setLoading(true);
      clearError();

      final result = await _repository.getTenantSentModifications();
      modifications.value = result;
    } catch (e) {
      handleError(e, title: 'Error loading modifications');
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchTenantReceivedModifications() async {
    try {
      setLoading(true);
      clearError();

      final result = await _repository.getTenantReceivedModifications();
      modifications.value = result;
    } catch (e) {
      handleError(e, title: 'Error loading modifications');
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchReservationModifications(int reservationId) async {
    try {
      setLoading(true);
      clearError();

      final result = await _repository.getReservationModifications(
        reservationId,
      );
      modifications.value = result;
    } catch (e) {
      handleError(e, title: 'Error loading reservation modifications');
    } finally {
      setLoading(false);
    }
  }

  Future<bool> requestModification({
    required int reservationId,
    dynamic requestedStartDate,
    dynamic requestedEndDate,
    String? note,
    bool isCancellation = false,
  }) async {
    try {
      setLoading(true);
      clearError();

      await _repository.requestModification(
        reservationId: reservationId,
        requestedStartDate: requestedStartDate,
        requestedEndDate: requestedEndDate,
        note: note,
        isCancellation: isCancellation,
      );

      await fetchModifications();
      return true;
    } catch (e) {
      handleError(e, title: 'Error requesting modification');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> acceptModification(int modificationId) async {
    try {
      setLoading(true);
      clearError();

      await _repository.acceptModification(modificationId);

      await fetchModifications();
      return true;
    } catch (e) {
      handleError(e, title: 'Error accepting modification');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> rejectModification(int modificationId) async {
    try {
      setLoading(true);
      clearError();

      await _repository.rejectModification(modificationId);

      await fetchModifications();
      return true;
    } catch (e) {
      handleError(e, title: 'Error rejecting modification');
      return false;
    } finally {
      setLoading(false);
    }
  }

  @override
  Future<void> refresh() async {
    await fetchModifications();
  }
}
