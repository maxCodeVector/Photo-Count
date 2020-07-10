import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import './asset_image.dart';

class PreviewPage extends StatelessWidget {
  final List<AssetEntity> list;

  const PreviewPage({Key key, this.list = const []}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Preview"),
      ),
      body: InfiniteGridView(list),
    );
  }


  Widget buildImagesList() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        // 对于每个建议的单词对都会调用一次itemBuilder，然后将单词对添加到ListTile行中
        // 在偶数行，该函数会为单词对添加一个ListTile row.
        // 在奇数行，该函数会添加一个分割线widget，来分隔相邻的词对。
        // 注意，在小屏幕上，分割线看起来可能比较吃力。
        itemBuilder: (context, i) {
          // 在每一列之前，添加一个1像素高的分隔线widget
          if (i.isOdd)
            return Divider(
              thickness: 2,
            );

          final index = i ~/ 2;
          // 如果是建议列表中最后一个单词对
//          if (index >= _suggestions.length) {
//            // ...接着再生成10个单词对，然后添加到建议列表
//            _suggestions.addAll(generateWordPairs().take(10));
//            return
//          }
          return buildRow(index, 4);
        });
  }

  Widget buildRow(int index, int count) {
    int baseIndex = index * count;
    List<AssetImageWidget> row = [];
    for (var i = 0; i < count; i++) {
      if (baseIndex + count >= list.length) {
        break;
      }
      row.add(AssetImageWidget(
        assetEntity: list[baseIndex + count],
        width: 300,
        height: 200,
        boxFit: BoxFit.cover,
      ));
    }
    return Row(
      children: row,
    );
  }
}

class InfiniteGridView extends StatefulWidget {
  List<AssetEntity> assetList = []; //保存Icon数据

  InfiniteGridView(List<AssetEntity> assetList) {
    this.assetList = assetList;
  }

  @override
  _InfiniteGridViewState createState() =>
      new _InfiniteGridViewState(this.assetList);
}

class _InfiniteGridViewState extends State<InfiniteGridView> {
  List<AssetEntity> assetList = []; //保存Icon数据

  _InfiniteGridViewState(List<AssetEntity> assetList) {
    this.assetList = assetList;
  }

  @override
  void initState() {
    // 初始化数据
    _retrieveIcons();
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
          if (index == assetList.length - 1 && assetList.length < 20) {
            _retrieveIcons();
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
  void _retrieveIcons() {
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
