import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Recollia design tokens — single source of truth for every colour, radius,
/// and typographic decision in the app.
abstract class RC {
  // ── Colour palette ─────────────────────────────────────────────────────
  static const Color dark       = Color(0xFF0A0A0A);
  static const Color darkRaised = Color(0xFF111010);
  static const Color amber      = Color(0xFFE89A4D);
  static const Color amberDim   = Color(0xFF9B5F1A);
  static const Color deepRed    = Color(0xFF7A1500);
  static const Color midRed     = Color(0xFFB84A08);
  static const Color ivory      = Color(0xFFF5E9D7);
  static const Color ivoryDim   = Color(0xFF8A7C6A);
  static const Color border     = Color(0x21E89A4D); // amber @ 13 % opacity

  // ── Spacing / shape ────────────────────────────────────────────────────
  static const double radiusNone  = 0;
  static const double radiusSmall = 4;
}

class AppTheme {
  static ThemeData get darkTheme {
    const cs = ColorScheme.dark(
      primary:    RC.amber,
      onPrimary:  RC.dark,
      secondary:  RC.amberDim,
      surface:    RC.darkRaised,
      onSurface:  RC.ivory,
      error:      Color(0xFFCF6679),
      onError:    RC.dark,
    );

    return ThemeData(
      brightness:              Brightness.dark,
      colorScheme:             cs,
      scaffoldBackgroundColor: RC.dark,
      useMaterial3:            true,

      // System UI overlay — keep status bar icons light on dark backgrounds
      appBarTheme: const AppBarTheme(
        backgroundColor:    RC.dark,
        foregroundColor:    RC.ivory,
        elevation:          0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness:          Brightness.dark,
          statusBarIconBrightness:      Brightness.light,
          systemNavigationBarColor:     RC.dark,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: RC.darkRaised,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RC.radiusSmall),
          borderSide:   const BorderSide(color: RC.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RC.radiusSmall),
          borderSide:   const BorderSide(color: RC.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RC.radiusSmall),
          borderSide:   const BorderSide(color: RC.amber, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RC.radiusSmall),
          borderSide:   const BorderSide(color: Color(0xFFCF6679)),
        ),
        labelStyle: const TextStyle(color: RC.ivoryDim, fontSize: 14),
        hintStyle:  const TextStyle(color: RC.ivoryDim, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: RC.amber,
          foregroundColor: RC.dark,
          minimumSize:     const Size(double.infinity, 52),
          elevation:       0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          textStyle: const TextStyle(
            fontSize:      12,
            letterSpacing: 3.0,
            fontWeight:    FontWeight.w500,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: RC.ivoryDim,
          textStyle: const TextStyle(
            fontSize:      12,
            letterSpacing: 1.5,
            fontWeight:    FontWeight.w300,
          ),
        ),
      ),

      dividerTheme: const DividerThemeData(color: RC.border, thickness: 1),
      iconTheme:    const IconThemeData(color: RC.ivoryDim),
    );
  }

  // Alias so existing references compile without change
  static ThemeData get lightTheme => darkTheme;
}
