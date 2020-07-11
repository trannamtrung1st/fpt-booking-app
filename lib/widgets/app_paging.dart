import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/helpers/paging_helper.dart';

class AppPaging extends StatelessWidget {
  final Function(int page) onPagePressed;
  final Paging paging;

  AppPaging({this.onPagePressed, this.paging});

  @override
  Widget build(BuildContext context) {
    var widgets = <Widget>[];
    if (paging.firstVisiblePage >= 2) {
      widgets.add(_pageBtn(1));
      widgets.add(_dotBtn());
    }
    for (var p in paging.visiblePages) {
      widgets.add(_pageBtn(p));
    }
    if (paging.lastVisiblePage <= paging.totalPages - 1) {
      widgets.add(_dotBtn());
      widgets.add(_pageBtn(paging.totalPages));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widgets,
    );
  }

  Widget _pageBtn(int page) {
    var isActive = paging.isActivePage(page);
    return Container(
      child: ButtonTheme(
        shape: CircleBorder(side: BorderSide.none),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minWidth: 0,
        child: FlatButton(
          onPressed: () => onPagePressed(page),
          color: isActive ? Colors.orangeAccent : Colors.grey[300],
          textColor: isActive ? Colors.white : Colors.black,
          child: Text(page.toString()),
        ),
      ),
    );
  }

  Widget _dotBtn() {
    return Container(
      child: ButtonTheme(
        shape: CircleBorder(side: BorderSide.none),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minWidth: 0,
        child: FlatButton(
          onPressed: () {},
          color: Colors.grey[300],
          textColor: Colors.black,
          child: Text('...'),
        ),
      ),
    );
  }
}
