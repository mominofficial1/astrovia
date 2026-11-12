import 'package:flutter/material.dart';
import '../models/nasa_dataset_info.dart';
import '../services/audio_service.dart';
import '../theme/astrovia_theme.dart';
import '../widgets/hud_container.dart';

class ScreenNasaCredits extends StatefulWidget {
  const ScreenNasaCredits({super.key});

  @override
  State<ScreenNasaCredits> createState() => _ScreenNasaCreditsState();
}

class _ScreenNasaCreditsState extends State<ScreenNasaCredits> {
  int _selectedSourceIndex = 0;

  @override
  Widget build(BuildContext context) {
    final sources = NasaDatasetEntry.allSources;
    final active = sources[_selectedSourceIndex];

    return Scaffold(
      backgroundColor: AstroviaTheme.darkSpace,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Bar
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
                  Column(
                    children: [
                      Text(
                        "NASA DATA ARCHIVE & SCIENTIFIC CITATIONS",
                        style: AstroviaTheme.orbitron(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AstroviaTheme.white,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "NASA International Space Apps Challenge 2026 • Verified Datasets Integration",
                        style: AstroviaTheme.rajdhani(
                          fontSize: 12,
                          color: AstroviaTheme.secondary,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AstroviaTheme.cyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AstroviaTheme.cyan, width: 1.0),
                    ),
                    child: Text(
                      "8 SOURCES VERIFIED",
                      style: AstroviaTheme.orbitron(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AstroviaTheme.cyan,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Main content: Left list of 8 sources, Right source inspection panel
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left Source Selector Tabs
                    Expanded(
                      flex: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AstroviaTheme.panelTranslucent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AstroviaTheme.cyan.withValues(alpha: 0.3)),
                        ),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(8),
                          itemCount: sources.length,
                          separatorBuilder: (context, idx) =>
                              const SizedBox(height: 6),
                          itemBuilder: (context, idx) {
                            final item = sources[idx];
                            final isSel = idx == _selectedSourceIndex;
                            return InkWell(
                              onTap: () {
                                AudioService.instance.playClick();
                                setState(() {
                                  _selectedSourceIndex = idx;
                                });
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? AstroviaTheme.cyan.withValues(alpha: 0.22)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isSel
                                        ? AstroviaTheme.cyan
                                        : Colors.transparent,
                                    width: 1.2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSel
                                            ? AstroviaTheme.cyan
                                            : AstroviaTheme.panel,
                                        border: Border.all(
                                            color: AstroviaTheme.cyan),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        "${item.index}",
                                        style: AstroviaTheme.orbitron(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isSel
                                              ? AstroviaTheme.darkSpace
                                              : AstroviaTheme.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AstroviaTheme.rajdhani(
                                              fontSize: 14,
                                              fontWeight: isSel
                                                  ? FontWeight.bold
                                                  : FontWeight.w600,
                                              color: isSel
                                                  ? AstroviaTheme.white
                                                  : AstroviaTheme.secondary,
                                            ),
                                          ),
                                          Text(
                                            item.organization,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AstroviaTheme.inter(
                                              fontSize: 10,
                                              color: AstroviaTheme.secondary
                                                  .withValues(alpha: 0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      size: 16,
                                      color: AstroviaTheme.green,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Right Detail Display (Presentation-Ready Reference Screen)
                    Expanded(
                      flex: 6,
                      child: HudContainer(
                        isSelected: true,
                        padding: const EdgeInsets.all(20),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Title & Status
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      active.title.toUpperCase(),
                                      style: AstroviaTheme.orbitron(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AstroviaTheme.cyan,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color:
                                          AstroviaTheme.green.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: AstroviaTheme.green),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.bolt_rounded,
                                            size: 14,
                                            color: AstroviaTheme.green),
                                        const SizedBox(width: 4),
                                        Text(
                                          "IMPLEMENTED IN GAME",
                                          style: AstroviaTheme.orbitron(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: AstroviaTheme.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                active.organization,
                                style: AstroviaTheme.rajdhani(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AstroviaTheme.gold,
                                ),
                              ),
                              const Divider(
                                color: Color(0x3319D9FF),
                                height: 20,
                              ),

                              _buildDataRow("SOURCE LINK", active.url,
                                  isUrl: true),
                              const SizedBox(height: 10),
                              _buildDataRow("EXACT DATASET / ASSET",
                                  active.exactDatasetAsset),
                              const SizedBox(height: 10),
                              _buildDataRow("RETRIEVAL / VERSION",
                                  active.retrievalDateOrVersion),
                              const SizedBox(height: 10),
                              _buildDataRow("UNITS & COORDINATES",
                                  active.unitsAndCoordinates),
                              const SizedBox(height: 10),
                              _buildDataRow(
                                  "TERMS & CREDIT", active.creditAndTerms),
                              const SizedBox(height: 10),
                              _buildDataRow(
                                  "GAME FEATURE USAGE", active.gameFeatureUsage,
                                  highlight: true),
                              const SizedBox(height: 10),
                              _buildDataRow("SCIENTIFIC SIMPLIFICATION",
                                  active.scientificSimplification),
                            ],
                          ),
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

  Widget _buildDataRow(String label, String value,
      {bool isUrl = false, bool highlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AstroviaTheme.rajdhani(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AstroviaTheme.secondary,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: highlight
                ? AstroviaTheme.cyan.withValues(alpha: 0.12)
                : AstroviaTheme.darkSpace,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: highlight
                  ? AstroviaTheme.cyan.withValues(alpha: 0.5)
                  : AstroviaTheme.cyan.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            value,
            style: isUrl
                ? AstroviaTheme.rajdhani(
                    fontSize: 13,
                    color: AstroviaTheme.cyan,
                    fontWeight: FontWeight.bold,
                  )
                : AstroviaTheme.inter(
                    fontSize: 12,
                    color: AstroviaTheme.white,
                    height: 1.4,
                  ),
          ),
        ),
      ],
    );
  }
}
