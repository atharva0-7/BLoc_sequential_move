// Events
import 'dart:ui';

abstract class PositionsEvent {}

class GenerateNewPositions extends PositionsEvent {
  final Size bounds;
  final double itemSize;
  GenerateNewPositions({
    required this.bounds,
    required this.itemSize,
  });
}
