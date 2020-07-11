import 'package:flutter/material.dart';

import 'draw_entity.dart';
import 'draw_provider.dart';


class SignaturePainter extends CustomPainter {
  List<DrawEntity> pointsList;
  Paint pt;

  SignaturePainter(this.pointsList) {
    pt = Paint() //设置笔的属性
      ..color = pintColor["default"]
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.bevel;
  }

  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pointsList.length - 1; i++) {
      //画线
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        pt
          ..color = pintColor[pointsList[i].color]
          ..strokeWidth = pointsList[i].strokeWidth;

        canvas.drawLine(pointsList[i].offset, pointsList[i + 1].offset, pt);
      }
    }
  }

//是否重绘
  bool shouldRepaint(SignaturePainter other) => other.pointsList != pointsList;
}
