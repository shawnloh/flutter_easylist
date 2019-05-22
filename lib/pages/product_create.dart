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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20.0),
      child: ListView(
        children: <Widget>[
          TextField(
            onChanged: (value) {
              setState(() {
                _titleValue = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Product Title',
            ),
          ),
          TextField(
            maxLines: 4,
            onChanged: (value) {
              setState(() {
                _descriptionValue = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Product Description',
            ),
          ),
          TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _priceValue = double.parse(value);
              });
            },
            decoration: InputDecoration(
              labelText: 'Product Price',
            ),
          ),
          SizedBox(
            height: 15.0,
          ),
          RaisedButton(
            child: Text('Save'),
            color: Theme.of(context).accentColor,
            textColor: Colors.white,
            onPressed: () {
              final Map<String, dynamic> product = {
                'title': _titleValue,
                'description': _descriptionValue,
                'price': _priceValue,
                'image': 'assets/food.jpg'
              };
              widget.addProduct(product);
              Navigator.of(context).pushReplacementNamed('/products');
            },
          )
        ],
      ),
    );
  }
}
