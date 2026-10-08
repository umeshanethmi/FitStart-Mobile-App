import 'package:flutter/material.dart';

class WorkoutPage extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? bottomBar;
  final PreferredSizeWidget? appBar;
  final bool planningStyle;

  const WorkoutPage({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.bottomBar,
    this.appBar,
    this.planningStyle = false,
  });

  static const ink = Color(0xFF202925);
  static const green = Color(0xFF15765A);
  static const muted = Color(0xFF65716B);
  static const line = Color(0xFFDCE4DF);
  static const blue = Color(0xFF2563EB);
  static const planningLine = Color(0xFFE2E8F0);
  static const amber = Color(0xFFB45309);

  static ThemeData theme(BuildContext context, {bool planningStyle = false}) {
    final base = Theme.of(context);
    final primary = planningStyle ? blue : green;
    final foreground = planningStyle ? const Color(0xFF0F172A) : ink;
    final border = planningStyle ? planningLine : line;
    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    );
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: planningStyle ? amber : const Color(0xFFB94E3A),
        surface: Colors.white,
        onSurface: foreground,
      ),
      scaffoldBackgroundColor: planningStyle
          ? const Color(0xFFF6F8FD)
          : const Color(0xFFF5F8F6),
      textTheme: base.textTheme.apply(
        bodyColor: foreground,
        displayColor: foreground,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: foreground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: foreground,
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        labelStyle: TextStyle(color: muted, fontSize: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 50),
          shape: shape,
          textStyle: base.textTheme.labelLarge?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          side: BorderSide(color: border),
          shape: shape,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: shape,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: foreground,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: theme(context, planningStyle: planningStyle),
    child: Scaffold(
      appBar: appBar ?? AppBar(title: Text(title), actions: actions),
      body: body,
      bottomNavigationBar: bottomBar,
    ),
  );
}

class WorkoutSectionHeading extends StatelessWidget {
  final String title;
  final IconData icon;
  const WorkoutSectionHeading(this.title, {super.key, required this.icon});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 20),
    child: Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}
