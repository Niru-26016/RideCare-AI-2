import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/vehicle_condition_editor.dart';
import '../widgets/service_alerts.dart';
import '../widgets/service_updates.dart';
import '../widgets/vehicle_map.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedVehicleId;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: _selectedIndex == 0,
      backgroundColor: AppColors.bg,
      body: _buildBodyContent(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBodyContent() {
    if (_selectedVehicleId == null) {
      return Stack(
        children: [
          _buildMapSection(),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(child: _buildFloatingHeader()),
          ),
          Positioned.fill(
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.indigo.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.directions_car_rounded,
                        size: 32,
                        color: AppColors.indigo.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Select a Vehicle',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose a vehicle from the dropdown\nabove to view its status',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textMuted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (_selectedIndex == 0) {
      // Home / Map View
      return Stack(
        children: [
          _buildMapSection(),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(child: _buildFloatingHeader()),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: _buildGoOnlineButton(),
          ),
        ],
      );
    }

    // Other Tabs
    return SafeArea(
      child: Column(
        children: [
          _buildFloatingHeader(),
          Expanded(child: _getSelectedTabView()),
        ],
      ),
    );
  }

  Widget _getSelectedTabView() {
    switch (_selectedIndex) {
      case 1:
        return VehicleConditionEditor(vehicleId: _selectedVehicleId!);
      case 2:
        return ServiceAlerts(vehicleId: _selectedVehicleId!);
      case 3:
        return ServiceUpdates(vehicleId: _selectedVehicleId!);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: BottomNavigationBar(
        backgroundColor: AppColors.surface,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.indigoLight,
        unselectedItemColor: AppColors.textMuted,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.build_circle_outlined),
            label: 'Condition',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber_rounded),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build_rounded),
            label: 'Services',
          ),
        ],
      ),
    );
  }

  // ─── Map Section (Background) ────────────────────────────────────────────
  Widget _buildMapSection() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('vehicles')
          .doc(
            _selectedVehicleId ?? 'dummy',
          ) // Provide dummy id if null to still show map
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final score = (data?['score'] ?? 100).toDouble();
        final isCritical = score < 80;

        return VehicleMapWidget(
          vehicleId: _selectedVehicleId,
          vehicleData: data,
          showServiceCenters: isCritical && _selectedIndex == 0,
        );
      },
    );
  }

  // ─── Floating Header ──────────────────────────────────────────────────
  Widget _buildFloatingHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Brand row
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: AppColors.indigoGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.indigo.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.shield, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'RideCare',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.indigo.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'DRIVER',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.indigoLight,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Vehicle Health & Service Manager',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Status dot
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _selectedVehicleId != null
                            ? AppColors.emerald
                            : AppColors.textMuted,
                        shape: BoxShape.circle,
                        boxShadow: _selectedVehicleId != null
                            ? [
                                BoxShadow(
                                  color: AppColors.emerald.withOpacity(0.5),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _selectedVehicleId != null ? 'Online' : 'Offline',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Vehicle selector
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('vehicles')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.indigo,
                      ),
                    ),
                  ),
                );
              }

              final vehicles = snapshot.data!.docs;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedVehicleId,
                    hint: Row(
                      children: [
                        Icon(
                          Icons.directions_car_rounded,
                          color: AppColors.textMuted,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Select Your Vehicle...',
                          style: GoogleFonts.inter(
                            color: AppColors.textMuted,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    dropdownColor: AppColors.surface,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textMuted,
                    ),
                    items: vehicles.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final info = data['info'] as Map<String, dynamic>?;
                      return DropdownMenuItem<String>(
                        value: doc.id,
                        child: Row(
                          children: [
                            Icon(
                              _getVehicleIcon(info?['type'] ?? ''),
                              color: AppColors.indigoLight,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                '${info?['driver'] ?? 'Unknown'} — ${doc.id}',
                                style: GoogleFonts.inter(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              info?['model'] ?? '',
                              style: GoogleFonts.inter(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedVehicleId = value;
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _getVehicleIcon(String type) {
    switch (type.toLowerCase()) {
      case 'car':
        return Icons.directions_car_rounded;
      case 'bike':
        return Icons.two_wheeler_rounded;
      case 'auto':
        return Icons.electric_rickshaw_rounded;
      default:
        return Icons.directions_car_rounded;
    }
  }

  // ─── Go Online Button ──────────────────────────────────────────────────
  Widget _buildGoOnlineButton() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('vehicles')
          .doc(_selectedVehicleId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final score = (data?['score'] ?? 100).toDouble();
        final state = data?['state'] ?? 'offline'; // 'offline' or 'online'
        final isGoodCondition = score >= 80;
        final isOnline = state == 'online';

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isGoodCondition
                  ? (isOnline ? AppColors.emerald : Colors.orange.shade600)
                  : Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              shadowColor:
                  (isGoodCondition ? Colors.orange : Colors.red.shade600)
                      .withValues(alpha: 0.4),
            ),
            onPressed: isGoodCondition
                ? () {
                    // Toggle online state
                    FirebaseFirestore.instance
                        .collection('vehicles')
                        .doc(_selectedVehicleId)
                        .update({'state': isOnline ? 'offline' : 'online'});
                  }
                : () {
                    // Optionally show a snackbar explaining why they can't go online
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Cannot go online. Vehicle requires service.',
                        ),
                        backgroundColor: Colors.red.shade600,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isGoodCondition
                      ? (isOnline
                            ? Icons.stop_rounded
                            : Icons.play_arrow_rounded)
                      : Icons.warning_rounded,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    isGoodCondition
                        ? (isOnline ? 'GO OFFLINE' : 'GO ONLINE')
                        : 'SERVICE REQUIRED',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
