import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CostumButton extends StatelessWidget {
  const CostumButton({
    super.key,
    this.onTap,
    this.text,
    this.Width,
    this.color,
    this.image,
  });

  final VoidCallback? onTap;
  final String? text;
  final Color? color;
  final double? Width;
  final String? image;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: Width,
          height: 50.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            color: onTap == null
                ? color?.withOpacity(0.6)
                : color,
            border: Border.all(
              color: Colors.blueGrey.withOpacity(0.3),
              width: 1.w,
            ),
          ),
          child: Center(
            child: text != null
                ? Text(
                    text!,
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : SizedBox(
                    height: 28.h,
                    child: Image.asset(image ?? ''),
                  ),
          ),
        ),
      ),
    );
  }
}
