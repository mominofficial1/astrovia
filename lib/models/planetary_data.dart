// NASA Planetary Properties and Verified Physical Constants
class PlanetaryData {
  final String name;
  final double surfaceGravity; // m/s^2
  final double atmosphericPressure; // kPa
  final double escapeVelocity; // km/s
  final double meanTemperature; // Celsius
  final double orbitalDistanceAU; // Astronomical Units
  final String primaryGas;

  const PlanetaryData({
    required this.name,
    required this.surfaceGravity,
    required this.atmosphericPressure,
    required this.escapeVelocity,
    required this.meanTemperature,
    required this.orbitalDistanceAU,
    required this.primaryGas,
  });

  // Source: NASA Planetary Fact Sheet (https://nssdc.gsfc.nasa.gov/planetary/factsheet/)
  static const PlanetaryData earth = PlanetaryData(
    name: "Earth",
    surfaceGravity: 9.807,
    atmosphericPressure: 101.325,
    escapeVelocity: 11.186,
    meanTemperature: 15.0,
    orbitalDistanceAU: 1.0,
    primaryGas: "N2 / O2 (78% / 21%)",
  );

  static const PlanetaryData moon = PlanetaryData(
    name: "Moon",
    surfaceGravity: 1.62,
    atmosphericPressure: 0.0,
    escapeVelocity: 2.38,
    meanTemperature: -20.0,
    orbitalDistanceAU: 1.0, // In Earth orbit (384,400 km)
    primaryGas: "Hard Vacuum (<10^-10 Pa)",
  );

  static const PlanetaryData mars = PlanetaryData(
    name: "Mars",
    surfaceGravity: 3.721,
    atmosphericPressure: 0.636,
    escapeVelocity: 5.027,
    meanTemperature: -63.0,
    orbitalDistanceAU: 1.524,
    primaryGas: "CO2 (95.3%)",
  );

  static const PlanetaryData bennu = PlanetaryData(
    name: "Asteroid 101955 Bennu",
    surfaceGravity: 0.00006, // Microgravity (~60-80 micro-g)
    atmosphericPressure: 0.0,
    escapeVelocity: 0.0002,
    meanTemperature: -73.0,
    orbitalDistanceAU: 1.126,
    primaryGas: "Vacuum",
  );
}

