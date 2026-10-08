import 'package:flutter/material.dart';

class WorkoutPage extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? bottomBar;

  const WorkoutPage({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.bottomBar,
  });

  static const ink = Color(0xFF202925);
  static const green = Color(0xFF15765A);
  static const muted = Color(0xFF65716B);
  static const line = Color(0xFFDCE4DF);

  static ThemeData theme(BuildContext context) {
    final base = Theme.of(context);
    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    );
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: green,
        primary: green,
        secondary: const Color(0xFFB94E3A),
        surface: Colors.white,
        onSurface: ink,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F8F6),
      textTheme: base.textTheme.apply(bodyColor: ink, displayColor: ink),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: ink,
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
      ),
      dividerTheme: const DividerThemeData(color: line, thickness: 1),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: green, width: 2),
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
          side: const BorderSide(color: line),
          shape: shape,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: shape,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: ink,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: theme(context),
    child: Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
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
        Icon(icon, size: 20, color: WorkoutPage.green),
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
