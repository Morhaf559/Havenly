import 'package:flutter/material.dart';

class CostumField extends StatefulWidget {
  CostumField({
    this.isPassword = false,
    this.width,
    this.alignment,
    this.labelText,
    this.controller,
  });
  bool? isPassword;
  //String? text;
  double? width;
  Alignment? alignment;
  String? labelText;
  final TextEditingController? controller;

  @override
  State<CostumField> createState() => _CostumFieldState();
}

class _CostumFieldState extends State<CostumField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          /* Container(
            padding: EdgeInsets.only(left: double.minPositive),
            alignment: Alignment.topLeft,
            child: Text(
              '${widget.text}',
              style: TextStyle(fontSize: 14, color: Color(0xff001733)),
            ),
          ), */
          Align(
            alignment: widget.alignment ?? Alignment.center,
            child: SizedBox(
              width: widget.width,
              child: TextField(
                controller: widget.controller,
                obscureText: widget.isPassword! ? _obscureText : false,
                decoration: InputDecoration(
                  labelText: widget.labelText,
                  labelStyle: TextStyle(fontSize: 14, color: Color(0xff001733)),
                  suffixIcon: widget.isPassword!
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
