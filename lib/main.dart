import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo_manager/photo_manager.dart';

import './preview.dart';
import 'icon_text_button.dart';

void main() => runApp(MyApp());

enum PickType{
  onlyImage,
  onlyVideo,
  all
}

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
  Widget buildPreviewLoading(
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          FlatButton(
            child: Icon(Icons.image),
            onPressed: _testPhotoListParams,
          ),
        ],
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              IconTextButton(
                icon: Icons.photo,
                text: "photo",
                onTap: () => _pickAsset(PickType.onlyImage),
              ),
              IconTextButton(
                icon: Icons.videocam,
                text: "video",
                onTap: () => _pickAsset(PickType.onlyVideo),
              ),
              IconTextButton(
                icon: Icons.album,
                text: "all",
                onTap: () => _pickAsset(PickType.all),
              ),
              IconTextButton(
                icon: CupertinoIcons.reply_all,
                text: "Picked asset examples.",
                onTap: () => showAllImage(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAllImage(),
        tooltip: 'pickImage',
        child: Icon(Icons.add),
      ),
    );
  }

  void _testPhotoListParams() async {
    var assetPathList =
        await PhotoManager.getAssetPathList(type: RequestType.image);
    _pickAsset(PickType.all, pathList: assetPathList);
  }

  void showAllImage() async{
    var result = await PhotoManager.requestPermission();
    if (!result) {
      // fail
      /// if result is fail, you can call `PhotoManager.openSetting();`  to open android/ios applicaton's setting to get permission
      PhotoManager.openSetting();
      return;
    }
    List<AssetPathEntity> pathList = await PhotoManager.getAssetPathList();
    if(pathList.length==0){
      showToast("You do not have library");
    }

    AssetPathEntity firstPath = pathList[0];
    List<AssetEntity> imageList = await firstPath.getAssetListRange(start: 0, end: 20);

    List<String> r = [];
    for (var e in imageList) {
      var file = await e.file;
      r.add(file.absolute.path);
    }
    currentSelected = r.join("\n\n");

    List<AssetEntity> preview = [];
    preview.addAll(imageList);
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => PreviewPage(list: preview)));

    setState(() {});
  }

  void _pickAsset(PickType type, {List<AssetPathEntity> pathList}) async {
    /// context is required, other params is optional.
    /// context is required, other params is optional.
    /// context is required, other params is optional.

    List<AssetEntity> imgList = null;

    showToast("pick start?");

    if (imgList == null || imgList.isEmpty) {
      showToast("No picked item.");
      return;
    } else {
      List<String> r = [];
      for (var e in imgList) {
        var file = await e.file;
        r.add(file.absolute.path);
      }
      currentSelected = r.join("\n\n");

      List<AssetEntity> preview = [];
      preview.addAll(imgList);
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => PreviewPage(list: preview)));
    }
    setState(() {});
  }

  void routePage(Widget widget) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return widget;
        },
      ),
    );
  }
}
