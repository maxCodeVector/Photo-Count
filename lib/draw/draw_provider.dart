import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:PhotoCount/draw/draw_entity.dart';

//可选的画板颜色
Map<String, Color> pintColor = {
  'default': Color(0xFFB275F5),
  'black': Colors.black,
  'brown': Colors.brown,
  'gray': Colors.grey,
  'blueGrey': Colors.blueGrey,
  'blue': Colors.blue,
  'cyan': Colors.cyan,
  'deepPurple': Colors.deepPurple,
  'orange': Colors.orange,
  'green': Colors.green,
  'indigo': Colors.indigo,
  'pink': Colors.pink,
  'teal': Colors.teal,
  'red': Colors.red,
  'purple': Colors.purple,
  'blueAccent': Colors.blueAccent,
  'white': Colors.white,
};

class DrawProvider {
  List<List<DrawEntity>> undoPoints = List<List<DrawEntity>>(); // 撤销的数据
  List<List<DrawEntity>> points = List<List<DrawEntity>>(); // 存储要画的数据
  List<DrawEntity> pointsList = List<DrawEntity>(); //预处理的数据，避免绘制时处理卡顿
  String pentColor = "default"; //默认颜色
  double pentSize = 5;

  final void Function() stateCallBack;

  DrawProvider(this.stateCallBack); //默认字体大小

  //清除数据
  clear() {
    //清除数据
    points.clear();
    //通知更新
    setState();
  }

  //绘制数据
  sendDraw(Offset localPosition) {
    if (points.length == 0) {
      points.add(List<DrawEntity>());
      points.add(List<DrawEntity>());
    }
    //添加绘制
    points[points.length - 2].add(
        DrawEntity(localPosition, color: pentColor, strokeWidth: pentSize));
//    points.add(localPosition);
    //通知更新
    setState();
  }

  //绘制Null数据隔断标识
  sendDrawNull() {
    //添加绘制标识
    points.add(List<DrawEntity>());
    //通知更新
    setState();
  }

  //撤销一条数据
  undoDate() {
    //撤销，缓存到撤销容器
    undoPoints.add(points[points.length - 3]); //添加到撤销的数据里
    points.removeAt(points.length - 3); //移除数据
    setState();
  }

  //反撤销一条数据
  reverseUndoDate() {
    List<DrawEntity> ss = undoPoints.removeLast();
    points.insert(points.length - 2, ss);

    setState();
  }

  _update() {
    pointsList = List<DrawEntity>();
    for (int i = 0; i < points.length - 1; i++) {
      pointsList.addAll(points[i]);
      pointsList.add(null);
    }
  }

  setState() {
    _update();
    this.stateCallBack();
  }
}
