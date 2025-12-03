import 'package:flutter/material.dart';

class AppBarConfig {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  const AppBarConfig({
    this.title = '',
    this.actions,
    this.showBackButton = false,
  });

  AppBarConfig copyWith({
    String? title,
    List<Widget>? actions,
    bool? showBackButton,
  }) {
    return AppBarConfig(
      title: title ?? this.title,
      actions: actions ?? this.actions,
      showBackButton: showBackButton ?? this.showBackButton,
    );
  }
}
