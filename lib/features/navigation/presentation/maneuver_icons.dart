import 'package:flutter/material.dart';

IconData maneuverIconForType(String type) {
  switch (type) {
    case 'depart':
      return Icons.trip_origin_rounded;
    case 'turn-left':
    case 'turn-slight-left':
    case 'fork-left':
      return Icons.turn_left_rounded;
    case 'turn-right':
    case 'turn-slight-right':
    case 'fork-right':
      return Icons.turn_right_rounded;
    case 'turn-sharp-left':
      return Icons.u_turn_left_rounded;
    case 'turn-sharp-right':
      return Icons.u_turn_right_rounded;
    case 'uturn':
      return Icons.u_turn_left_rounded;
    case 'roundabout':
      return Icons.sync_rounded;
    case 'merge':
      return Icons.merge_rounded;
    case 'arrive':
      return Icons.flag_rounded;
    case 'continue':
    default:
      return Icons.straight_rounded;
  }
}
