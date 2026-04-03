import 'package:flutter/material.dart';
import 'package:frontend/models/route_point_model/route_segment_model.dart';
import 'package:frontend/utils/constants/ui/box_decor_const.dart';
import 'package:frontend/utils/widgets/navigation_icon.dart';

class SegmentInfo extends StatelessWidget {
  const SegmentInfo({super.key, required this.segment, this.nextSegment});

  final RouteSegmentModel segment;
  final RouteSegmentModel? nextSegment;

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.toInt()} m';
  }

  String _formatDuration(double seconds) {
    final mins = (seconds / 60).ceil();
    if (mins < 60) return '$mins min';
    final h = mins ~/ 60;
    final m = mins % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maneuver = ManeuverType.fromValue(1);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Current segment card ──────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(BoxDecorConst.borderRadius),
          ),
          child: Row(
            children: [
              // Maneuver icon for current segment
              NavigationIcon.of(
                maneuver,
                size: 60,
                color: theme.colorScheme.onPrimary,
                backgroundColor: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              // Instruction + distance/duration
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      segment.instruction,
                      style: TextStyle(
                        fontSize: theme.textTheme.titleMedium?.fontSize,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.straighten_rounded,
                          size: 13,
                          color: theme.colorScheme.onPrimaryContainer
                              .withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDistance(segment.distance),
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onPrimaryContainer
                                .withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.schedule_rounded,
                          size: 13,
                          color: theme.colorScheme.onPrimaryContainer
                              .withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDuration(segment.duration),
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onPrimaryContainer
                                .withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Upcoming segment type icon (small, right side)
              if (nextSegment != null) ...[
                const SizedBox(width: 8),
                Column(
                  children: [
                    Text(
                      'then',
                      style: TextStyle(
                        fontSize: 9,
                        color: theme.colorScheme.onPrimaryContainer.withOpacity(
                          0.55,
                        ),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    NavigationIcon.of(
                      ManeuverType.fromValue(nextSegment!.type),
                      size: 28,
                      color: theme.colorScheme.onPrimaryContainer,
                      backgroundColor: theme.colorScheme.onPrimaryContainer
                          .withOpacity(0.15),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
