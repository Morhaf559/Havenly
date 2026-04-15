import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../governorates/views/widgets/governorate_picker.dart';

class FiltersBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic>? initialFilters;

  const FiltersBottomSheetWidget({super.key, this.initialFilters});

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    Map<String, dynamic>? initialFilters,
  }) async {
    return await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: FiltersBottomSheetWidget(initialFilters: initialFilters),
      ),
    );
  }

  @override
  State<FiltersBottomSheetWidget> createState() =>
      _FiltersBottomSheetWidgetState();
}

class _FiltersBottomSheetWidgetState extends State<FiltersBottomSheetWidget> {
  int? _selectedGovernorateId;
  final _cityController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialFilters != null) {
      _selectedGovernorateId = widget.initialFilters!['governorate'] != null
          ? int.tryParse(widget.initialFilters!['governorate'].toString())
          : null;
      _cityController.text = widget.initialFilters!['city']?.toString() ?? '';
      _minPriceController.text =
          widget.initialFilters!['min_price']?.toString() ?? '';
      _maxPriceController.text =
          widget.initialFilters!['max_price']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildFilters() {
    final filters = <String, dynamic>{};

    if (!mounted) return filters;

    if (_selectedGovernorateId != null) {
      filters['governorate'] = _selectedGovernorateId;
    }
    if (_cityController.text.isNotEmpty) {
      filters['city'] = _cityController.text.trim();
    }
    if (_minPriceController.text.isNotEmpty) {
      final minPrice = double.tryParse(_minPriceController.text);
      if (minPrice != null) {
        filters['minPrice'] = minPrice;
      }
    }
    if (_maxPriceController.text.isNotEmpty) {
      final maxPrice = double.tryParse(_maxPriceController.text);
      if (maxPrice != null) {
        filters['maxPrice'] = maxPrice;
      }
    }

    return filters;
  }

  bool _hasFilters() {
    if (!mounted) return false;

    return _selectedGovernorateId != null ||
        _cityController.text.isNotEmpty ||
        _minPriceController.text.isNotEmpty ||
        _maxPriceController.text.isNotEmpty;
  }

  void _clearFilters() {
    if (!mounted) return;

    setState(() {
      _selectedGovernorateId = null;
      _cityController.clear();
      _minPriceController.clear();
      _maxPriceController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters'.tr,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              Row(
                children: [
                  if (_hasFilters())
                    TextButton(
                      onPressed: _clearFilters,
                      child: Text(
                        'Clear'.tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      size: 24.sp,
                      color: AppColors.textColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24.h),
          GovernoratePicker(
            selectedGovernorateId: _selectedGovernorateId,
            onChanged: (value) {
              setState(() {
                _selectedGovernorateId = value;
              });
            },
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: _cityController,
            decoration: InputDecoration(
              labelText: 'City'.tr,
              hintText: 'Enter city'.tr,
              prefixIcon: Icon(
                Icons.location_city,
                color: AppColors.primaryNavy,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.primaryNavy, width: 2),
              ),
              filled: true,
              fillColor: AppColors.cardColor,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
            ),
            style: TextStyle(fontSize: 16.sp, color: AppColors.textColor),
          ),
          SizedBox(height: 16.h),
          Text(
            'Price Range'.tr,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minPriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Min Price'.tr,
                    hintText: 'Min'.tr,
                    prefixIcon: Icon(
                      Icons.attach_money,
                      color: AppColors.primaryNavy,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColors.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColors.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: AppColors.primaryNavy,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: AppColors.cardColor,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                  ),
                  style: TextStyle(fontSize: 16.sp, color: AppColors.textColor),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: TextField(
                  controller: _maxPriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Max Price'.tr,
                    hintText: 'Max'.tr,
                    prefixIcon: Icon(
                      Icons.attach_money,
                      color: AppColors.primaryNavy,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColors.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColors.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: AppColors.primaryNavy,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: AppColors.cardColor,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                  ),
                  style: TextStyle(fontSize: 16.sp, color: AppColors.textColor),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          SafeArea(
            child: AppButton(
              text: 'Apply Filters'.tr,
              icon: Icons.filter_list,
              iconPosition: IconPosition.left,
              onPressed: () {
                final filters = _buildFilters();
                Navigator.pop(context, filters);
              },
              variant: ButtonVariant.primary,
              size: ButtonSize.large,
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}
