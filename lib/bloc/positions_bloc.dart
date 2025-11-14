import 'dart:math';
import 'package:example_folder/bloc/event/position_event.dart';
import 'package:example_folder/bloc/state/position_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


// State

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


