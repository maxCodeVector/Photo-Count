import 'package:PhotoCount/draw/draw_page.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class ImageDraw extends StatefulWidget {
  List<AssetEntity> assetList = []; //保存Icon数据
  final AssetEntity assetEntity;

  ImageDraw(this.assetEntity, {List<AssetEntity> assetList}) {
    this.assetList = assetList;
  }

  @override
  _ImageDrawState createState() => new _ImageDrawState(this.assetEntity);
}

class _ImageDrawState extends State<ImageDraw> {
  List<AssetEntity> assetList = []; //保存Icon数据
  final AssetEntity currEntity;

  _ImageDrawState(this.currEntity, {List<AssetEntity> assetList}) {
    this.assetList = assetList;
  }

  @override
  void initState() {
    // 初始化数据
  }

  @override
  Widget build(BuildContext context) {
    return DrawPage(this.currEntity);
  }
}
