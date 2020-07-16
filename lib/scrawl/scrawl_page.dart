import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:photo_manager/photo_manager.dart';

import 'scrawl_painter.dart';


class ScrawlPage extends StatefulWidget {
  final List<AssetEntity> assetEntityList;
  final int initialIndex;

  const ScrawlPage(this.assetEntityList, this.initialIndex, {Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _ScrawlState(this.assetEntityList, initialIndex);
}

class _ScrawlState extends State<ScrawlPage> {
  static final List<Color> colors = [
    Colors.redAccent,
    Colors.lightBlueAccent,
    Colors.greenAccent,
  ];
  static final List<double> lineWidths = [1.0, 3.0, 5.0];
  File imageFile;
  int selectedLine = 0;
  Color selectedColor = colors[0];
  List<Point> points = [];
  List<Point> undoPoints = [];
  int curFrame = 0;
  bool isClear = false;

  final GlobalKey _repaintKey = new GlobalKey();

  final List<AssetEntity> assetEntityList;
  int currentIndex;

  File currImageFile;

  _ScrawlState(this.assetEntityList, this.currentIndex);

  double get strokeWidth => lineWidths[selectedLine];

  @override
  void initState() {
    super.initState();
    getImage();
  }

  void getImage() async {
    var currImageFile = await this.assetEntityList[currentIndex].file;
    setState(() {
      this.currImageFile = currImageFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: buildAppBar(),
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
                        (currImageFile == null)
                            ? Container()
                            : Image.file(currImageFile),
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

  AppBar buildAppBar() {
    return AppBar(
      title: Text("To my Melvin"),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.arrow_upward),
          onPressed: () {
            if (currentIndex > 0) {
              currentIndex--;
              getImage();
              reset();
            }
          },
        ),
        IconButton(
          icon: Icon(Icons.arrow_downward),
          onPressed: () {
            if (currentIndex < this.assetEntityList.length - 1) {
              currentIndex++;
              getImage();
              reset();
            }
          },
        ),
        IconButton(
          icon: Icon(Icons.undo),
          onPressed: () {
            if (points.length == 0) {
              return;
            }
            Point p = points.removeLast();
            undoPoints.add(p);
            setState(() {
              curFrame--;
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.redo),
          onPressed: () {
            if (undoPoints.length == 0) {
              return;
            }
            Point p = undoPoints.removeLast();
            points.add(p);
            setState(() {
              curFrame++;
            });
          },
        ),
      ],
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
            points.add(Point(selectedColor, strokeWidth, []));
            // should clear undo points buffer if want to start paining
            if (undoPoints.length != 0) {
              undoPoints.clear();
            }
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
//            points.add(Point(selectedColor, strokeWidth, []));
            if (points[curFrame].points.length == 0) {
              print("appear 0 size points, ignore this draw");
              points.removeLast();
              return;
            }
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
    undoPoints.clear();
//    points.add(Point(selectedColor, strokeWidth, []));
  }
}
