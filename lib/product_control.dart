import 'package:flutter/material.dart';

class ProductControl extends StatelessWidget {
  final Function(Map<String, String> val) _handleOnPress;

  ProductControl(this._handleOnPress);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
        color: Theme.of(context).primaryColor,
        child: Text('Add Product'),
        onPressed: () {
          _handleOnPress({'title': 'Chocolate', 'image': 'assets/food.jpg'});
        });
  }
}
