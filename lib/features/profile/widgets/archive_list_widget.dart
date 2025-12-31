// Widget: Archive List (Empty State)
import 'package:flutter/material.dart';

class ArchiveListWidget extends StatelessWidget {
  const ArchiveListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Archive is empty',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    );
  }
}



