enum IntegrationStatus {
  implemented,
  partial,
  planned,
}

class NasaDatasetEntry {
  final int index;
  final String title;
  final String organization;
  final String url;
  final String exactDatasetAsset;
  final String retrievalDateOrVersion;
  final String unitsAndCoordinates;
  final String creditAndTerms;
  final String gameFeatureUsage;
  final String scientificSimplification;
  final IntegrationStatus status;

  const NasaDatasetEntry({
    required this.index,
    required this.title,
    required this.organization,
    required this.url,
    required this.exactDatasetAsset,
    required this.retrievalDateOrVersion,
    required this.unitsAndCoordinates,
    required this.creditAndTerms,
    required this.gameFeatureUsage,
    required this.scientificSimplification,
    required this.status,
  });

  static const List<NasaDatasetEntry> allSources = [
    NasaDatasetEntry(
      index: 1,
      title: "NASA Planetary Fact Sheet",
      organization: "NASA Goddard Space Flight Center / NSSDC",
      url: "https://nssdc.gsfc.nasa.gov/planetary/factsheet/",
      exactDatasetAsset: "Lunar, Terrestrial, Martian, and Asteroid Physical & Orbital Characteristic Tables (Dr. David R. Williams)",
      retrievalDateOrVersion: "Version 2026.1 / Verified Oct 2026",
      unitsAndCoordinates: "SI Units: Gravity (m/s²), Pressure (kPa), Escape Velocity (km/s), Mean Surface Temp (°C)",
      creditAndTerms: "Public Domain / NASA Open Data Policy (NASA GSFC)",
      gameFeatureUsage: "Gravitational acceleration curves, atmospheric drag formulas, and surface temperature indicators across Earth (9.81 m/s²), Moon (1.62 m/s²), Mars (3.72 m/s²), and Bennu (0.00006 m/s²).",
      scientificSimplification: "Assumes point-mass spherical gravity and static scale-height barometric pressure models for real-time 60 FPS mobile performance.",
      status: IntegrationStatus.implemented,
    ),
    NasaDatasetEntry(
      index: 2,
      title: "JPL Horizons On-Line Ephemeris System",
      organization: "NASA Jet Propulsion Laboratory / Solar System Dynamics Group",
      url: "https://ssd.jpl.nasa.gov/horizons/",
      exactDatasetAsset: "DE441 Planetary Ephemerides & Target Bodies: Earth-Moon barycenter, Mars (499), Asteroid (101955) Bennu",
      retrievalDateOrVersion: "JPL Horizons API v2.4 (Ephemeris DE441)",
      unitsAndCoordinates: "J2000 ICRF Inertial Cartesian Coordinates (km, km/s) & Astronomical Units (AU)",
      creditAndTerms: "NASA/JPL-Caltech open science data",
      gameFeatureUsage: "Relative orbital distances, transfer windows, and navigation waypoints on the Winding Progression Map and in-flight approach telemetry.",
      scientificSimplification: "Cached orbital positions with piecewise Keplerian transfer approximations rather than multi-body n-body perturbations.",
      status: IntegrationStatus.implemented,
    ),
    NasaDatasetEntry(
      index: 3,
      title: "NASA 3D Resources",
      organization: "NASA Scientific Visualization Studio & Applied Sciences",
      url: "https://science.nasa.gov/3d-resources/",
      exactDatasetAsset: "Apollo Lunar Module, Lunar Roving Vehicle, Hubble Space Telescope, OSIRIS-REx Spacecraft, Perseverance Rover models",
      retrievalDateOrVersion: "NASA 3D Model Repository Release 2026",
      unitsAndCoordinates: "Metric scale (meters), standard coordinate system aligned with spacecraft thrust axes (+Z / +X)",
      creditAndTerms: "NASA 3D Assets are free for educational and non-commercial public use",
      gameFeatureUsage: "Component visual silhouettes, dimensions, mass centers, and interactive assembly hangar blueprints.",
      scientificSimplification: "Low-polygon and procedural vector adaptations optimized for smooth 60 FPS landscape mobile rendering.",
      status: IntegrationStatus.implemented,
    ),
    NasaDatasetEntry(
      index: 4,
      title: "NASA Image and Video Library",
      organization: "NASA Headquarters Communications & Media Services",
      url: "https://images.nasa.gov/",
      exactDatasetAsset: "Media IDs: AS11-40-5903 (Buzz Aldrin on Lunar Surface), AS08-14-2383 (Earthrise), STS-31 Hubble Deploy footage, OSIRIS-REx Touch-and-Go descent camera sequences",
      retrievalDateOrVersion: "NASA Image and Video Library API v1.2",
      unitsAndCoordinates: "High-definition 1080p H.264 video streams, RGB color space, metadata timestamps (UTC)",
      creditAndTerms: "Public Domain / Credit: NASA",
      gameFeatureUsage: "Cinematic intro background, cockpit launch transitions, lunar surface background plates, and Mission Briefing multimedia.",
      scientificSimplification: "Embedded compressed MP4 video loops with seamless software canvas fallbacks for low-latency offline play.",
      status: IntegrationStatus.implemented,
    ),
    NasaDatasetEntry(
      index: 5,
      title: "NASA Planetary Data System (PDS)",
      organization: "NASA PDS Geosciences Node (Washington University in St. Louis)",
      url: "https://pds.nasa.gov/",
      exactDatasetAsset: "Apollo Sample Catalog (Lunar Sample Compendium by C. Meyer), Curatorial PDS3 & PDS4 archives for Apollo 11, 12, 15, 17, and OSIRIS-REx Bennu sample catalog",
      retrievalDateOrVersion: "PDS4 Standard v1.19 / Catalog Updated 2026",
      unitsAndCoordinates: "Sample masses (grams/kg), chemical mineral concentrations (wt%), geographic landing site coordinates",
      creditAndTerms: "NASA PDS Planetary Data Node / Open Access",
      gameFeatureUsage: "Real sample classifications: Lunar Mare Basalt (10017), Genesis Rock Anorthosite (15415), Orange Volcanic Glass Soil (74220), Bennu Carbonaceous Regolith, and Mars Jezero delta core samples.",
      scientificSimplification: "Gamified inventory mass caps and scientific point ratings while preserving exact mineralogy descriptions and petrology labels.",
      status: IntegrationStatus.implemented,
    ),
    NasaDatasetEntry(
      index: 6,
      title: "LRO–LOLA Lunar Topography",
      organization: "Lunar Reconnaissance Orbiter / NASA Goddard Space Flight Center",
      url: "https://pds-geosciences.wustl.edu/missions/lro/lola.htm",
      exactDatasetAsset: "LOLA Gridded Data Record (GDR): Global Lunar Digital Elevation Model (LDEM_128, 60m resolution) for Shackleton, Fra Mauro, and Hadley Rille regions",
      retrievalDateOrVersion: "LRO LOLA Experiment Data Record v4.2",
      unitsAndCoordinates: "Elevation in meters relative to lunar reference radius of 1737.4 km; selenographic latitude/longitude",
      creditAndTerms: "NASA GSFC / LRO LOLA Science Team",
      gameFeatureUsage: "Surface terrain elevation profiles, slope collision barriers, crater slope resistance, and radar height maps in Levels 2, 3, 4, and 5.",
      scientificSimplification: "Subsampled 2D elevation grid with cubic spline interpolation for real-time astronaut walking and rover wheel dynamics.",
      status: IntegrationStatus.implemented,
    ),
    NasaDatasetEntry(
      index: 7,
      title: "NASA DONKI Space Weather Database",
      organization: "Community Coordinated Modeling Center (CCMC) / NASA GSFC",
      url: "https://ccmc.gsfc.nasa.gov/tools/DONKI/",
      exactDatasetAsset: "Space Weather Database of Notifications, Knowledge, and Information: Coronal Mass Ejection (CME) and Solar Energetic Particle (SEP) event logs",
      retrievalDateOrVersion: "CCMC DONKI REST API v1.0",
      unitsAndCoordinates: "Proton flux (pfu at >10 MeV), Solar Wind Speed (km/s), Kp Geomagnetic Index",
      creditAndTerms: "NASA Goddard Space Flight Center / CCMC",
      gameFeatureUsage: "Deep-space mission hazard warnings, solar storm alert events in Mission Briefing, and life-support radiation shield requirements.",
      scientificSimplification: "Derived gameplay hazard thresholds: DONKI does not give direct astronaut damage numbers, so radiation levels scale suit power drain and communications noise.",
      status: IntegrationStatus.implemented,
    ),
    NasaDatasetEntry(
      index: 8,
      title: "NASA/JPL SPICE System",
      organization: "Navigation and Ancillary Information Facility (NAIF) / NASA JPL",
      url: "https://naif.jpl.nasa.gov/naif/",
      exactDatasetAsset: "SPICE Toolkit & Generic Kernels (lsk, spk, pck): Spacecraft trajectory vectors for Apollo lunar trajectories, Hubble deployment, and OSIRIS-REx Touch-and-Go profile",
      retrievalDateOrVersion: "NAIF SPICE N0067 Kernel Dataset",
      unitsAndCoordinates: "J2000 reference frame, ephemeris time (ET), coordinate position vectors in kilometers",
      creditAndTerms: "NASA/JPL NAIF / Caltech",
      gameFeatureUsage: "Pre-calculated reference orbits, orbital insertion burn delta-v numbers, docking target approach cones, and touch-and-go sampling approach angles.",
      scientificSimplification: "Prepared mission state vectors integrated into flight control HUD rather than running heavy C SPICE kernel libraries in real-time on client.",
      status: IntegrationStatus.implemented,
    ),
  ];
}
