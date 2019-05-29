import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';

import 'pages/auth.dart';
import 'pages/products_admin.dart';
import 'pages/products.dart';
import 'pages/product.dart';
import 'models/product.dart';
import 'scoped-models/main.dart';
import 'widgets/helpers/custom_route.dart';
import 'shared/adaptive_theme.dart';
//import 'package:flutter/rendering.dart';

void main() {
//  debugPaintSizeEnabled = true;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final MainModel _model = MainModel();
  final _platformChannel = MethodChannel('betterwith.tech/battery');
  bool _isAuthenticated = false;

  Future<Null> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result =
          await _platformChannel.invokeMethod<int>('getBatteryLevel');
      batteryLevel = 'Battery level is $result %.';
    } catch (error) {
      batteryLevel = 'Failed to get battery level';
    }
    print(batteryLevel);
  }

  @override
  void initState() {
    _getBatteryLevel();
    _model.autoAuthenticate();
    _model.userSubject.listen((bool isAuthenticated) {
      setState(() {
        _isAuthenticated = isAuthenticated;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(
        title: 'EasyList',
        theme: getAdaptiveThemeData(context),
        // home: AuthPage(),
        routes: {
          '/': (BuildContext context) =>
              !_isAuthenticated ? AuthPage() : ProductsPage(_model),
          '/admin': (BuildContext context) =>
              !_isAuthenticated ? AuthPage() : ProductsAdminPage(_model),
        },
        onGenerateRoute: (RouteSettings settings) {
          if (!_isAuthenticated) {
            return MaterialPageRoute<bool>(builder: (BuildContext context) {
              return AuthPage();
            });
          }

          final List<String> pathElements = settings.name.split('/');
          if (pathElements[0] != '') {
            return null;
          }

          if (pathElements[1] == 'product') {
            final String productId = pathElements[2];
            final Product product =
                _model.allProducts.firstWhere((Product product) {
              return product.id == productId;
            });
            return CustomRoute<bool>(builder: (BuildContext context) {
              return !_isAuthenticated ? AuthPage() : ProductPage(product);
            });
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
              builder: (BuildContext context) =>
                  !_isAuthenticated ? AuthPage() : ProductsPage(_model));
        },
      ),
    );
  }
}
