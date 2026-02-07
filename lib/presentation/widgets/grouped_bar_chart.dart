import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Structure d'une série (groupe) pour le chart groupé
class ChartSeries {
  final String id; // ex: "Manto", "Sottomanto", "Silice" ou "Recharge"
  final Color color;
  final List<double> values; // aligné sur buckets
  ChartSeries({required this.id, required this.color, required this.values});
}

/// Chart groupé par bucket (X) avec N séries (légende)
class GroupedBarChart extends StatelessWidget {
  final List<String> buckets; // étiquettes X
  final List<ChartSeries> series; // séries groupées
  final double height;
  final EdgeInsets padding;
  final String? title;
  final int yTickCount;

  const GroupedBarChart({
    super.key,
    required this.buckets,
    required this.series,
    this.height = 240,
    this.padding = const EdgeInsets.all(12),
    this.title,
    this.yTickCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    final maxY = _computeMaxY(series);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(title!, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
            ],
            _Legend(series: series),
            const SizedBox(height: 8),
            SizedBox(
              height: height,
              child: CustomPaint(
                painter: _GroupedBarPainter(
                  buckets: buckets,
                  series: series,
                  maxY: maxY == 0 ? 1 : maxY,
                  yTickCount: yTickCount,
                  textStyle: Theme.of(context).textTheme.bodySmall!,
                  gridColor: Colors.grey.withOpacity(0.25),
                ),
                child: Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _computeMaxY(List<ChartSeries> s) {
    double maxV = 0;
    for (final serie in s) {
      for (final v in serie.values) {
        if (v > maxV) maxV = v;
      }
    }
    // marge 10%
    return (maxV * 1.1).ceilToDouble();
  }
}

class _Legend extends StatelessWidget {
  final List<ChartSeries> series;
  const _Legend({required this.series});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: series.map((s) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                    color: s.color, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 6),
            Text(s.id, style: Theme.of(context).textTheme.bodySmall),
          ],
        );
      }).toList(),
    );
  }
}

class _GroupedBarPainter extends CustomPainter {
  final List<String> buckets;
  final List<ChartSeries> series;
  final double maxY;
  final int yTickCount;
  final TextStyle textStyle;
  final Color gridColor;

  _GroupedBarPainter({
    required this.buckets,
    required this.series,
    required this.maxY,
    required this.yTickCount,
    required this.textStyle,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintAxis = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    final paddingLeft = 36.0;
    final paddingBottom = 28.0;
    final chartW = size.width - paddingLeft - 8;
    final chartH = size.height - paddingBottom - 8;
    final origin = Offset(paddingLeft, size.height - paddingBottom);

    // Grille horizontale + ticks Y
    final tpBuilder = (String text) {
      final tp = TextPainter(
        text: TextSpan(text: text, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      return tp;
    };

    for (int i = 0; i <= yTickCount; i++) {
      final yVal = (maxY * i / yTickCount);
      final y = origin.dy - (yVal / maxY) * chartH;
      // ligne
      canvas.drawLine(
          Offset(paddingLeft, y), Offset(paddingLeft + chartW, y), paintAxis);
      // label
      final tp = tpBuilder(yVal.toStringAsFixed(0));
      tp.paint(canvas, Offset(paddingLeft - tp.width - 6, y - tp.height / 2));
    }

    if (buckets.isEmpty || series.isEmpty) return;

    // Calcul barres groupées
    final groupCount = buckets.length;
    final serieCount = series.length;
    final groupGap = 16.0;
    final barGap = 6.0;

    final groupWidth =
        (chartW - (groupGap * (groupCount - 1))) / math.max(groupCount, 1);
    final barWidth =
        (groupWidth - (barGap * (serieCount - 1))) / math.max(serieCount, 1);

    // Dessin barres + labels X
    for (int g = 0; g < groupCount; g++) {
      final groupX = paddingLeft + g * (groupWidth + groupGap);
      for (int s = 0; s < serieCount; s++) {
        final v = series[s].values.length > g ? series[s].values[g] : 0.0;
        final h = (v / maxY) * chartH;
        final x = groupX + s * (barWidth + barGap);
        final y = origin.dy - h;

        final barPaint = Paint()..color = series[s].color;
        final r = RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, barWidth, h), const Radius.circular(3));
        canvas.drawRRect(r, barPaint);
      }

      // label X (bucket)
      final label = buckets[g];
      final tp = tpBuilder(label);
      final lx = groupX + (groupWidth - tp.width) / 2;
      final ly = origin.dy + 4;
      tp.paint(canvas, Offset(lx, ly));
    }
  }

  @override
  bool shouldRepaint(covariant _GroupedBarPainter oldDelegate) {
    return oldDelegate.buckets != buckets ||
        oldDelegate.series != series ||
        oldDelegate.maxY != maxY ||
        oldDelegate.yTickCount != yTickCount;
  }
}
