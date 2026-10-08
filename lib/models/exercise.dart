class Exercise {
  final String name;
  final String description;
  final String targetArea;
  final int sets;
  final int? reps;
  final int? durationSeconds;
  final int restSeconds;
  final String beginnerTip;

  const Exercise({
    required this.name,
    required this.description,
    required this.targetArea,
    required this.sets,
    this.reps,
    this.durationSeconds,
    required this.restSeconds,
    required this.beginnerTip,
  }) : assert(reps != null || durationSeconds != null);

  String get workDescription {
    if (reps != null) {
      return '$sets sets · $reps reps';
    }
    return '$sets sets · ${durationSeconds!} sec';
  }

  String get activeDescription {
    if (reps != null) {
      return '$reps repetitions';
    }
    return 'Hold for ${durationSeconds!} seconds';
  }
}
