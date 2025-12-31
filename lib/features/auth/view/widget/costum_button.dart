//import 'dart:ffi';

import 'package:flutter/material.dart';

class CostumButton extends StatelessWidget {
  CostumButton({this.onTap, this.text, this.Width, this.color, this.image});
  VoidCallback? onTap;
  String? text;
  Color? color;
  double? Width;
  String? image;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          child: Center(
            child: text != null
                ? Text(
                    text!,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Container(height: 28, child: Image.asset('$image')),
          ),

          width: Width,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: color,
            border: Border.all(color: Colors.blueGrey, width: 1),
          ),
        ),
      ),
    );
  }
}
