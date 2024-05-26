import 'package:dynamic_toast_message/dynamic_toast_message.dart';
import 'package:flutter/material.dart';

void dynamicToastMessageConfigure() {
  DynamicToastMessage.configure(
    duration: const Duration(seconds: 3),
    consideredWidgetTypes: {
      AppBar: DynamicToastMessageConfiguration(
        alignment: Alignment.topCenter,
        offset: Offset(0, AppBar().preferredSize.height + 8),
      ),
      BottomNavigationBar: const DynamicToastMessageConfiguration(
        alignment: Alignment.bottomCenter,
        offset: Offset(0, -8 + kBottomNavigationBarHeight),
      ),
    },
    builder: (context, child) {
      return DefaultTextStyle(
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: child,
        ),
      );
    },
    animationBuilder: (context, controller, child, alignment, offset) {
      final begin = alignment == Alignment.topCenter ? const Offset(0, -1) : const Offset(0, 1);

      return SlideTransition(
        position: Tween<Offset>(begin: begin, end: const Offset(0, 0)).animate(controller),
        child: FadeTransition(
          opacity: controller,
          child: child,
        ),
      );
    },
  );
}
