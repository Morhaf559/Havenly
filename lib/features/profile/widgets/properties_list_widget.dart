// Widget: Properties List with Property Cards
import 'package:flutter/material.dart';
import '../controllers/profile_controller.dart';
import 'property_card_widget.dart';

class PropertiesListWidget extends StatelessWidget {
  final ProfileController controller;

  const PropertiesListWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: controller.properties.length,
      itemBuilder: (context, index) {
        return PropertyCardWidget(
          property: controller.properties[index],
          controller: controller,
        );
      },
    );
  }
}

