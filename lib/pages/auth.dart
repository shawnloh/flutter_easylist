import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  String _emailValue = '';
  String _passwordValue = '';
  bool _tos = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Container(
        margin: EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              onChanged: (val) {
                setState(() {
                  _emailValue = val;
                });
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              onChanged: (val) {
                setState(() {
                  _passwordValue = val;
                });
              },
            ),
            SwitchListTile(
              title: Text('Accept Terms'),
              onChanged: (val) {
                setState(() {
                  _tos = val;
                });
              },
              value: _tos,
            ),
            SizedBox(
              height: 10.0,
            ),
            RaisedButton(
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              child: Text('Login'),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/products');
              },
            ),
          ],
        ),
      ),
    );
  }
}
