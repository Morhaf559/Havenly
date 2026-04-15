import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/routes/app_routes.dart';
import 'package:my_havenly_application/features/reservations/controllers/reservation_request_controller.dart';
import 'package:my_havenly_application/features/reservations/views/widgets/date_range_picker_widget.dart';
import 'package:my_havenly_application/features/main/controllers/main_navigation_controller.dart';
import 'package:my_havenly_application/features/apartments/repositories/apartments_repository.dart';
import 'package:my_havenly_application/features/apartments/models/apartment_model.dart';

class CreateReservationRequestScreen extends StatefulWidget {
  final int apartmentId;

  const CreateReservationRequestScreen({super.key, required this.apartmentId});

  @override
  State<CreateReservationRequestScreen> createState() =>
      _CreateReservationRequestScreenState();
}

class _CreateReservationRequestScreenState
    extends State<CreateReservationRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  final _controller = Get.find<ReservationRequestController>();
  final _apartmentsRepository = Get.find<ApartmentsRepository>();

  DateTime? _startDate;
  DateTime? _endDate;
  ApartmentModel? _apartment;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      Get.snackbar(
        'Error'.tr,
        'Please select start and end dates'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!) ||
        _endDate!.isAtSameMomentAs(_startDate!)) {
      Get.snackbar(
        'Error'.tr,
        'End date must be after start date'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final success = await _controller.createReservationRequest(
      apartmentId: widget.apartmentId,
      startDate: _startDate!,
      endDate: _endDate!,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    if (success && mounted) {
      Get.snackbar(
        'Success'.tr,
        'Reservation request created successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      Get.back();

      await Future.delayed(const Duration(milliseconds: 400));

      Get.offAllNamed(AppRoutes.main, arguments: {'targetTab': 'reservations'});

      await Future.delayed(const Duration(milliseconds: 600));
      try {
        final navController = Get.find<MainNavigationController>();
        if (navController.visibleTabs.isEmpty) {
          await Future.delayed(const Duration(milliseconds: 300));
        }
        navController.navigateToTab('reservations', animate: true);
        await Future.delayed(const Duration(milliseconds: 300));

        try {
          final reservationRequestController =
              Get.find<ReservationRequestController>();
          await reservationRequestController.fetchSentReservationRequests();
        } catch (e) {
          Future.delayed(const Duration(milliseconds: 500), () {
            try {
              final reservationRequestController =
                  Get.find<ReservationRequestController>();
              reservationRequestController.fetchSentReservationRequests();
            } catch (e2) {}
          });
        }
      } catch (e) {}
    }
  }

  @override
  void initState() {
    super.initState();
    _loadApartmentDetails();
  }

  Future<void> _loadApartmentDetails() async {
    try {
      _apartment = await _apartmentsRepository.getApartmentDetails(
        widget.apartmentId,
      );
      setState(() {});
    } catch (e) {}
  }

  int _calculateDays() {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  double? _calculateTotalPrice() {
    if (_apartment == null || _startDate == null || _endDate == null)
      return null;
    final days = _calculateDays();
    if (days <= 0) return null;
    return days * _apartment!.price;
  }

  String? _getFormattedTotalPrice() {
    final totalPrice = _calculateTotalPrice();
    if (totalPrice == null) return null;
    final currency = _apartment?.currency ?? '\$';
    return '$currency${totalPrice.toStringAsFixed(2)}';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Reservation Request'.tr)),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Obx(() {
            if (_controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DateRangePickerWidget(
                  startDate: _startDate,
                  endDate: _endDate,
                  onStartDateSelected: (date) {
                    setState(() {
                      _startDate = date;
                      if (_endDate != null && _endDate!.isBefore(date)) {
                        _endDate = null;
                      }
                    });
                  },
                  onEndDateSelected: (date) {
                    setState(() {
                      _endDate = date;
                    });
                  },
                ),
                SizedBox(height: 24.h),

                if (_apartment != null &&
                    _startDate != null &&
                    _endDate != null) ...[
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price Summary'.tr,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Daily Price:'.tr,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              _apartment!.getFormattedPrice() +
                                  ' / ${'Day'.tr}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[900],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Number of Days:'.tr,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              '${_calculateDays()} ${'Days'.tr}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[900],
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 24.h, thickness: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Price:'.tr,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                            ),
                            Text(
                              _getFormattedTotalPrice() ?? 'N/A',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],

                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: 'Note (Optional)',
                    hintText: 'Add any special requests or notes',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                  maxLines: 4,
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: 32.h),

                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Submit Request',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ),

                if (_controller.errorMessage.value != null) ...[
                  SizedBox(height: 16.h),
                  Text(
                    _controller.errorMessage.value!,
                    style: TextStyle(fontSize: 14.sp, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            );
          }),
        ),
      ),
    );
  }
}
