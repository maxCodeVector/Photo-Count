import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo_manager/photo_manager.dart';

import 'file_utils.dart';
import 'scrawl_painter.dart';

Widget buildImage(AssetEntity assetEntity) {
  return FutureBuilder<Uint8List>(
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            child: Image.memory(snapshot.data,
                width: assetEntity.width.toDouble(),
                height: assetEntity.height.toDouble(),
                fit: BoxFit.cover),
          );
        } else {
          return Container(child: Container());
        }
      },
      future: assetEntity.originBytes);
}

class ScrawlPage extends StatefulWidget {
  final AssetEntity assetEntity;

  const ScrawlPage(this.assetEntity, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ScrawlState(this.assetEntity);
}

class _ScrawlState extends State<ScrawlPage> {
  static final List<Color> colors = [
    Colors.redAccent,
    Colors.lightBlueAccent,
    Colors.greenAccent,
  ];
  static final List<double> lineWidths = [2.0, 4.0, 6.0];
  File imageFile;
  int selectedLine = 0;
  Color selectedColor = colors[0];
  List<Point> points = [Point(colors[0], lineWidths[0], [])];
  int curFrame = 0;
  bool isClear = false;

  final GlobalKey _repaintKey = new GlobalKey();

  AssetEntity currAssetEntity;

  Uint8List imageData;

  _ScrawlState(this.currAssetEntity);

  double get strokeWidth => lineWidths[selectedLine];

  @override
  void initState() {
    super.initState();
    getImage();
  }

  void getImage() async {
    var currImageData = await this.currAssetEntity.originBytes;
    setState(() {
      this.imageData = currImageData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Start counting now!"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.undo),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.redo),
              onPressed: () {},
            ),
          ],
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  color: Colors.white,
                  margin: EdgeInsets.all(12.0),
                  child: RepaintBoundary(
                    key: _repaintKey,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        (imageData == null)
                            ? Container()
                            : Image.memory(this.imageData),
                        Positioned(
                          child: _buildCanvas(),
                          top: 0.0,
                          bottom: 0.0,
                          left: 0.0,
                          right: 0.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottom(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCanvas() {
    return StatefulBuilder(builder: (context, state) {
      return CustomPaint(
        painter: ScrawlPainter(
          points: points,
          strokeColor: selectedColor,
          strokeWidth: strokeWidth,
          isClear: isClear,
        ),
        child: GestureDetector(
          onPanStart: (details) {
            // before painting, set color & strokeWidth.
            isClear = false;
            points[curFrame].color = selectedColor;
            points[curFrame].strokeWidth = strokeWidth;
          },
          onPanUpdate: (details) {
            RenderBox referenceBox = context.findRenderObject();
            Offset localPosition =
                referenceBox.globalToLocal(details.globalPosition);
            state(() {
              points[curFrame].points.add(localPosition);
            });
          },
          onPanEnd: (details) {
            // preparing for next line painting.
            points.add(Point(selectedColor, strokeWidth, []));
            setState(() {
              curFrame++;
            });
          },
        ),
      );
    });
  }

  Widget _buildBottom() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
      child: StatefulBuilder(builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            GestureDetector(
              child: Icon(
                Icons.brightness_1,
                size: 10.0,
                color: selectedLine == 0
                    ? Colors.black87
                    : Colors.grey.withOpacity(0.5),
              ),
              onTap: () {
                state(() {
                  selectedLine = 0;
                });
              },
            ),
            GestureDetector(
              child: Icon(
                Icons.brightness_1,
                size: 15.0,
                color: selectedLine == 1
                    ? Colors.black87
                    : Colors.grey.withOpacity(0.5),
              ),
              onTap: () {
                state(() {
                  selectedLine = 1;
                });
              },
            ),
            GestureDetector(
              child: Icon(
                Icons.brightness_1,
                size: 20.0,
                color: selectedLine == 2
                    ? Colors.black87
                    : Colors.grey.withOpacity(0.5),
              ),
              onTap: () {
                state(() {
                  selectedLine = 2;
                });
              },
            ),
            GestureDetector(
              child: Container(
                color: selectedColor == colors[0]
                    ? Colors.grey.withOpacity(0.2)
                    : Colors.transparent,
                child: Icon(
                  Icons.create,
                  color: colors[0],
                ),
              ),
              onTap: () {
                state(() {
                  selectedColor = colors[0];
                });
              },
            ),
            GestureDetector(
              child: Container(
                color: selectedColor == colors[1]
                    ? Colors.grey.withOpacity(0.2)
                    : Colors.transparent,
                child: Icon(
                  Icons.create,
                  color: colors[1],
                ),
              ),
              onTap: () {
                state(() {
                  selectedColor = colors[1];
                });
              },
            ),
            GestureDetector(
              child: Container(
                color: selectedColor == colors[2]
                    ? Colors.grey.withOpacity(0.2)
                    : Colors.transparent,
                child: Icon(
                  Icons.create,
                  color: colors[2],
                ),
              ),
              onTap: () {
                state(() {
                  selectedColor = colors[2];
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  reset();
                });
              },
            ),
            Text("count: " + curFrame.toString())
          ],
        );
      }),
    );
  }

  void reset() {
    isClear = true;
    curFrame = 0;
    points.clear();
    points.add(Point(selectedColor, strokeWidth, []));
  }
}
