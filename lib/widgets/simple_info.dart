import 'package:flutter/widgets.dart';

class SimpleInfo extends StatelessWidget {
  final String labelText;
  final Widget child;
  final double marginBetween;
  final double marginBottom;
  final bool isHorizontal;

  SimpleInfo(
      {@required this.labelText,
      this.child,
      this.marginBottom = 7,
      this.marginBetween = 7,
      this.isHorizontal = false});

  @override
  Widget build(BuildContext context) {
    print("build ${this.runtimeType}");
    if (this.isHorizontal) return _getHorizontal();
    return _getVertical();
  }

  Widget _getVertical() {
    return Container(
      margin: EdgeInsets.only(bottom: marginBottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: marginBetween),
            child:
                Text(labelText, style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          child
        ],
      ),
    );
  }

  Widget _getHorizontal() {
    return Container(
      margin: EdgeInsets.only(bottom: marginBottom),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: marginBetween),
            child:
                Text(labelText, style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          child
        ],
      ),
    );
  }
}
