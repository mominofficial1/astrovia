import 'package:flutter/material.dart';
import '../models/spacecraft_model.dart';
import '../rendering/spacecraft_renderer.dart';
import '../services/audio_service.dart';
import '../state/mission_state.dart';
import '../theme/astrovia_theme.dart';
import '../widgets/hud_container.dart';

class ScreenRocketBuilder extends StatefulWidget {
  const ScreenRocketBuilder({super.key});

  @override
  State<ScreenRocketBuilder> createState() => _ScreenRocketBuilderState();
}

class _ScreenRocketBuilderState extends State<ScreenRocketBuilder> {
  late SpacecraftBuild _activeBuild;
  final List<List<String>> _undoStack = [];
  ComponentCategory _selectedCategory = ComponentCategory.capsulePayload;

  @override
  void initState() {
    super.initState();
    final current = MissionState.instance.activeSpacecraft;
    _activeBuild = SpacecraftBuild(
      name: current.name,
      componentIds: List<String>.from(current.componentIds),
    );
  }

  void _pushUndo() {
    _undoStack.add(List<String>.from(_activeBuild.componentIds));
    if (_undoStack.length > 20) _undoStack.removeAt(0);
  }

  void _undo() {
    if (_undoStack.isNotEmpty) {
      AudioService.instance.playClick();
      setState(() {
        _activeBuild.componentIds = _undoStack.removeLast();
      });
    }
  }

  void _addComponent(SpacecraftComponent comp) {
    _pushUndo();
    AudioService.instance.playClick();
    setState(() {
      _activeBuild.componentIds.add(comp.id);
    });
  }

  void _removeComponent(String compId) {
    _pushUndo();
    AudioService.instance.playClick();
    setState(() {
      _activeBuild.componentIds.remove(compId);
    });
  }

  void _resetBuild() {
    _pushUndo();
    AudioService.instance.playClick();
    setState(() {
      _activeBuild.componentIds.clear();
    });
  }

  void _loadStarterBlueprint(SpacecraftBuild blueprint) {
    _pushUndo();
    AudioService.instance.playTransition();
    setState(() {
      _activeBuild = SpacecraftBuild(
        name: blueprint.name,
        componentIds: List<String>.from(blueprint.componentIds),
      );
    });
  }

  void _saveBuild() {
    AudioService.instance.playSuccess();
    MissionState.instance.saveSpacecraftBuild(_activeBuild);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AstroviaTheme.panel,
        content: Text(
          "SPACECRAFT BLUEPRINT '${_activeBuild.name}' SAVED TO HANGAR VAULT.",
          style: AstroviaTheme.orbitron(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AstroviaTheme.cyan,
          ),
        ),
      ),
    );
  }

  void _runPreflightValidation() {
    AudioService.instance.playClick();
    final activeMissionLevel =
        MissionState.instance.currentMission?.levelNumber ??
            MissionState.instance.saveData.unlockedCampaignLevel;
    final errors = _activeBuild.validateForMission(activeMissionLevel);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AstroviaTheme.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: errors.isEmpty ? AstroviaTheme.green : AstroviaTheme.red,
            width: 1.5,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(22),
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    errors.isEmpty
                        ? Icons.check_circle_rounded
                        : Icons.warning_amber_rounded,
                    color: errors.isEmpty
                        ? AstroviaTheme.green
                        : AstroviaTheme.red,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    errors.isEmpty
                        ? "PREFLIGHT VALIDATION PASSED"
                        : "PREFLIGHT VALIDATION FAILED",
                    style: AstroviaTheme.orbitron(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: errors.isEmpty
                          ? AstroviaTheme.green
                          : AstroviaTheme.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                errors.isEmpty
                    ? "Spacecraft vehicle structure is aerodynamically and propulsion-wise certified for Level $activeMissionLevel launch directives."
                    : "The following flight integrity diagnostics must be resolved before ignition:",
                style: AstroviaTheme.rajdhani(
                  fontSize: 13,
                  color: AstroviaTheme.white,
                ),
              ),
              const SizedBox(height: 12),
              if (errors.isNotEmpty)
                Column(
                  children: errors
                      .map((err) => Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("• ",
                                    style: TextStyle(
                                        color: AstroviaTheme.red,
                                        fontSize: 16)),
                                Expanded(
                                  child: Text(
                                    err,
                                    style: AstroviaTheme.inter(
                                      fontSize: 12,
                                      color: AstroviaTheme.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AstroviaTheme.cyan.withValues(alpha: 0.3),
                    side: const BorderSide(color: AstroviaTheme.cyan),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "ACKNOWLEDGE",
                    style: AstroviaTheme.orbitron(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AstroviaTheme.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalog = SpacecraftComponent.catalog;
    final filtered =
        catalog.where((c) => c.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: AstroviaTheme.darkSpace,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: AstroviaTheme.cyan),
                    onPressed: () {
                      AudioService.instance.playClick();
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    "AEROSPACE SPACECRAFT ASSEMBLY HANGAR",
                    style: AstroviaTheme.orbitron(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AstroviaTheme.white,
                      letterSpacing: 2.0,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        tooltip: "Undo",
                        icon: const Icon(Icons.undo_rounded,
                            color: AstroviaTheme.cyan),
                        onPressed: _undoStack.isNotEmpty ? _undo : null,
                      ),
                      IconButton(
                        tooltip: "Reset Build",
                        icon: const Icon(Icons.refresh_rounded,
                            color: AstroviaTheme.secondary),
                        onPressed: _resetBuild,
                      ),
                      IconButton(
                        tooltip: "Save Spacecraft",
                        icon: const Icon(Icons.save_rounded,
                            color: AstroviaTheme.gold),
                        onPressed: _saveBuild,
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AstroviaTheme.cyan.withValues(alpha: 0.25),
                          side: const BorderSide(color: AstroviaTheme.cyan),
                        ),
                        icon: const Icon(Icons.fact_check_rounded,
                            size: 16, color: AstroviaTheme.cyan),
                        label: Text(
                          "PREFLIGHT CHECK",
                          style: AstroviaTheme.orbitron(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AstroviaTheme.white,
                          ),
                        ),
                        onPressed: _runPreflightValidation,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Main 3-Column Hangar Layout:
              // Left: Component Categories & Catalog
              // Center: Visual Vehicle Assembly Stage
              // Right: Flight Telemetry & Statistics
              Expanded(
                child: Row(
                  children: [
                    // Left Column: Catalog & Categories
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          // Category Selector Chips
                          SizedBox(
                            height: 38,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _buildCategoryChip(
                                    "CAPSULES", ComponentCategory.capsulePayload),
                                _buildCategoryChip(
                                    "TANKS", ComponentCategory.propellantTank),
                                _buildCategoryChip(
                                    "ENGINES", ComponentCategory.mainEngine),
                                _buildCategoryChip(
                                    "BOOSTERS", ComponentCategory.booster),
                                _buildCategoryChip(
                                    "STAGING", ComponentCategory.separator),
                                _buildCategoryChip(
                                    "POWER/SOLAR", ComponentCategory.solarArray),
                                _buildCategoryChip(
                                    "AVIONICS", ComponentCategory.avionics),
                                _buildCategoryChip(
                                    "LANDING/DOCK", ComponentCategory.landingLegs),
                                _buildCategoryChip(
                                    "HEAT SHIELD", ComponentCategory.thermalHeatShield),
                                _buildCategoryChip(
                                    "SCIENCE", ComponentCategory.scienceInstrument),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Component Cards List
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AstroviaTheme.panelTranslucent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: AstroviaTheme.cyan
                                        .withValues(alpha: 0.3)),
                              ),
                              child: ListView.separated(
                                padding: const EdgeInsets.all(8),
                                itemCount: filtered.length,
                                separatorBuilder: (ctx, i) =>
                                    const SizedBox(height: 6),
                                itemBuilder: (ctx, i) {
                                  final comp = filtered[i];
                                  final isAttached = _activeBuild.componentIds
                                      .contains(comp.id);
                                  return InkWell(
                                    onTap: () => _addComponent(comp),
                                    borderRadius: BorderRadius.circular(6),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isAttached
                                            ? AstroviaTheme.cyan
                                                .withValues(alpha: 0.15)
                                            : AstroviaTheme.darkSpace,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isAttached
                                              ? AstroviaTheme.cyan
                                              : AstroviaTheme.cyan
                                                  .withValues(alpha: 0.25),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: comp.baseColor,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  comp.name,
                                                  style: AstroviaTheme.rajdhani(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: AstroviaTheme.white,
                                                  ),
                                                ),
                                                Text(
                                                  "${comp.massKg.toInt()} kg • Stage ${comp.stage}",
                                                  style: AstroviaTheme.inter(
                                                    fontSize: 10,
                                                    color:
                                                        AstroviaTheme.secondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              isAttached
                                                  ? Icons.check_circle_rounded
                                                  : Icons.add_circle_outline_rounded,
                                              color: isAttached
                                                  ? AstroviaTheme.green
                                                  : AstroviaTheme.cyan,
                                              size: 20,
                                            ),
                                            onPressed: () => _addComponent(comp),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          // Starter Blueprints Quick Bar
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                "BLUEPRINTS: ",
                                style: AstroviaTheme.orbitron(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AstroviaTheme.gold,
                                ),
                              ),
                              _buildBlueprintButton("APOLLO",
                                  SpacecraftBuild.starterApollo),
                              const SizedBox(width: 4),
                              _buildBlueprintButton("LANDER",
                                  SpacecraftBuild.starterLunarLander),
                              const SizedBox(width: 4),
                              _buildBlueprintButton("PROBE",
                                  SpacecraftBuild.starterRoboticProbe),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Center Column: Interactive Assembled Spacecraft Stage
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AstroviaTheme.panelTranslucent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AstroviaTheme.cyan.withValues(alpha: 0.4),
                            width: 1.2,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Background Blueprint Grid
                            CustomPaint(
                              size: Size.infinite,
                              painter: BlueprintGridPainter(),
                            ),

                            // Actual Assembled Vehicle
                            Center(
                              child: SpacecraftWidget(
                                buildData: _activeBuild,
                                scale: 1.15,
                                landingLegsExtended: true,
                                solarPanelsDeployed: true,
                              ),
                            ),

                            // Top Info Tag
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AstroviaTheme.panelGlass,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                      color: AstroviaTheme.cyan
                                          .withValues(alpha: 0.5)),
                                ),
                                child: Text(
                                  "${_activeBuild.name.toUpperCase()} [${_activeBuild.componentIds.length} PARTS]",
                                  style: AstroviaTheme.orbitron(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AstroviaTheme.cyan,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Right Column: Telemetry & Installed Components List
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          // Statistics Cards
                          HudContainer(
                            isSelected: true,
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "VEHICLE MASS & PROPULSION SPECS",
                                  style: AstroviaTheme.orbitron(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AstroviaTheme.cyan,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _buildStatRow(
                                    "TOTAL MASS",
                                    "${_activeBuild.totalMassKg.toInt()} kg",
                                    Icons.fitness_center_rounded),
                                _buildStatRow(
                                    "TOTAL PROPELLANT",
                                    "${_activeBuild.totalFuelKg.toInt()} kg",
                                    Icons.local_gas_station_rounded),
                                _buildStatRow(
                                    "LIFTOFF THRUST",
                                    "${_activeBuild.totalLiftoffThrustKn.toStringAsFixed(0)} kN",
                                    Icons.speed_rounded),
                                _buildStatRow(
                                    "EARTH TWR",
                                    _activeBuild.twrEarth.toStringAsFixed(2),
                                    Icons.trending_up_rounded,
                                    isWarning: _activeBuild.twrEarth < 1.0),
                                _buildStatRow(
                                    "NET POWER BALANCE",
                                    "${_activeBuild.netPowerWatts.toStringAsFixed(0)} W",
                                    Icons.bolt_rounded),
                                _buildStatRow(
                                    "LIFE SUPPORT",
                                    "${_activeBuild.maxLifeSupportHours.toStringAsFixed(0)} h",
                                    Icons.favorite_rounded),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Active Attached Components list with removal buttons
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AstroviaTheme.panelTranslucent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: AstroviaTheme.cyan
                                        .withValues(alpha: 0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "ATTACHED STAGING SEQUENCE",
                                    style: AstroviaTheme.orbitron(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AstroviaTheme.gold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: _activeBuild.components.length,
                                      itemBuilder: (ctx, idx) {
                                        final comp =
                                            _activeBuild.components[idx];
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 4),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "${idx + 1}. ${comp.name}",
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: AstroviaTheme.rajdhani(
                                                    fontSize: 12,
                                                    color: AstroviaTheme.white,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.remove_circle_outline_rounded,
                                                  color: AstroviaTheme.red,
                                                  size: 16,
                                                ),
                                                onPressed: () =>
                                                    _removeComponent(comp.id),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, ComponentCategory cat) {
    final isSelected = _selectedCategory == cat;
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        labelStyle: AstroviaTheme.orbitron(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isSelected ? AstroviaTheme.darkSpace : AstroviaTheme.white,
        ),
        selectedColor: AstroviaTheme.cyan,
        backgroundColor: AstroviaTheme.panelTranslucent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(
              color: isSelected ? AstroviaTheme.cyan : Colors.transparent),
        ),
        onSelected: (_) {
          AudioService.instance.playClick();
          setState(() => _selectedCategory = cat);
        },
      ),
    );
  }

  Widget _buildBlueprintButton(String label, SpacecraftBuild bp) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        backgroundColor: AstroviaTheme.panelTranslucent,
        side: BorderSide(color: AstroviaTheme.cyan.withValues(alpha: 0.4)),
      ),
      onPressed: () => _loadStarterBlueprint(bp),
      child: Text(
        label,
        style: AstroviaTheme.orbitron(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: AstroviaTheme.cyan,
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon,
      {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon,
                  size: 14,
                  color:
                      isWarning ? AstroviaTheme.red : AstroviaTheme.secondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: AstroviaTheme.rajdhani(
                  fontSize: 11,
                  color:
                      isWarning ? AstroviaTheme.red : AstroviaTheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: AstroviaTheme.orbitron(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isWarning ? AstroviaTheme.red : AstroviaTheme.white,
            ),
          ),
        ],
      ),
    );
  }
}

class BlueprintGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AstroviaTheme.cyan.withValues(alpha: 0.08)
      ..strokeWidth = 1.0;

    const step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
