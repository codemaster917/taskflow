import 'package:flutter/material.dart';

class Responsive {
  // Screen width limits (in pixels).
  // Less than 600 = mobile, 600 to 1023 = tablet, 1024 or more = desktop.
  static const double mobileLimit = 600;
  static const double tabletLimit = 1024;

  // Get the screen width using MediaQuery.
  static double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  // Is the screen a mobile?
  static bool isMobile(BuildContext context) {
    return width(context) < mobileLimit;
  }

  // Is the screen a tablet?
  static bool isTablet(BuildContext context) {
    return width(context) >= mobileLimit && width(context) < tabletLimit;
  }

  // Is the screen a desktop?
  static bool isDesktop(BuildContext context) {
    return width(context) >= tabletLimit;
  }

  // How many columns should a grid or list use?
  // Mobile = 1, Tablet = 2, Desktop = 3.
  static int columns(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 3;
  }

  // On a very big screen, we don't want the content to stretch too wide.
  // This returns the maximum width the content can have.
  static double maxContentWidth(BuildContext context) {
    if (isDesktop(context)) return 1100;
    return double.infinity; // no limit on mobile and tablet
  }
}