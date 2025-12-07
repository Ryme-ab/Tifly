// lib/icons.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcons {
  static const String bottle = 'assets/icons/feeding-bottle.svg';

  // IconData constants
  static const IconData time = Icons.access_time;
  static const IconData feeding = Icons.restaurant;
  static const IconData feedingBottle = Icons.emoji_food_beverage;
  static const IconData sleepNight = Icons.nightlight_round;
  static const IconData sleep = Icons.bedtime;
  static const IconData medication = Icons.medication;
  static const IconData hospital = Icons.local_hospital;

  static Widget svg(String path, {double size = 32, Color? color}) =>
      SvgPicture.asset(
        path,
        width: size,
        height: size,
        colorFilter: color != null
            ? ColorFilter.mode(color, BlendMode.srcIn)
            : null,
      );
}
