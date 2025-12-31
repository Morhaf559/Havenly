// Widget: Reserved Navigation Item (Special Button with Ticket Icon)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import 'ticket_icon_painter.dart';

class ReservedNavItemWidget extends StatelessWidget {
  final int index;
  final ProfileController controller;

  const ReservedNavItemWidget({
    super.key,
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.onReservedPressed,
      child: Obx(() {
        final isSelected = controller.selectedBottomNav.value == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE3F2FD) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ticket Icon
              CustomPaint(
                size: const Size(24, 24),
                painter: TicketIconPainter(
                  color: isSelected ? const Color(0xFF1565C0) : Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Reserved',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? const Color(0xFF1565C0) : Colors.white,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

