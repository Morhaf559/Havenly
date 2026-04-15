import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/utils/date_helper.dart';
import 'package:my_havenly_application/features/reservations/controllers/reservation_controller.dart';
import 'package:my_havenly_application/features/reservations/models/reservation_model.dart';
import 'package:my_havenly_application/features/reservations/views/widgets/reservation_status_badge.dart';
import 'package:my_havenly_application/features/reservations/views/widgets/modify_reservation_bottom_sheet.dart';

class ReservationDetailsScreen extends StatefulWidget {
  final int reservationId;

  const ReservationDetailsScreen({super.key, required this.reservationId});

  @override
  State<ReservationDetailsScreen> createState() =>
      _ReservationDetailsScreenState();
}

class _ReservationDetailsScreenState extends State<ReservationDetailsScreen> {
  Future<ReservationModel?>? _reservationFuture;
  final ReservationController _controller = Get.find<ReservationController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.reservationId > 0) {
        setState(() {
          _reservationFuture = _controller.getReservation(widget.reservationId);
        });
      }
    });
  }

  String _formatDate(String date, String locale) {
    final dateTime = DateHelper.parseDate(date);
    if (dateTime != null) {
      return DateHelper.formatForDisplay(dateTime, locale: locale);
    }
    return date;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reservationId <= 0) {
      return Scaffold(
        appBar: AppBar(title: Text('Reservation Details'.tr)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
              SizedBox(height: 16.h),
              Text(
                'Invalid reservation ID'.tr,
                style: TextStyle(fontSize: 16.sp, color: Colors.red),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: Text('Go Back'.tr),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Reservation Details'.tr)),
      body: FutureBuilder<ReservationModel?>(
        future: _reservationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    snapshot.error?.toString() ??
                        'Failed to load reservation'.tr,
                    style: TextStyle(fontSize: 16.sp, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: Text('Go Back'.tr),
                  ),
                ],
              ),
            );
          }

          final reservation = snapshot.data!;
          final locale = Get.locale?.languageCode ?? 'ar';
          final apartmentTitle =
              reservation.apartment?.getLocalizedTitle(locale) ??
              'Unknown Apartment';

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ReservationStatusBadge(status: reservation.status),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Apartment',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(apartmentTitle, style: TextStyle(fontSize: 16.sp)),
                  SizedBox(height: 24.h),

                  Text(
                    'Dates',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 20.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '${_formatDate(reservation.startDate, locale)} - ${_formatDate(reservation.endDate, locale)}',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h),

                  if (reservation.status?.toLowerCase() == 'active')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final startDate = DateHelper.parseDate(
                            reservation.startDate,
                          );
                          final endDate = DateHelper.parseDate(
                            reservation.endDate,
                          );

                          if (startDate != null && endDate != null) {
                            final result =
                                await ModifyReservationBottomSheet.show(
                                  context,
                                  reservationId: reservation.id,
                                  currentStartDate: startDate,
                                  currentEndDate: endDate,
                                );

                            if (result == true && mounted) {
                              setState(() {
                                _reservationFuture = _controller.getReservation(
                                  widget.reservationId,
                                );
                              });
                            }
                          }
                        },
                        icon: const Icon(Icons.edit),
                        label: Text('Request Modification'.tr),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          backgroundColor: const Color(0xff001733),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
