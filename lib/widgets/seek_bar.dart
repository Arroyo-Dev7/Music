import 'package:flutter/material.dart';

import '../services/player_service.dart';

/// Barra para ver y mover la posición de la canción, con los tiempos.
class SeekBar extends StatefulWidget {
  const SeekBar({super.key, required this.player});

  final PlayerService player;

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _dragMs; // valor mientras el usuario arrastra

  static const _timeStyle = TextStyle(
    color: Colors.white60,
    fontSize: 12,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  String _format(Duration d) {
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '${d.inMinutes}:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration?>(
      stream: widget.player.durationStream,
      builder: (context, durationSnap) {
        final total = durationSnap.data ?? Duration.zero;
        final totalMs = total.inMilliseconds.toDouble();
        final maxMs = totalMs > 0 ? totalMs : 1.0;

        return StreamBuilder<Duration>(
          stream: widget.player.positionStream,
          builder: (context, positionSnap) {
            final position = positionSnap.data ?? Duration.zero;
            final currentMs =
                (_dragMs ?? position.inMilliseconds.toDouble()).clamp(0.0, maxMs);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  value: currentMs,
                  max: maxMs,
                  onChanged: totalMs > 0
                      ? (value) => setState(() => _dragMs = value)
                      : null,
                  onChangeEnd: (value) async {
                    await widget.player.seek(
                      Duration(milliseconds: value.round()),
                    );
                    if (mounted) setState(() => _dragMs = null);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _format(Duration(milliseconds: currentMs.round())),
                        style: _timeStyle,
                      ),
                      Text(_format(total), style: _timeStyle),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
