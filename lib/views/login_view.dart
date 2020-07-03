import 'package:flutter/material.dart';

class LoginView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Material is a conceptual piece of paper on which the UI appears.
    return Material(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Image.asset("assets/fpt-logo.png"),
            ),
            Text('Instant booking for your need'),
            Container(
              margin: EdgeInsets.only(top: 20),
              child: RaisedButton(
                child: Text("Sign in with email @fpt.edu.vn"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
