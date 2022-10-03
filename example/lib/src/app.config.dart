// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// ConfiguratorGenerator
// **************************************************************************

import 'package:flutter/material.dart';
import 'package:configurator_flutter/configurator_flutter.dart';
import 'dart:ui';

// ********************************
// Color Util
// ********************************

class _ColorUtil {
  static Color _colorFromHex(String input) {
    String c = input.toUpperCase().replaceAll("#", "");
    if (![6, 8].contains(c.length)) {
      return Colors.transparent;
    }
    if (c.length == 6) {
      c = 'FF$c';
    }
    int? iVal = int.tryParse(c, radix: 16);
    if (iVal != null) {
      return Color(iVal);
    }
    return Colors.transparent;
  }

  static Color _colorFromRGBString(String color) {
    try {
      bool hasAlpha = color.toLowerCase().startsWith('rgba');
      String numParts = color
          .replaceAll("rgb(", "")
          .replaceAll("rgba(", "")
          .replaceAll(")", "");
      List<String> rgbSplit = numParts.split(",").map((e) => e.trim()).toList();
      int r = int.parse(rgbSplit[0]);
      int g = int.parse(rgbSplit[1]);
      int b = int.parse(rgbSplit[2]);
      double a = hasAlpha ? double.parse(rgbSplit[3]) : 1.0;
      return Color.fromRGBO(r, g, b, a);
    } catch (e) {
      print(e);
      return Colors.transparent;
    }
  }

  static String colorToString(Color color) {
    var r = color.red;
    var g = color.green;
    var b = color.blue;
    var o = color.opacity;
    return 'rgba($r,$g,$b,$o)';
  }

  static Color parseColorValue(dynamic input) {
    if (input is Color) {
      return input;
    }
    if (input is int) {
      try {
        return Color(input);
      } catch (e) {
        print(e);
        return Colors.transparent;
      }
    }
    if (input is String) {
      if (input.toLowerCase().startsWith('rgb')) {
        return _colorFromRGBString(input);
      }
      return _colorFromHex(input);
    }
    return Colors.transparent;
  }
}

// ********************************
// Keys
// ********************************

class _FlagKeys {
  final isEnabled = 'isEnabled';

  final andThis = 'andThis';

  final andThat = 'andThat';

  final orThis = 'orThis';

  final orThat = 'orThat';

  final showTitle = 'showTitle';
}

class _ImageKeys {
  final loginHeaderImage = 'loginHeaderImage';

  final storeFrontHeaderImage = 'storeFrontHeaderImage';
}

class _RouteKeys {}

class _SizeKeys {
  final homeTitleSize = 'homeTitleSize';

  final detailTitleSize = 'detailTitleSize';
}

class _ColorKeys {
  final primary = 'primary';

  final secondary = 'secondary';

  final tertiary = 'tertiary';
}

class MyAppConfigKeys {
  static final routes = _RouteKeys();

  static final flags = _FlagKeys();

  static final sizes = _SizeKeys();

  static final colors = _ColorKeys();

  static final images = _ImageKeys();
}

// ********************************
// Theme
// ********************************

class MyAppGeneratedThemeExtension
    extends ConfigTheme<MyAppGeneratedThemeExtension> {
  MyAppGeneratedThemeExtension({required super.themeMap});

  Color get primary =>
      _ColorUtil.parseColorValue(themeMap['colors']?['primary']);
  Color get secondary =>
      _ColorUtil.parseColorValue(themeMap['colors']?['secondary']);
  Color get tertiary =>
      _ColorUtil.parseColorValue(themeMap['colors']?['tertiary']);
  double get homeTitleSize => themeMap['sizes']?['homeTitleSize'];
  double get detailTitleSize => themeMap['sizes']?['detailTitleSize'];
  @override
  MyAppGeneratedThemeExtension copyWith(
      {Map<String, Map<String, dynamic>>? themeMap}) {
    this.themeMap.addAll(themeMap ?? {});
    return MyAppGeneratedThemeExtension(themeMap: this.themeMap);
  }

  @override
  MyAppGeneratedThemeExtension lerp(
    ThemeExtension<MyAppGeneratedThemeExtension>? other,
    double t,
  ) {
    if (other is! MyAppGeneratedThemeExtension) {
      return this;
    }
    themeMap['colors']!['primary'] =
        _ColorUtil.colorToString(Color.lerp(primary, other.primary, t)!);
    themeMap['colors']!['secondary'] =
        _ColorUtil.colorToString(Color.lerp(secondary, other.secondary, t)!);
    themeMap['colors']!['tertiary'] =
        _ColorUtil.colorToString(Color.lerp(tertiary, other.tertiary, t)!);
    themeMap['sizes']!['homeTitleSize'] =
        lerpDouble(homeTitleSize, other.homeTitleSize, t);
    themeMap['sizes']!['detailTitleSize'] =
        lerpDouble(detailTitleSize, other.detailTitleSize, t);
    return MyAppGeneratedThemeExtension(themeMap: themeMap);
  }
}

// ********************************
// Flags
// ********************************

class _Flags {
  const _Flags();

  Map<String, bool> get map => {
        MyAppConfigKeys.flags.isEnabled: false,
        MyAppConfigKeys.flags.andThis: true,
        MyAppConfigKeys.flags.andThat: true,
        MyAppConfigKeys.flags.orThis: false,
        MyAppConfigKeys.flags.orThat: false,
        MyAppConfigKeys.flags.showTitle: true
      };
  bool get isEnabled => map[MyAppConfigKeys.flags.isEnabled] == true;
  bool get andThis => map[MyAppConfigKeys.flags.andThis] == true;
  bool get andThat => map[MyAppConfigKeys.flags.andThat] == true;
  bool get orThis => map[MyAppConfigKeys.flags.orThis] == true;
  bool get orThat => map[MyAppConfigKeys.flags.orThat] == true;
  bool get showTitle => map[MyAppConfigKeys.flags.showTitle] == true;
}

// ********************************
// Images
// ********************************

class _Images {
  const _Images();

  Map<String, String> get map => {
        MyAppConfigKeys.images.loginHeaderImage:
            'https://pub.dev/static/hash-qr9i96gp/img/pub-dev-logo-2x.png',
        MyAppConfigKeys.images.storeFrontHeaderImage:
            'https://pub.dev/static/hash-qr9i96gp/img/pub-dev-logo-2x.png'
      };
  String get loginHeaderImage =>
      map[MyAppConfigKeys.images.loginHeaderImage] ?? '/';
  String get storeFrontHeaderImage =>
      map[MyAppConfigKeys.images.storeFrontHeaderImage] ?? '/';
}

// ********************************
// Routes
// ********************************

class _Routes {
  const _Routes();

  Map<int, String> get map => {};
}

// ********************************
// Colors
// ********************************

class _Colors {
  const _Colors();

  Map<String, String> get map => {
        MyAppConfigKeys.colors.primary: '0000FF',
        MyAppConfigKeys.colors.secondary: 'CC0000',
        MyAppConfigKeys.colors.tertiary: '000000'
      };
  String get primary => map[MyAppConfigKeys.colors.primary] ?? '';
  String get secondary => map[MyAppConfigKeys.colors.secondary] ?? '';
  String get tertiary => map[MyAppConfigKeys.colors.tertiary] ?? '';
}

// ********************************
// Sizes
// ********************************

class _Sizes {
  const _Sizes();

  Map<String, double> get map => {
        MyAppConfigKeys.sizes.homeTitleSize: 14.0,
        MyAppConfigKeys.sizes.detailTitleSize: 22.0
      };
  double get homeTitleSize => map[MyAppConfigKeys.sizes.homeTitleSize] ?? 0.0;
  double get detailTitleSize =>
      map[MyAppConfigKeys.sizes.detailTitleSize] ?? 0.0;
}

// ********************************
// Configuration
// ********************************

class MyAppGeneratedScope extends ConfigScope {
  @override
  String name = '__GeneratedScope';

  @override
  Map<String, bool> flags = const _Flags().map;

  @override
  Map<String, String> images = const _Images().map;

  @override
  Map<String, String> colors = const _Colors().map;

  @override
  Map<String, double> sizes = const _Sizes().map;

  @override
  Map<int, String> routes = const _Routes().map;
}