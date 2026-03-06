import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/health_engine.dart';

class VehicleConditionEditor extends StatefulWidget {
  final String vehicleId;
  const VehicleConditionEditor({super.key, required this.vehicleId});

  @override
  State<VehicleConditionEditor> createState() => _VehicleConditionEditorState();
}

class _VehicleConditionEditorState extends State<VehicleConditionEditor> {
  double _temperature = 75;
  double _voltage = 12.6;
  double _mileageSinceService = 2000;
  double _vibration = 12;
  double _fuelEfficiency = 18;
  double _baseVib = 10;
  double _baseFuel = 18;

  bool _isUpdating = false;
  bool _loaded = false;
  HealthResult? _healthResult;

  @override
  void didUpdateWidget(VehicleConditionEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vehicleId != widget.vehicleId) {
      _loaded = false;
    }
  }

  void _recalcHealth() {
    _healthResult = evaluateHealth(
      temperature: _temperature,
      voltage: _voltage,
      mileageSinceService: _mileageSinceService,
      vibration: _vibration,
      fuelEfficiency: _fuelEfficiency,
      baseVib: _baseVib,
      baseFuel: _baseFuel,
    );
  }

  Future<void> _updateCondition() async {
    setState(() => _isUpdating = true);
    try {
      _recalcHealth();
      await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(widget.vehicleId)
          .set({
            'temperature': _temperature,
            'voltage': _voltage,
            'mileageSinceService': _mileageSinceService,
            'vibration': _vibration,
            'fuelEfficiency': _fuelEfficiency,
            'baseVib': _baseVib,
            'baseFuel': _baseFuel,
            'score': _healthResult!.score,
            'state': _healthResult!.state,
            'issues': _healthResult!.issues,
            'lastUpdated': DateTime.now().millisecondsSinceEpoch,
          }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.emerald,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  'Vehicle condition updated!',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: AppColors.surface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.roseDark,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('vehicles')
          .doc(widget.vehicleId)
          .snapshots(),
      builder: (context, snapshot) {
        // Load initial values from Firestore once
        if (snapshot.hasData && snapshot.data!.exists && !_loaded) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          _temperature = (data['temperature'] ?? 75).toDouble();
          _voltage = (data['voltage'] ?? 12.6).toDouble();
          _mileageSinceService = (data['mileageSinceService'] ?? 2000)
              .toDouble();
          _vibration = (data['vibration'] ?? 12).toDouble();
          _fuelEfficiency = (data['fuelEfficiency'] ?? 18).toDouble();
          _baseVib = (data['baseVib'] ?? 10).toDouble();
          _baseFuel = (data['baseFuel'] ?? 18).toDouble();
          _loaded = true;
        }

        _recalcHealth();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            // Health Score Card
            _buildHealthCard(),
            const SizedBox(height: 20),
            // Telemetry Sliders
            _buildSectionHeader('Vehicle Telemetry', Icons.speed_rounded),
            const SizedBox(height: 12),
            _buildSlider(
              label: 'Engine Temperature',
              value: _temperature,
              min: 30,
              max: 130,
              unit: '°C',
              icon: Icons.thermostat_rounded,
              warningThreshold: 95,
              criticalThreshold: 105,
              onChanged: (v) => setState(() {
                _temperature = v;
                _recalcHealth();
              }),
            ),
            _buildSlider(
              label: 'Battery Voltage',
              value: _voltage,
              min: 10,
              max: 14,
              unit: 'V',
              icon: Icons.battery_charging_full_rounded,
              warningThreshold: 12.0,
              criticalThreshold: 11.5,
              invertWarning: true,
              onChanged: (v) => setState(() {
                _voltage = v;
                _recalcHealth();
              }),
            ),
            _buildSlider(
              label: 'Mileage Since Service',
              value: _mileageSinceService,
              min: 0,
              max: 15000,
              unit: 'km',
              icon: Icons.route_rounded,
              warningThreshold: 5000,
              criticalThreshold: 8000,
              onChanged: (v) => setState(() {
                _mileageSinceService = v;
                _recalcHealth();
              }),
            ),
            _buildSlider(
              label: 'Vibration Level',
              value: _vibration,
              min: 0,
              max: 60,
              unit: 'hz',
              icon: Icons.vibration_rounded,
              warningThreshold: _baseVib + 10,
              criticalThreshold: _baseVib + 25,
              onChanged: (v) => setState(() {
                _vibration = v;
                _recalcHealth();
              }),
            ),
            _buildSlider(
              label: 'Fuel Efficiency',
              value: _fuelEfficiency,
              min: 0,
              max: 50,
              unit: 'km/l',
              icon: Icons.local_gas_station_rounded,
              warningThreshold: _baseFuel - 4,
              criticalThreshold: _baseFuel - 8,
              invertWarning: true,
              onChanged: (v) => setState(() {
                _fuelEfficiency = v;
                _recalcHealth();
              }),
            ),
            const SizedBox(height: 24),
            // Submit button
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isUpdating ? null : _updateCondition,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isUpdating
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_upload_rounded, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Update Condition',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ─── Health Score Card ──────────────────────────────────────
  Widget _buildHealthCard() {
    final score = _healthResult?.score ?? 100;
    final state = _healthResult?.state ?? 'Healthy';
    final issues = _healthResult?.issues ?? [];

    Color statusColor;
    IconData statusIcon;
    if (score >= 80) {
      statusColor = AppColors.emerald;
      statusIcon = Icons.check_circle_rounded;
    } else if (score >= 60) {
      statusColor = AppColors.amber;
      statusIcon = Icons.warning_amber_rounded;
    } else {
      statusColor = AppColors.rose;
      statusIcon = Icons.error_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Score circle
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      statusColor.withOpacity(0.2),
                      statusColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: statusColor.withOpacity(0.4),
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${score.round()}',
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health Score',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(statusIcon, color: statusColor, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          state,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (issues.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withOpacity(0.15)),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: issues
                    .map(
                      (issue) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: statusColor.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          issue,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Section Header ─────────────────────────────────────────
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.indigoLight, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ─── Slider Widget ──────────────────────────────────────────
  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String unit,
    required IconData icon,
    required double warningThreshold,
    required double criticalThreshold,
    bool invertWarning = false,
    required ValueChanged<double> onChanged,
  }) {
    bool isWarning;
    bool isCritical;

    if (invertWarning) {
      isWarning = value < warningThreshold;
      isCritical = value < criticalThreshold;
    } else {
      isWarning = value > warningThreshold;
      isCritical = value > criticalThreshold;
    }

    final activeColor = isCritical
        ? AppColors.rose
        : isWarning
        ? AppColors.amber
        : AppColors.indigo;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCritical
              ? AppColors.rose.withOpacity(0.3)
              : isWarning
              ? AppColors.amber.withOpacity(0.2)
              : AppColors.border,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: activeColor, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: activeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${value.toStringAsFixed(unit == 'V'
                      ? 2
                      : unit == 'km'
                      ? 0
                      : 1)} $unit',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: activeColor,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: activeColor,
              inactiveTrackColor: activeColor.withOpacity(0.15),
              thumbColor: activeColor,
              overlayColor: activeColor.withOpacity(0.1),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
