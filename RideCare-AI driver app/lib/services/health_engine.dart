/// Mirrors the health scoring logic from the web admin dashboard.
class HealthResult {
  final double score;
  final String state;
  final List<String> issues;

  HealthResult({
    required this.score,
    required this.state,
    required this.issues,
  });
}

HealthResult evaluateHealth({
  required double temperature,
  required double voltage,
  required double mileageSinceService,
  required double vibration,
  required double fuelEfficiency,
  required double baseVib,
  required double baseFuel,
}) {
  double score = 100;
  List<String> issues = [];

  // 1. Engine Temperature (Normal: 60-90°C)
  if (temperature > 105) {
    score -= 25;
    issues.add('Critical Overheating');
  } else if (temperature > 95) {
    score -= 10;
    issues.add('Running Hot');
  }

  // 2. Battery Voltage (Normal > 12.2V)
  if (voltage < 11.5) {
    score -= 30;
    issues.add('Battery Critically Low');
  } else if (voltage < 12.0) {
    score -= 15;
    issues.add('Battery Weak');
  }

  // 3. Servicing (Normal < 5000km since last)
  if (mileageSinceService > 8000) {
    score -= 20;
    issues.add('Service Overdue');
  } else if (mileageSinceService > 5000) {
    score -= 10;
    issues.add('Service Due Soon');
  }

  // 4. Vibration / Engine knocking
  final vibrationDiff = vibration - baseVib;
  if (vibrationDiff > 25) {
    score -= 20;
    issues.add('Severe Engine Knocking');
  } else if (vibrationDiff > 10) {
    score -= 10;
    issues.add('Abnormal Vibration');
  }

  // 5. Fuel Efficiency
  final fuelDiff = baseFuel - fuelEfficiency;
  if (fuelDiff > 8) {
    score -= 15;
    issues.add('Poor Fuel Economy');
  } else if (fuelDiff > 4) {
    score -= 5;
    issues.add('Efficiency Dropping');
  }

  // Clamp
  score = score.clamp(0, 100);

  // State
  String state = 'Healthy';
  if (score < 40) {
    state = 'Critical';
  } else if (score < 60) {
    state = 'Service Soon';
  } else if (score < 80) {
    state = 'Attention Needed';
  }

  return HealthResult(score: score, state: state, issues: issues);
}
