import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final bool interactive;
  final Function(int)? onRatingChanged;

  const RatingWidget({
    super.key,
    required this.rating,
    this.interactive = false,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (interactive && onRatingChanged != null) {
      return _InteractiveRating(
        rating: rating,
        onRatingChanged: onRatingChanged!,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return Icon(
          starIndex <= rating
              ? Icons.star
              : starIndex <= rating + 0.5
              ? Icons.star_half
              : Icons.star_border,
          size: 20.sp,
          color: Colors.amber,
        );
      }),
    );
  }
}

class _InteractiveRating extends StatefulWidget {
  final double rating;
  final Function(int) onRatingChanged;

  const _InteractiveRating({
    required this.rating,
    required this.onRatingChanged,
  });

  @override
  State<_InteractiveRating> createState() => _InteractiveRatingState();
}

class _InteractiveRatingState extends State<_InteractiveRating> {
  late int _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating.round();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return GestureDetector(
          onTap: () {
            setState(() {
              _currentRating = starIndex;
            });
            widget.onRatingChanged(starIndex);
          },
          child: Icon(
            starIndex <= _currentRating ? Icons.star : Icons.star_border,
            size: 28.sp,
            color: Colors.amber,
          ),
        );
      }),
    );
  }
}
