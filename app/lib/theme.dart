import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff256a4b),
      surfaceTint: Color(0xff256a4b),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffabf2c9),
      onPrimaryContainer: Color(0xff005234),
      secondary: Color(0xff4d6356),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffd0e8d7),
      onSecondaryContainer: Color(0xff364b3f),
      tertiary: Color(0xff3c6472),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffc0e9fa),
      onTertiaryContainer: Color(0xff234c59),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfff5fbf4),
      onSurface: Color(0xff171d19),
      onSurfaceVariant: Color(0xff404943),
      outline: Color(0xff707972),
      outlineVariant: Color(0xffc0c9c1),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c322e),
      inversePrimary: Color(0xff90d5ae),
      primaryFixed: Color(0xffabf2c9),
      onPrimaryFixed: Color(0xff002112),
      primaryFixedDim: Color(0xff90d5ae),
      onPrimaryFixedVariant: Color(0xff005234),
      secondaryFixed: Color(0xffd0e8d7),
      onSecondaryFixed: Color(0xff0b1f15),
      secondaryFixedDim: Color(0xffb4ccbc),
      onSecondaryFixedVariant: Color(0xff364b3f),
      tertiaryFixed: Color(0xffc0e9fa),
      onTertiaryFixed: Color(0xff001f28),
      tertiaryFixedDim: Color(0xffa4cddd),
      onTertiaryFixedVariant: Color(0xff234c59),
      surfaceDim: Color(0xffd6dbd5),
      surfaceBright: Color(0xfff5fbf4),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff0f5ef),
      surfaceContainer: Color(0xffeaefe9),
      surfaceContainerHigh: Color(0xffe4eae3),
      surfaceContainerHighest: Color(0xffdee4de),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff003f27),
      surfaceTint: Color(0xff256a4b),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff357959),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff263b2f),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff5c7264),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff0e3b48),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff4b7381),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff5fbf4),
      onSurface: Color(0xff0d120f),
      onSurfaceVariant: Color(0xff303832),
      outline: Color(0xff4c554e),
      outlineVariant: Color(0xff666f68),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c322e),
      inversePrimary: Color(0xff90d5ae),
      primaryFixed: Color(0xff357959),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff186041),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff5c7264),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff445a4d),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff4b7381),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff325a68),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc2c8c2),
      surfaceBright: Color(0xfff5fbf4),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff0f5ef),
      surfaceContainer: Color(0xffe4eae3),
      surfaceContainerHigh: Color(0xffd9ded8),
      surfaceContainerHighest: Color(0xffced3cd),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff00341f),
      surfaceTint: Color(0xff256a4b),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff045436),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff1c3025),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff394e41),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff00313e),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff264e5c),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff5fbf4),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff262e29),
      outlineVariant: Color(0xff434b45),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c322e),
      inversePrimary: Color(0xff90d5ae),
      primaryFixed: Color(0xff045436),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff003b25),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff394e41),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff22372b),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff264e5c),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff093745),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb5bab4),
      surfaceBright: Color(0xfff5fbf4),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffedf2ec),
      surfaceContainer: Color(0xffdee4de),
      surfaceContainerHigh: Color(0xffd0d6d0),
      surfaceContainerHighest: Color(0xffc2c8c2),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff90d5ae),
      surfaceTint: Color(0xff90d5ae),
      onPrimary: Color(0xff003823),
      primaryContainer: Color(0xff005234),
      onPrimaryContainer: Color(0xffabf2c9),
      secondary: Color(0xffb4ccbc),
      onSecondary: Color(0xff203529),
      secondaryContainer: Color(0xff364b3f),
      onSecondaryContainer: Color(0xffd0e8d7),
      tertiary: Color(0xffa4cddd),
      onTertiary: Color(0xff053542),
      tertiaryContainer: Color(0xff234c59),
      onTertiaryContainer: Color(0xffc0e9fa),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff0f1511),
      onSurface: Color(0xffdee4de),
      onSurfaceVariant: Color(0xffc0c9c1),
      outline: Color(0xff8a938c),
      outlineVariant: Color(0xff404943),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee4de),
      inversePrimary: Color(0xff256a4b),
      primaryFixed: Color(0xffabf2c9),
      onPrimaryFixed: Color(0xff002112),
      primaryFixedDim: Color(0xff90d5ae),
      onPrimaryFixedVariant: Color(0xff005234),
      secondaryFixed: Color(0xffd0e8d7),
      onSecondaryFixed: Color(0xff0b1f15),
      secondaryFixedDim: Color(0xffb4ccbc),
      onSecondaryFixedVariant: Color(0xff364b3f),
      tertiaryFixed: Color(0xffc0e9fa),
      onTertiaryFixed: Color(0xff001f28),
      tertiaryFixedDim: Color(0xffa4cddd),
      onTertiaryFixedVariant: Color(0xff234c59),
      surfaceDim: Color(0xff0f1511),
      surfaceBright: Color(0xff353b36),
      surfaceContainerLowest: Color(0xff0a0f0c),
      surfaceContainerLow: Color(0xff171d19),
      surfaceContainer: Color(0xff1b211d),
      surfaceContainerHigh: Color(0xff262b27),
      surfaceContainerHighest: Color(0xff303632),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffa5ecc3),
      surfaceTint: Color(0xff90d5ae),
      onPrimary: Color(0xff002c1a),
      primaryContainer: Color(0xff5a9e7b),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffcae2d1),
      onSecondary: Color(0xff152a1f),
      secondaryContainer: Color(0xff7f9687),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffbae3f3),
      onTertiary: Color(0xff002a35),
      tertiaryContainer: Color(0xff6f97a6),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff0f1511),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffd6dfd6),
      outline: Color(0xffabb4ac),
      outlineVariant: Color(0xff8a938b),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee4de),
      inversePrimary: Color(0xff015335),
      primaryFixed: Color(0xffabf2c9),
      onPrimaryFixed: Color(0xff00150a),
      primaryFixedDim: Color(0xff90d5ae),
      onPrimaryFixedVariant: Color(0xff003f27),
      secondaryFixed: Color(0xffd0e8d7),
      onSecondaryFixed: Color(0xff02150b),
      secondaryFixedDim: Color(0xffb4ccbc),
      onSecondaryFixedVariant: Color(0xff263b2f),
      tertiaryFixed: Color(0xffc0e9fa),
      onTertiaryFixed: Color(0xff00141a),
      tertiaryFixedDim: Color(0xffa4cddd),
      onTertiaryFixedVariant: Color(0xff0e3b48),
      surfaceDim: Color(0xff0f1511),
      surfaceBright: Color(0xff404641),
      surfaceContainerLowest: Color(0xff040806),
      surfaceContainerLow: Color(0xff191f1b),
      surfaceContainer: Color(0xff242925),
      surfaceContainerHigh: Color(0xff2e3430),
      surfaceContainerHighest: Color(0xff393f3b),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffbbffd7),
      surfaceTint: Color(0xff90d5ae),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xff8cd1ab),
      onPrimaryContainer: Color(0xff000e06),
      secondary: Color(0xffddf6e5),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffb0c8b8),
      onSecondaryContainer: Color(0xff000e06),
      tertiary: Color(0xffdbf4ff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffa0c9d9),
      onTertiaryContainer: Color(0xff000d13),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff0f1511),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffe9f2ea),
      outlineVariant: Color(0xffbcc5bd),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee4de),
      inversePrimary: Color(0xff015335),
      primaryFixed: Color(0xffabf2c9),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xff90d5ae),
      onPrimaryFixedVariant: Color(0xff00150a),
      secondaryFixed: Color(0xffd0e8d7),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffb4ccbc),
      onSecondaryFixedVariant: Color(0xff02150b),
      tertiaryFixed: Color(0xffc0e9fa),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffa4cddd),
      onTertiaryFixedVariant: Color(0xff00141a),
      surfaceDim: Color(0xff0f1511),
      surfaceBright: Color(0xff4c514d),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1b211d),
      surfaceContainer: Color(0xff2c322e),
      surfaceContainerHigh: Color(0xff373d38),
      surfaceContainerHighest: Color(0xff424844),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.surface,
     canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
