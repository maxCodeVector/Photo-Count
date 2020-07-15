import 'dart:math';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import './asset_image.dart';

class PreviewPage extends StatelessWidget {
  final AssetPathEntity pathEntity;

  const PreviewPage({Key key, this.pathEntity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Preview"),
      ),
      body: InfiniteGridView(pathEntity),
    );
  }
}

class InfiniteGridView extends StatefulWidget {
  final AssetPathEntity assetPathEntity;

  InfiniteGridView(this.assetPathEntity);

  @override
  _InfiniteGridViewState createState() =>
      new _InfiniteGridViewState(this.assetPathEntity);
}

class _InfiniteGridViewState extends State<InfiniteGridView> {
  final AssetPathEntity assetPathEntity;

  List<AssetEntity> assetList = []; //保存Icon数据

  _InfiniteGridViewState(this.assetPathEntity);

  @override
  void initState() {
    super.initState();
    _retrieveImages();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, //每行三列
            childAspectRatio: 1.0 //显示区域宽高相等
            ),
        itemCount: assetList.length,
        itemBuilder: (context, index) {
          //如果显示到最后一个并且Icon总数小于200时继续获取数据
          if (index == assetList.length - 1 &&
              assetList.length < assetPathEntity.assetCount) {
            _retrieveImages();
          }
          return AssetImageWidget(
            assetEntity: assetList[index],
            width: 200,
            height: 200,
            boxFit: BoxFit.cover,
          );
        });
  }

  //模拟异步获取数据
  Future<bool> _retrieveImages() async {
    int numCurrentAsset = assetList.length;
    int endAssetRange = min(numCurrentAsset + 20, assetPathEntity.assetCount);
    List<AssetEntity> imageList = await assetPathEntity.getAssetListRange(
        start: numCurrentAsset, end: endAssetRange);

    this.assetList.addAll(imageList);
    //  Future.delayed(Duration(milliseconds: 200)).then((e) {
    //    setState(() {
    //      assetList.addAll([
    //        Icons.ac_unit,
    //        Icons.airport_shuttle,
    //        Icons.all_inclusive,
    //        Icons.beach_access,
    //        Icons.cake,
    //        Icons.free_breakfast
    //      ]);
    //    });
    //  });
  }
}
