import 'dart:typed_data';

import 'package:PhotoCount/draw/signature_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:photo_manager/photo_manager.dart';

import 'draw_provider.dart';

//绘制布局页面 （ pengzhenkun - 2020.04.30 ）
class DrawPage extends StatefulWidget {
  List<AssetEntity> assetList = []; //保存Icon数据
  final AssetEntity assetEntity;

  DrawPage(this.assetEntity, {Key key, this.assetList}) : super(key: key);

  @override
  _DrawPageState createState() => _DrawPageState(this.assetEntity);
}

class _DrawPageState extends State<DrawPage> {
  DrawProvider _provider;

  List<AssetEntity> assetList = []; //保存Icon数据
  final AssetEntity assetEntity;

  _DrawPageState(this.assetEntity, {List<AssetEntity> assetList});

  @override
  void initState() {
    super.initState();
    _provider = DrawProvider(() => this.setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Start counting now!"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.call_missed_outgoing),
              onPressed: () {
                //撤销一步
                _provider.undoDate();
              },
            ),
            IconButton(
              icon: Icon(Icons.call_missed),
              onPressed: () {
                //反撤销
                _provider.reverseUndoDate();
              },
            ),
          ],
        ),
        body: _buildBody(),
        floatingActionButton: FloatingActionButton(
          onPressed: _provider.clear,
          tooltip: 'clear draw',
          child: Icon(Icons.clear),
        ));
  }

  InkWell buildInkWell(DrawProvider drawProvider, double size) {
    return InkWell(
      onTap: () {
        drawProvider.pentSize = size;
        setState(() {});
      },
      child: Container(
        width: 40,
        height: 40,
        child: Center(
          child: Container(
            decoration: new BoxDecoration(
              color: pintColor[drawProvider.pentColor],
              //设置四周圆角 角度
              borderRadius: BorderRadius.all(Radius.circular(size / 2)),
              //设置四周边框
              border: drawProvider.pentSize == size
                  ? Border.all(width: 1, color: Colors.black)
                  : null,
            ),
            width: size,
            height: size,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      color: Color(0x18262B33),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              children: [
                _buildImage(),
                Text(_provider.points.length.toString()),
                GestureDetector(
                  //手势探测器，一个特殊的widget，想要给一个widge添加手势，直接用这货包裹起来
                  onPanUpdate: (DragUpdateDetails details) {
                    //按下
                    RenderBox referenceBox = context.findRenderObject();
                    Offset localPosition =
                        referenceBox.globalToLocal(details.globalPosition);
                    _provider.sendDraw(localPosition);
                  },
                  onPanEnd: (DragEndDetails details) {
                    _provider.sendDrawNull();
                  }, //抬起来
                ),
                CustomPaint(painter: SignaturePainter(_provider.pointsList)),
              ],
            ),
          ),
          _buildPainSize(),
          _buildPainColor()
        ],
      ),
    );
  }

  Widget _buildImage() {
    return FutureBuilder<Uint8List>(
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            color: Colors.white,
            child: Image.memory(
              snapshot.data,
//                    width: width,
//                    height: height,
              fit: BoxFit.cover,
            ),
          );
        } else {
          return Container(
            color: Colors.black,
          );
        }
      },
      future: assetEntity.originBytes,
    );
  }

  Widget _buildPainSize() {
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 80, bottom: 20),
      child: Wrap(
        spacing: 5,
        runSpacing: 5,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          buildInkWell(_provider, 5),
          buildInkWell(_provider, 8),
          buildInkWell(_provider, 10),
          buildInkWell(_provider, 15),
          buildInkWell(_provider, 17),
          buildInkWell(_provider, 20),
        ],
      ),
    );
  }

  Widget _buildPainColor() {
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 80, bottom: 20),
      child: Wrap(
        spacing: 5,
        runSpacing: 5,
        children: pintColor.keys.map((key) {
          Color value = pintColor[key];
          return InkWell(
            onTap: () {
              _provider.pentColor = key;
              setState(() {});
            },
            child: Container(
              width: 32,
              height: 32,
              color: value,
              child: _provider.pentColor == key
                  ? Icon(
                      Icons.done,
                      color: Colors.white,
                    )
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
//    _provider.dispose();
    super.dispose();
  }
}
