import 'package:flutter/widgets.dart';

class SimpleInfo extends StatelessWidget {
  final String labelText;
  final Widget child;
  final bool paddingBottom;

  SimpleInfo({@required this.labelText, this.child, this.paddingBottom = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: this.paddingBottom ? EdgeInsets.only(bottom: 7) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 7),
            child:
                Text(labelText, style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          child
        ],
      ),
    );
  }
}
