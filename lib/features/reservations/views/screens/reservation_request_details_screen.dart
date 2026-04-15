import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/routes/app_routes.dart';
import 'package:my_havenly_application/core/utils/app_colors.dart';
import 'package:my_havenly_application/core/utils/date_helper.dart';
import 'package:my_havenly_application/core/widgets/loading_widget.dart';
import 'package:my_havenly_application/core/widgets/error_state_widget.dart';
import 'package:my_havenly_application/features/reservations/controllers/reservation_request_controller.dart';
import 'package:my_havenly_application/features/reservations/models/reservation_request_model.dart';
import 'package:my_havenly_application/features/reservations/repositories/reservation_requests_repository.dart';
import 'package:my_havenly_application/features/reservations/views/widgets/reservation_status_badge.dart';
import 'package:my_havenly_application/features/reservations/views/widgets/date_range_picker_widget.dart';

class ReservationRequestDetailsScreen extends StatefulWidget {
  final int requestId;

  const ReservationRequestDetailsScreen({super.key, required this.requestId});

  @override
  State<ReservationRequestDetailsScreen> createState() =>
      _ReservationRequestDetailsScreenState();
}

class _ReservationRequestDetailsScreenState
    extends State<ReservationRequestDetailsScreen> {
  final ReservationRequestController _controller =
      Get.find<ReservationRequestController>();
  final ReservationRequestsRepository _repository =
      Get.find<ReservationRequestsRepository>();

  ReservationRequestModel? _request;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isEditing = false;

  DateTime? _startDate;
  DateTime? _endDate;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRequestDetails();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadRequestDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final request = await _repository.getReservationRequestDetails(
        widget.requestId,
      );
      setState(() {
        _request = request;
        _startDate = DateHelper.parseDate(request.startDate);
        _endDate = DateHelper.parseDate(request.endDate);
        _noteController.text = request.note ?? '';
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateRequest() async {
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

    final success = await _controller.updateReservationRequest(
      id: widget.requestId,
      startDate: _startDate!,
      endDate: _endDate!,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    if (success && mounted) {
      Get.snackbar(
        'Success'.tr,
        'Reservation request updated successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      setState(() {
        _isEditing = false;
      });
      await _loadRequestDetails();
    }
  }

  Future<void> _cancelRequest() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Cancel Reservation Request'.tr),
        content: Text(
          'Are you sure you want to cancel this reservation request?'.tr,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('No'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Yes'.tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _controller.cancelReservationRequest(
        widget.requestId,
      );
      if (success && mounted) {
        Get.snackbar(
          'Success'.tr,
          'Reservation request cancelled'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('Reservation Request Details'.tr),
        elevation: 0,
        backgroundColor: AppColors.appBarColor,
        foregroundColor: Colors.white,
        actions: [
          if (_request != null && _request!.canBeCancelled() && !_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _cancelRequest,
              tooltip: 'Cancel Request'.tr,
            ),
          if (_request != null && _request!.isPending() && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              tooltip: 'Edit Request'.tr,
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(
              message: 'Loading reservation request details...',
            )
          : _errorMessage != null
          ? ErrorStateWidget(
              message: _errorMessage!,
              onRetry: _loadRequestDetails,
            )
          : _request == null
          ? Center(
              child: Text(
                'Reservation request not found'.tr,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadRequestDetails,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ReservationStatusBadge(status: _request!.status),
                    ),
                    SizedBox(height: 24.h),
                    _buildSectionTitle('Apartment Information'.tr),
                    SizedBox(height: 12.h),
                    _buildApartmentInfo(_request!),
                    SizedBox(height: 24.h),

                    _buildSectionTitle('Reservation Details'.tr),
                    SizedBox(height: 12.h),
                    _isEditing
                        ? _buildEditForm()
                        : _buildReservationDetails(_request!),
                    SizedBox(height: 24.h),

                    if (_request!.note != null &&
                        _request!.note!.isNotEmpty &&
                        !_isEditing) ...[
                      _buildSectionTitle('Notes'.tr),
                      SizedBox(height: 12.h),
                      _buildNotesSection(_request!),
                      SizedBox(height: 24.h),
                    ],

                    if (_isEditing) ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _isEditing = false;
                                  _startDate = DateHelper.parseDate(
                                    _request!.startDate,
                                  );
                                  _endDate = DateHelper.parseDate(
                                    _request!.endDate,
                                  );
                                  _noteController.text = _request!.note ?? '';
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                side: BorderSide(color: AppColors.primaryNavy),
                              ),
                              child: Text('Cancel'.tr),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _updateRequest,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                backgroundColor: AppColors.primaryNavy,
                                foregroundColor: Colors.white,
                              ),
                              child: Text('Save Changes'.tr),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textColor,
      ),
    );
  }

  Widget _buildApartmentInfo(ReservationRequestModel request) {
    final locale = Get.locale?.languageCode ?? 'ar';
    final apartment = request.apartment;
    if (apartment == null) {
      return _buildInfoCard(
        child: Text(
          'Apartment information not available'.tr,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
      );
    }

    final title = apartment.getLocalizedTitle(locale) ?? 'No Title'.tr;
    final address =
        apartment.getLocalizedAddress(locale) ?? apartment.city ?? '';

    return _buildInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 18.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  address,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Get.toNamed(
                  AppRoutes.apartmentDetails,
                  arguments: apartment.id,
                );
              },
              icon: Icon(Icons.visibility, size: 18.sp),
              label: Text('View Apartment Details'.tr),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryNavy,
                side: BorderSide(color: AppColors.primaryNavy),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationDetails(ReservationRequestModel request) {
    return _buildInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
            icon: Icons.calendar_today,
            label: 'Start Date'.tr,
            value: DateHelper.formatForDisplay(
              DateHelper.parseDate(request.startDate)!,
              locale: Get.locale?.languageCode,
            ),
          ),
          SizedBox(height: 12.h),
          _buildDetailRow(
            icon: Icons.calendar_today,
            label: 'End Date'.tr,
            value: DateHelper.formatForDisplay(
              DateHelper.parseDate(request.endDate)!,
              locale: Get.locale?.languageCode,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return _buildInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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

          TextFormField(
            controller: _noteController,
            decoration: InputDecoration(
              labelText: 'Note (Optional)'.tr,
              hintText: 'Add any special requests or notes'.tr,
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
        ],
      ),
    );
  }

  Widget _buildNotesSection(ReservationRequestModel request) {
    return _buildInfoCard(
      child: Text(
        request.note ?? '',
        style: TextStyle(fontSize: 14.sp, color: AppColors.textColor),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: AppColors.textSecondary),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
