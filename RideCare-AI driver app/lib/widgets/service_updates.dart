import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ServiceUpdates extends StatefulWidget {
  final String vehicleId;
  const ServiceUpdates({super.key, required this.vehicleId});

  @override
  State<ServiceUpdates> createState() => _ServiceUpdatesState();
}

class _ServiceUpdatesState extends State<ServiceUpdates> {
  String _selectedServiceType = 'Oil Change';
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  final _serviceTypes = [
    'Oil Change',
    'Brake Service',
    'Battery Replace',
    'Tire Rotation',
    'Engine Tune-up',
    'General Service',
  ];

  final _serviceIcons = {
    'Oil Change': Icons.water_drop_rounded,
    'Brake Service': Icons.disc_full_rounded,
    'Battery Replace': Icons.battery_charging_full_rounded,
    'Tire Rotation': Icons.tire_repair_rounded,
    'Engine Tune-up': Icons.settings_rounded,
    'General Service': Icons.build_circle_rounded,
  };

  Future<void> _submitUpdate() async {
    setState(() => _isSubmitting = true);
    try {
      await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(widget.vehicleId)
          .collection('service_updates')
          .add({
            'type': _selectedServiceType,
            'notes': _notesController.text.trim(),
            'timestamp': FieldValue.serverTimestamp(),
            'createdAt': DateTime.now().millisecondsSinceEpoch,
          });

      // 1. Prepare updates based on service type
      final Map<String, dynamic> updates = {
        'mileageSinceService': 0,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
        'state': 'online', // Assume logging a service makes it ready for duty
      };

      switch (_selectedServiceType) {
        case 'Oil Change':
          // Oil pressure not yet in sliders, but we can set it for future use
          updates['oilPressure'] = 40.0;
          break;
        case 'Battery Replace':
          updates['voltage'] = 12.6;
          break;
        case 'Tire Rotation':
          // Tire pressure not yet in sliders, but we can set it
          updates['tirePressure'] = 32.0;
          break;
        case 'Engine Tune-up':
          updates['temperature'] = 90.0;
          updates['vibration'] = 10.0; // Reset to a healthy baseline
          break;
        case 'Brake Service':
          // Could improve safety/score
          break;
        case 'General Service':
          // Full reset of all known sliders
          updates['temperature'] = 90.0;
          updates['vibration'] = 10.0;
          updates['voltage'] = 12.6;
          updates['fuelEfficiency'] = 18.0;
          updates['score'] = 100.0;
          break;
      }

      // If not a full reset, just bump the overall score significantly
      if (_selectedServiceType != 'General Service') {
        // We'll reset the score to 100 for any specific service too,
        // as it usually addresses the main issue.
        updates['score'] = 100.0;
      }

      // 2. Apply updates to Firestore
      await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(widget.vehicleId)
          .update(updates);

      _notesController.clear();

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
                  'Service update logged!',
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
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        // ─── Log New Service ────────────────────────────
        _buildSectionHeader(
          'Log New Service',
          Icons.add_circle_outline_rounded,
        ),
        const SizedBox(height: 12),
        _buildServiceForm(),
        const SizedBox(height: 28),

        // ─── Service History ────────────────────────────
        _buildSectionHeader('Service History', Icons.history_rounded),
        const SizedBox(height: 12),
        _buildServiceHistory(),
      ],
    );
  }

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

  Widget _buildServiceForm() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Service Type',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Service type dropdown
          DropdownButtonFormField<String>(
            value: _selectedServiceType,
            dropdownColor: AppColors.surface,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textMuted,
            ),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            items: _serviceTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Row(
                  children: [
                    Icon(
                      _serviceIcons[type] ?? Icons.build,
                      size: 18,
                      color: AppColors.indigoLight,
                    ),
                    const SizedBox(width: 12),
                    Text(type),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedServiceType = value);
              }
            },
          ),
          const SizedBox(height: 18),

          // Notes field
          Text(
            'Notes (optional)',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 3,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'e.g., Replaced with synthetic oil...',
              hintStyle: GoogleFonts.inter(
                color: AppColors.textMuted.withOpacity(0.5),
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitUpdate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emeraldDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
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
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Log Service Update',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('vehicles')
          .doc(widget.vehicleId)
          .collection('service_updates')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: AppColors.indigo),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 40,
                  color: AppColors.textMuted.withOpacity(0.4),
                ),
                const SizedBox(height: 12),
                Text(
                  'No service history yet',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Service records will appear here',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textMuted.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final type = data['type'] ?? 'General Service';
            final notes = data['notes'] ?? '';
            final createdAt = data['createdAt'] as int?;
            final date = createdAt != null
                ? DateTime.fromMillisecondsSinceEpoch(createdAt)
                : DateTime.now();

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _serviceIcons[type] ?? Icons.build_circle_rounded,
                      color: AppColors.emerald,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (notes.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            notes,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          _formatDate(date),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Done',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.emerald,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${date.day}/${date.month}/${date.year}';
  }
}
