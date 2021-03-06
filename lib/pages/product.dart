import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/product.dart';
import '../widgets/ui_elements/title_default.dart';
import '../widgets/products/product_fab.dart';

class ProductPage extends StatelessWidget {
  final Product product;

  ProductPage(this.product);

  Function _showMap(BuildContext context) {
    return () {
      final markers = <Marker>[
        Marker(
          markerId: MarkerId('Position'),
          position:
              LatLng(product.location.latitude, product.location.longitude),
        )
      ].toSet();
      final googleMap = GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: LatLng(product.location.latitude, product.location.longitude),
          zoom: 14.0,
        ),
        myLocationButtonEnabled: false,
        markers: markers,
      );
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text(product.location.address),
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: googleMap,
          ),
        );
      }));
    };
  }

  Widget _buildAddressPriceRow(
      String address, double price, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: GestureDetector(
            onTap: _showMap(context),
            child: Text(
              address,
              style: TextStyle(fontFamily: 'Oswald', color: Colors.grey),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          child: Text(
            '|',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        Flexible(
          child: Text(
            '\$' + price.toString(),
            style: TextStyle(fontFamily: 'Oswald', color: Colors.grey),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      appBar: AppBar(
//        title: Text(product.title),
//      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 256.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(product.title),
              background: Hero(
                tag: product.id,
                child: FadeInImage(
                  image: NetworkImage(product.image),
                  height: 300.0,
                  fit: BoxFit.cover,
                  placeholder: AssetImage('assets/food.jpg'),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                padding: EdgeInsets.all(10.0),
                child: TitleDefault(product.title),
                alignment: Alignment.center,
              ),
              _buildAddressPriceRow(
                  product.location.address, product.price, context),
              Container(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  product.description,
                  textAlign: TextAlign.center,
                ),
              )
            ]),
          )
        ],
      ),
      floatingActionButton: ProductFab(product),
    );
  }
}
