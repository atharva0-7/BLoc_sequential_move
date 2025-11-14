import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class PositionsEvent {}

class GenerateNewPositions extends PositionsEvent {
  final Size bounds;
  final double itemSize;
  GenerateNewPositions({
    required this.bounds,
    required this.itemSize,
  });
}

// State
class PositionsState {
  final List<Offset> positions;
  const PositionsState({required this.positions});
}

// BLoC
class PositionsBloc extends Bloc<PositionsEvent, PositionsState> {
  PositionsBloc()
      : super(const PositionsState(
          positions: [
            Offset(16, 16),
            Offset(96, 16),
            Offset(176, 16),
            Offset(16, 96),
            Offset(96, 96),
          ],
        )) {
    on<GenerateNewPositions>(_onGenerateNewPositions);
  }

  void _onGenerateNewPositions(
    GenerateNewPositions event,
    Emitter<PositionsState> emit,
  ) {
    final random = Random();
    final maxX = (event.bounds.width - event.itemSize).clamp(0, double.infinity);
    final maxY = (event.bounds.height - event.itemSize).clamp(0, double.infinity);

    List<Offset> next = List.generate(5, (_) {
      final dx = random.nextDouble() * maxX;
      final dy = random.nextDouble() * maxY;
      return Offset(dx, dy);
    });

    emit(PositionsState(positions: next));
  }
}


