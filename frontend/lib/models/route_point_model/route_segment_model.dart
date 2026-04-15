class RouteSegmentModel {
  final String instruction;
  final int type;
  final double distance;
  final double duration;
  final List<int> waypoints;

  RouteSegmentModel({
    required this.instruction,
    required this.type,
    required this.distance,
    required this.duration,
    required this.waypoints,
  });

  factory RouteSegmentModel.fromJson(Map<String, dynamic> json) =>
      RouteSegmentModel(
        instruction: json['instruction'],
        type: json['type'],
        distance: (json['distance'] as num).toDouble(),
        duration: (json['duration'] as num).toDouble(),
        waypoints: List<int>.from(json['way_points']),
      );

  Map<String, dynamic> toJson() => {
    'instruction': instruction,
    'type': type,
    'distance': distance,
    'duration': duration,
    'way_points': waypoints,
  };

  @override
  String toString() {
    return 'RouteSegmentModel{instruction: $instruction, type: $type, distance: $distance, duration: $duration, waypoints: $waypoints}';
  }
}
