import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:havenly/controller/date_controller.dart';

class DateTimeWidget extends StatelessWidget {
  DateTimeWidget({super.key});
  DateTime date = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return GetX<DateController>(
      // init: DateController(),
      builder: (controller) {
        return Container(
          child: Column(
            children: [
              Text('Date of birth'),
              SizedBox(height: 6),
              MaterialButton(
                onPressed: () async {
                  controller.pickDate(context);
                },
                color: Colors.grey,
                child: Text(
                  '${controller.selectedDate.value.day}/${controller.selectedDate.value.month}/${controller.selectedDate.value.year}',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
