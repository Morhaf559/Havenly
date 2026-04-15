import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_havenly_application/features/governorates/views/widgets/governorate_picker.dart';

/// Apartment Filters Bottom Sheet
/// Returns filters map when Apply button is pressed
class ApartmentFiltersBottomSheet extends StatefulWidget {
  const ApartmentFiltersBottomSheet({super.key});

  @override
  State<ApartmentFiltersBottomSheet> createState() => _ApartmentFiltersBottomSheetState();

  /// Show filters bottom sheet and return filters map
  static Future<Map<String, dynamic>?> show(BuildContext context) async {
    return await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const ApartmentFiltersBottomSheet(),
      ),
    );
  }
}

class _ApartmentFiltersBottomSheetState extends State<ApartmentFiltersBottomSheet> {
  int? _selectedGovernorateId;
  final _cityController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _roomsController = TextEditingController();

  @override
  void dispose() {
    _cityController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _roomsController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildFilters() {
    final filters = <String, dynamic>{};

    if (_selectedGovernorateId != null) {
      filters['governorate'] = _selectedGovernorateId.toString();
    }
    if (_cityController.text.isNotEmpty) {
      filters['city'] = _cityController.text;
    }
    if (_minPriceController.text.isNotEmpty) {
      filters['min_price'] = _minPriceController.text;
    }
    if (_maxPriceController.text.isNotEmpty) {
      filters['max_price'] = _maxPriceController.text;
    }
    if (_roomsController.text.isNotEmpty) {
      filters['number_of_room'] = _roomsController.text;
    }

    return filters;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, size: 24.sp),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Governorate Picker
          GovernoratePicker(
            selectedGovernorateId: _selectedGovernorateId,
            onChanged: (value) {
              setState(() {
                _selectedGovernorateId = value;
              });
            },
          ),
          SizedBox(height: 16.h),

          // City Field
          TextField(
            controller: _cityController,
            decoration: InputDecoration(
              labelText: 'City',
              hintText: 'Enter city',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
            style: TextStyle(fontSize: 16.sp),
          ),
          SizedBox(height: 16.h),

          // Price Range
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minPriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Min Price',
                    hintText: 'Min',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: TextField(
                  controller: _maxPriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Max Price',
                    hintText: 'Max',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Rooms Field
          TextField(
            controller: _roomsController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Number of Rooms',
              hintText: 'Enter number of rooms',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
            style: TextStyle(fontSize: 16.sp),
          ),
          SizedBox(height: 24.h),

          // Apply Button
          ElevatedButton(
            onPressed: () {
              final filters = _buildFilters();
              Navigator.pop(context, filters);
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Apply Filters',
              style: TextStyle(fontSize: 16.sp),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

