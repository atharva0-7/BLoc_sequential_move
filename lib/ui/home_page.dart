import 'package:example_folder/bloc/event/position_event.dart';
import 'package:example_folder/bloc/state/position_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/positions_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const int itemCount = 5;
  static const Duration itemAnimationDuration = Duration(milliseconds: 350);
  static const Curve itemAnimationCurve = Curves.easeInOut;

  @override
  void initState() {
    super.initState();
    // Initialize from current BLoC state so items don't overlap at first frame.
    final initial = context.read<PositionsBloc>().state;
    _displayedPositions = List<Offset>.from(initial.positions);
    _targetPositions = List<Offset>.from(initial.positions);
    _hasInitializedFromState = true;
  }

  List<Offset> _displayedPositions = List.filled(
    itemCount,
    const Offset(16, 16),
    growable: false,
  );

  List<Offset> _targetPositions = List.filled(
    itemCount,
    const Offset(16, 16),
    growable: false,
  );

  int _currentlyAnimatingIndex = -1;
  bool _hasInitializedFromState = false;
  Size? _lastBounds;

  double _computeItemSize(Size bounds) {
    final shortest = bounds.shortestSide;
    final computed = shortest / 5.5;
    if (computed < 72) return 72;
    if (computed > 140) return 140;
    return computed;
  }

  void _startSequentialAnimation(List<Offset> newTargets) {
    _targetPositions = newTargets;
    if (!mounted) return;
    setState(() {
      _currentlyAnimatingIndex = 0;
      _displayedPositions[0] = _targetPositions[0];
    });
  }

  void _handleItemAnimationEnd(int index) {
    if (index != _currentlyAnimatingIndex) return;
    if (_currentlyAnimatingIndex < itemCount - 1) {
      setState(() {
        _currentlyAnimatingIndex += 1;
        final next = _currentlyAnimatingIndex;
        _displayedPositions[next] = _targetPositions[next];
      });
    } else {
      setState(() {
        _currentlyAnimatingIndex = -1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BLoC Sequential Move')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final Size bounds = Size(constraints.maxWidth, constraints.maxHeight);
          _lastBounds = bounds;
          final double itemSize = _computeItemSize(bounds);
          return BlocListener<PositionsBloc, PositionsState>(
            listenWhen: (prev, curr) => prev.positions != curr.positions,
            listener: (context, state) {
              if (!_hasInitializedFromState) {
                // First time we get state, set displayed and target without animating.
                _hasInitializedFromState = true;
                setState(() {
                  _displayedPositions = List<Offset>.from(state.positions);
                  _targetPositions = List<Offset>.from(state.positions);
                  _currentlyAnimatingIndex = -1;
                });
              } else {
                _startSequentialAnimation(state.positions);
              }
            },
            child: Stack(
              children: [
                // Background guide
                Positioned.fill(child: Container(color: Colors.grey.shade100)),
                // The 5 animated items
                for (int i = 0; i < itemCount; i++)
                  AnimatedPositioned(
                    key: ValueKey('box_$i'),
                    left: _displayedPositions[i].dx.clamp(
                      0.0,
                      (bounds.width - itemSize).clamp(0.0, double.infinity),
                    ),
                    top: _displayedPositions[i].dy.clamp(
                      0.0,
                      (bounds.height - itemSize).clamp(0.0, double.infinity),
                    ),
                    width: itemSize,
                    height: itemSize,
                    duration: itemAnimationDuration,
                    curve: itemAnimationCurve,
                    onEnd: () => _handleItemAnimationEnd(i),
                    child: _ColoredBox(index: i),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Builder(
        builder: (context) {
          return FloatingActionButton.extended(
            onPressed: () {
              final size = _lastBounds ?? MediaQuery.of(context).size;
              final itemSize = _computeItemSize(size);
              context.read<PositionsBloc>().add(
                GenerateNewPositions(bounds: size, itemSize: itemSize),
              );
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Move'),
          );
        },
      ),
    );
  }
}

class _ColoredBox extends StatelessWidget {
  final int index;
  const _ColoredBox({required this.index});

  Color _colorForIndex(int i) {
    const colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];
    return colors[i % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _colorForIndex(index),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '${index + 1}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}
