import 'package:flutter/material.dart';

class ProductCreatePage extends StatefulWidget {
  final Function addProduct;

  ProductCreatePage(this.addProduct);

  @override
  _ProductCreatePageState createState() => _ProductCreatePageState();
}

class _ProductCreatePageState extends State<ProductCreatePage> {
  String _titleValue = '';
  String _descriptionValue = '';
  double _priceValue = 0.0;

  Widget _buildTitleTextField() {
    return TextField(
      onChanged: (value) {
        setState(() {
          _titleValue = value;
        });
      },
      decoration: InputDecoration(
        labelText: 'Product Title',
      ),
    );
  }

  Widget _buildDescriptionTextField() {
    return TextField(
      maxLines: 4,
      onChanged: (value) {
        setState(() {
          _descriptionValue = value;
        });
      },
      decoration: InputDecoration(
        labelText: 'Product Description',
      ),
    );
  }

  Widget _buildPriceTextField() {
    return TextField(
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {
          _priceValue = double.parse(value);
        });
      },
      decoration: InputDecoration(
        labelText: 'Product Price',
      ),
    );
  }

  void _onHandleSave() {
    final Map<String, dynamic> product = {
      'title': _titleValue,
      'description': _descriptionValue,
      'price': _priceValue,
      'image': 'assets/food.jpg'
    };
    widget.addProduct(product);
    Navigator.of(context).pushReplacementNamed('/products');
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;
    return Container(
      margin: EdgeInsets.all(10.0),
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
        children: <Widget>[
          _buildTitleTextField(),
          _buildDescriptionTextField(),
          _buildPriceTextField(),
          SizedBox(
            height: 15.0,
          ),
          RaisedButton(
            child: Text('Save'),
            textColor: Colors.white,
            onPressed: _onHandleSave,
          )
//          GestureDetector(
//            onTap: _onHandleSave,
//            child: Container(
//              color: Colors.green,
//              padding: EdgeInsets.all(5.0),
//              child: Text('My Button'),
//            ),
//          )
        ],
      ),
    );
  }
}
