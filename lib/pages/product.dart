import 'package:flutter/material.dart';

class ProductPage extends StatelessWidget {
  final String title;
  final String imageUrl;

  ProductPage(this.title, this.imageUrl);

  _showWarningDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Are you sure?'),
            content: Text('This action is irreversible'),
            actions: <Widget>[
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('Delete'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(imageUrl),
          Container(
            child: Text('On the product page'),
            padding: EdgeInsets.all(10.0),
          ),
          Container(
            padding: EdgeInsets.all(10.0),
            child: RaisedButton(
              color: Theme.of(context).accentColor,
              child: Text('DELETE'),
              onPressed: () => _showWarningDialog(context),
            ),
          )
        ],
      ),
    );
//    return WillPopScope(
//      onWillPop: () {
//        Navigator.of(context).pop(false);
//        return Future.value(false);
//      },
//      child: Scaffold(
//        appBar: AppBar(
//          title: Text(title),
//        ),
//        body: Column(
//          crossAxisAlignment: CrossAxisAlignment.center,
//          children: <Widget>[
//            Image.asset(imageUrl),
//            Container(
//              child: Text('On the product page'),
//              padding: EdgeInsets.all(10.0),
//            ),
//            Container(
//              padding: EdgeInsets.all(10.0),
//              child: RaisedButton(
//                color: Theme.of(context).accentColor,
//                child: Text('DELETE'),
//                onPressed: () => _showWarningDialog(context),
//              ),
//            )
//          ],
//        ),
//      ),
//    );
  }
}
