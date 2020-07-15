import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo_manager/photo_manager.dart';

import './preview.dart';
import 'icon_text_button.dart';

void main() => runApp(MyApp());

enum PickType { onlyImage, onlyVideo, all }

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MaterialApp(
        title: 'ImageMarker',
        theme: ThemeData(
          primarySwatch: Colors.lime,
        ),
        home: MyHomePage(title: 'You better Image Marker'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String currentSelected = "";
  List<AssetPathEntity> pathList = [];

  @override
  Widget buildBigImageLoading(
      BuildContext context, AssetEntity entity, Color themeColor) {
    return Center(
      child: Container(
        width: 50.0,
        height: 50.0,
        child: CupertinoActivityIndicator(
          radius: 25.0,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    showAllImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: buildAssetPathList(),
      ),
    );
  }

  Widget buildAssetPathList() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        // 对于每个建议的单词对都会调用一次itemBuilder，然后将单词对添加到ListTile行中
        // 在偶数行，该函数会为单词对添加一个ListTile row.
        // 在奇数行，该函数会添加一个分割线widget，来分隔相邻的词对。
        // 注意，在小屏幕上，分割线看起来可能比较吃力。
        itemCount: pathList.length,
        itemBuilder: (context, i) {
          // 在每一列之前，添加一个1像素高的分隔线widget
          if (i.isOdd)
            return Divider(
              thickness: 2,
            );

          final index = i ~/ 2;

          return IconTextButton(
            icon: Icons.album,
            text: pathList[index].name +
                " " +
                pathList[index].assetCount.toString(),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => PreviewPage(pathEntity: pathList[index]))),
          );
        });
  }

  void showAllImage() async {
    var result = await PhotoManager.requestPermission();
    if (!result) {
      // fail
      /// if result is fail, you can call `PhotoManager.openSetting();`  to open android/ios applicaton's setting to get permission
      PhotoManager.openSetting();
      return;
    }
    var pathList = await PhotoManager.getAssetPathList();
    if (pathList.length == 0) {
      showToast("You do not have library");
      return;
    }

    setState(() {
      this.pathList = pathList;
    });
  }
}
