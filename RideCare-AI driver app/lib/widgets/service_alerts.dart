import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ServiceAlerts extends StatelessWidget {
  final String vehicleId;
  const ServiceAlerts({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('vehicles')
          .doc(vehicleId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.indigo),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildEmptyState();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final score = (data['score'] ?? 100).toDouble();
        final issues = List<String>.from(data['issues'] ?? []);
        final state = data['state'] ?? 'Healthy';
        final temperature = (data['temperature'] ?? 75).toDouble();
        final voltage = (data['voltage'] ?? 12.6).toDouble();
        final mileage = (data['mileageSinceService'] ?? 2000).toDouble();

        // Generate alerts based on data
        final alerts = _generateAlerts(
          score: score,
          state: state,
          issues: issues,
          temperature: temperature,
          voltage: voltage,
          mileage: mileage,
        );

        if (alerts.isEmpty) {
          return _buildAllClearState(score);
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: alerts.length + 1, // +1 for the header card
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildAlertSummary(alerts, score, state);
            }
            return _buildAlertCard(alerts[index - 1]);
          },
        );
      },
    );
  }

  List<_AlertData> _generateAlerts({
    required double score,
    required String state,
    required List<String> issues,
    required double temperature,
    required double voltage,
    required double mileage,
  }) {
    List<_AlertData> alerts = [];

    if (temperature > 105) {
      alerts.add(
        _AlertData(
          title: 'Critical Overheating',
          message:
              'Engine temperature at ${temperature.toStringAsFixed(1)}°C — exceeds safe limit of 105°C. Stop driving and let the engine cool down immediately.',
          severity: _AlertSeverity.critical,
          icon: Icons.thermostat_rounded,
          action: 'Visit nearest service center',
        ),
      );
    } else if (temperature > 95) {
      alerts.add(
        _AlertData(
          title: 'Engine Running Hot',
          message:
              'Temperature at ${temperature.toStringAsFixed(1)}°C — approaching danger zone. Monitor closely.',
          severity: _AlertSeverity.warning,
          icon: Icons.thermostat_rounded,
          action: 'Reduce speed and avoid heavy loads',
        ),
      );
    }

    if (voltage < 11.5) {
      alerts.add(
        _AlertData(
          title: 'Battery Critically Low',
          message:
              'Battery voltage at ${voltage.toStringAsFixed(2)}V — vehicle may fail to start. Replace battery immediately.',
          severity: _AlertSeverity.critical,
          icon: Icons.battery_alert_rounded,
          action: 'Replace battery',
        ),
      );
    } else if (voltage < 12.0) {
      alerts.add(
        _AlertData(
          title: 'Battery Weak',
          message:
              'Voltage at ${voltage.toStringAsFixed(2)}V — below optimal 12.2V. Battery may need charging or replacement soon.',
          severity: _AlertSeverity.warning,
          icon: Icons.battery_charging_full_rounded,
          action: 'Get battery tested',
        ),
      );
    }

    if (mileage > 8000) {
      alerts.add(
        _AlertData(
          title: 'Service Overdue',
          message:
              '${mileage.round()} km since last service — exceeds recommended 5000 km interval. Schedule service immediately.',
          severity: _AlertSeverity.critical,
          icon: Icons.build_circle_rounded,
          action: 'Book service appointment',
        ),
      );
    } else if (mileage > 5000) {
      alerts.add(
        _AlertData(
          title: 'Service Due Soon',
          message:
              '${mileage.round()} km since last service — approaching service interval.',
          severity: _AlertSeverity.warning,
          icon: Icons.build_circle_outlined,
          action: 'Plan your next service visit',
        ),
      );
    }

    // Add issue-based alerts that aren't already covered
    for (final issue in issues) {
      if (issue.contains('Knocking') || issue.contains('Vibration')) {
        alerts.add(
          _AlertData(
            title: issue,
            message:
                'Abnormal engine vibration detected. This may indicate worn bearings or misalignment.',
            severity: issue.contains('Severe')
                ? _AlertSeverity.critical
                : _AlertSeverity.warning,
            icon: Icons.vibration_rounded,
            action: 'Get engine inspected',
          ),
        );
      }
      if (issue.contains('Fuel')) {
        alerts.add(
          _AlertData(
            title: issue,
            message:
                'Fuel efficiency has dropped significantly. May indicate clogged filters or engine issues.',
            severity: issue.contains('Poor')
                ? _AlertSeverity.critical
                : _AlertSeverity.warning,
            icon: Icons.local_gas_station_rounded,
            action: 'Check fuel system',
          ),
        );
      }
    }

    return alerts;
  }

  Widget _buildAlertSummary(
    List<_AlertData> alerts,
    double score,
    String state,
  ) {
    final criticalCount = alerts
        .where((a) => a.severity == _AlertSeverity.critical)
        .length;
    final warningCount = alerts
        .where((a) => a.severity == _AlertSeverity.warning)
        .length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: criticalCount > 0
              ? AppColors.rose.withOpacity(0.3)
              : AppColors.amber.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (criticalCount > 0 ? AppColors.rose : AppColors.amber)
                  .withOpacity(0.12),
            ),
            child: Center(
              child: Icon(
                Icons.notifications_active_rounded,
                color: criticalCount > 0 ? AppColors.rose : AppColors.amber,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${alerts.length} Active Alert${alerts.length > 1 ? 's' : ''}',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (criticalCount > 0) ...[
                      _buildCountBadge(
                        criticalCount,
                        'Critical',
                        AppColors.rose,
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (warningCount > 0)
                      _buildCountBadge(
                        warningCount,
                        'Warning',
                        AppColors.amber,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountBadge(int count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        '$count $label',
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildAlertCard(_AlertData alert) {
    final isCritical = alert.severity == _AlertSeverity.critical;
    final color = isCritical ? AppColors.rose : AppColors.amber;
    final bgColor = isCritical
        ? const Color(0xFF3B1219)
        : const Color(0xFF362712);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(alert.icon, color: color, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  alert.title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: color.withOpacity(0.25)),
                ),
                child: Text(
                  isCritical ? 'CRITICAL' : 'WARNING',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            alert.message,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: color.withOpacity(0.7),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  alert.action,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: AppColors.textMuted.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No vehicle data found',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllClearState(double score) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.emerald.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 44,
                color: AppColors.emerald,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'All Clear!',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.emerald,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your vehicle is in great shape.\nHealth score: ${score.round()}/100',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _AlertSeverity { critical, warning }

class _AlertData {
  final String title;
  final String message;
  final _AlertSeverity severity;
  final IconData icon;
  final String action;

  _AlertData({
    required this.title,
    required this.message,
    required this.severity,
    required this.icon,
    required this.action,
  });
}
