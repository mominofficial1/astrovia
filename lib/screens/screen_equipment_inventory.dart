import 'package:flutter/material.dart';
import '../models/inventory_model.dart';
import '../services/audio_service.dart';
import '../state/mission_state.dart';
import '../theme/astrovia_theme.dart';
import '../widgets/hud_container.dart';

class ScreenEquipmentInventory extends StatefulWidget {
  const ScreenEquipmentInventory({super.key});

  @override
  State<ScreenEquipmentInventory> createState() =>
      _ScreenEquipmentInventoryState();
}

class _ScreenEquipmentInventoryState extends State<ScreenEquipmentInventory> {
  InventoryItem? _selectedItem;

  @override
  Widget build(BuildContext context) {
    final state = MissionState.instance;
    final bag = state.bag;
    final vehicleStorage = state.activeVehicleStorage;

    return Scaffold(
      backgroundColor: AstroviaTheme.darkSpace,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
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
                    "ASTRONAUT FIELD BAG & MISSION VAULT",
                    style: AstroviaTheme.orbitron(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AstroviaTheme.white,
                      letterSpacing: 2.0,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.fitness_center_rounded,
                          color: AstroviaTheme.cyan, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        "${bag.currentMassKg.toStringAsFixed(1)} / ${bag.maxCapacityKg.toStringAsFixed(1)} KG",
                        style: AstroviaTheme.orbitron(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: bag.isFull
                              ? AstroviaTheme.red
                              : AstroviaTheme.cyan,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Main content
              Expanded(
                child: Row(
                  children: [
                    // Left Column: Active EVA Bag Items
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AstroviaTheme.panelTranslucent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AstroviaTheme.cyan.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "ASTRONAUT EVA BAG [${bag.items.length}]",
                                  style: AstroviaTheme.orbitron(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AstroviaTheme.cyan,
                                  ),
                                ),
                                if (bag.items.isNotEmpty)
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      backgroundColor: AstroviaTheme.gold
                                          .withValues(alpha: 0.15),
                                    ),
                                    icon: const Icon(Icons.move_to_inbox_rounded,
                                        size: 14, color: AstroviaTheme.gold),
                                    label: Text(
                                      "TRANSFER ALL",
                                      style: AstroviaTheme.orbitron(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: AstroviaTheme.gold,
                                      ),
                                    ),
                                    onPressed: () {
                                      AudioService.instance.playClick();
                                      setState(() {
                                        state.transferSamplesToVehicleStorage();
                                      });
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: bag.items.isEmpty
                                  ? Center(
                                      child: Text(
                                        "ASTRONAUT BAG EMPTY\n(Collect samples during planetary EVA)",
                                        textAlign: TextAlign.center,
                                        style: AstroviaTheme.rajdhani(
                                          fontSize: 13,
                                          color: AstroviaTheme.secondary,
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                      itemCount: bag.items.length,
                                      separatorBuilder: (ctx, i) =>
                                          const SizedBox(height: 6),
                                      itemBuilder: (ctx, idx) {
                                        final item = bag.items[idx];
                                        final isSel =
                                            _selectedItem?.id == item.id;
                                        return _buildItemTile(item, isSel, () {
                                          AudioService.instance.playClick();
                                          setState(() => _selectedItem = item);
                                        });
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Center Column: Secured Lander Storage Vault
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AstroviaTheme.panelTranslucent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AstroviaTheme.gold.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "LANDER HERMETIC VAULT [${vehicleStorage.length}]",
                              style: AstroviaTheme.orbitron(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AstroviaTheme.gold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: vehicleStorage.isEmpty
                                  ? Center(
                                      child: Text(
                                        "LANDER VAULT EMPTY\n(Transfer samples from bag when near vehicle)",
                                        textAlign: TextAlign.center,
                                        style: AstroviaTheme.rajdhani(
                                          fontSize: 13,
                                          color: AstroviaTheme.secondary,
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                      itemCount: vehicleStorage.length,
                                      separatorBuilder: (ctx, i) =>
                                          const SizedBox(height: 6),
                                      itemBuilder: (ctx, idx) {
                                        final item = vehicleStorage[idx];
                                        final isSel =
                                            _selectedItem?.id == item.id;
                                        return _buildItemTile(item, isSel, () {
                                          AudioService.instance.playClick();
                                          setState(() => _selectedItem = item);
                                        });
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Right Column: Item Inspection Inspector
                    Expanded(
                      flex: 4,
                      child: HudContainer(
                        isSelected: true,
                        padding: const EdgeInsets.all(16),
                        child: _selectedItem == null
                            ? Center(
                                child: Text(
                                  "SELECT ANY SAMPLE OR GEAR TO INSPECT NASA SCIENTIFIC DATA",
                                  textAlign: TextAlign.center,
                                  style: AstroviaTheme.orbitron(
                                    fontSize: 11,
                                    color: AstroviaTheme.secondary,
                                    height: 1.5,
                                  ),
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _selectedItem!.category.toUpperCase(),
                                        style: AstroviaTheme.orbitron(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AstroviaTheme.cyan,
                                        ),
                                      ),
                                      Text(
                                        "${_selectedItem!.massKg} KG",
                                        style: AstroviaTheme.orbitron(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AstroviaTheme.gold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _selectedItem!.name,
                                    style: AstroviaTheme.orbitron(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AstroviaTheme.white,
                                    ),
                                  ),
                                  const Divider(
                                      color: Color(0x3319D9FF), height: 16),
                                  Text(
                                    "DESCRIPTION & PETROLOGY",
                                    style: AstroviaTheme.rajdhani(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AstroviaTheme.secondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _selectedItem!.description,
                                    style: AstroviaTheme.inter(
                                      fontSize: 12,
                                      color: AstroviaTheme.white,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "LOCATION FOUND",
                                    style: AstroviaTheme.rajdhani(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AstroviaTheme.secondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _selectedItem!.locationFound,
                                    style: AstroviaTheme.orbitron(
                                      fontSize: 11,
                                      color: AstroviaTheme.gold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "MISSION RELEVANCE",
                                    style: AstroviaTheme.rajdhani(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AstroviaTheme.secondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _selectedItem!.missionRelevance,
                                    style: AstroviaTheme.inter(
                                      fontSize: 12,
                                      color: AstroviaTheme.cyan,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _selectedItem!.isSecuredInVehicle
                                          ? AstroviaTheme.green
                                              .withValues(alpha: 0.2)
                                          : AstroviaTheme.gold
                                              .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _selectedItem!.isSecuredInVehicle
                                            ? "★ SECURED FOR MISSION RETURN ★"
                                            : "IN TRANSIT (EVA BAG)",
                                        style: AstroviaTheme.orbitron(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: _selectedItem!.isSecuredInVehicle
                                              ? AstroviaTheme.green
                                              : AstroviaTheme.gold,
                                        ),
                                      ),
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
      ),
    );
  }

  Widget _buildItemTile(
      InventoryItem item, bool isSel, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSel
              ? AstroviaTheme.cyan.withValues(alpha: 0.2)
              : AstroviaTheme.darkSpace,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSel ? AstroviaTheme.cyan : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.science_rounded,
                size: 18, color: AstroviaTheme.cyan),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AstroviaTheme.rajdhani(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AstroviaTheme.white,
                    ),
                  ),
                  Text(
                    "${item.massKg} kg • ${item.category}",
                    style: AstroviaTheme.inter(
                      fontSize: 10,
                      color: AstroviaTheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

