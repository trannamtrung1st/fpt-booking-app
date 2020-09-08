import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/helpers/color_helper.dart';

class AppTable extends StatelessWidget {
  final Map<int, TableColumnWidth> columnWidths;
  final List<AppTableRow> data;
  final double width;
  final EdgeInsets padding;

  AppTable({@required this.data, this.columnWidths, this.width, this.padding});

  @override
  Widget build(BuildContext context) {
    print("build ${this.runtimeType}");
    List<TableRow> rows = <TableRow>[];
    var headers = <Widget>[];
    var headerRow = data[0];
    for (dynamic o in headerRow.data)
      headers.add(_headerCell(content: o, onTap: headerRow.onTap));
    rows.add(TableRow(
        children: headers, decoration: BoxDecoration(color: Colors.orange)));

    for (int i = 1; i < data.length; i++) {
      var rowData = data[i];
      var cells = <Widget>[];
      for (dynamic o in rowData.data)
        cells.add(_tableCell(content: o, rowIdx: i, onTap: rowData.onTap));
      rows.add(TableRow(
          children: cells,
          decoration: BoxDecoration(
              color: i % 2 == 0 ? "#EEEEEE".toColor() : Colors.white)));
    }

    return SingleChildScrollView(
      padding: this.padding ?? EdgeInsets.fromLTRB(15, 0, 15, 0),
      scrollDirection: Axis.horizontal,
      child: Container(
        color: Colors.black,
        width: this.width ?? MediaQuery.of(context).size.width,
        child: Table(
          border: TableBorder.all(style: BorderStyle.none, width: 0),
          columnWidths: columnWidths,
          children: rows,
        ),
      ),
    );
  }

  Widget _headerCell({@required dynamic content, Function onTap}) {
    Widget child;
    if (content is String)
      child = Text(
        content,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      );
    else
      child = content;
    return GestureDetector(
        onTap: onTap,
        child: Container(padding: EdgeInsets.all(7), child: child));
  }

  Widget _tableCell(
      {@required dynamic content, @required int rowIdx, Function onTap}) {
    Widget child;
    if (content is String)
      child = Text(
        content,
        style: TextStyle(color: onTap != null ? Colors.blue : Colors.black),
      );
    else if (content is Map<String, Object>) {
      if (content.containsKey("display") && content.containsKey("iso"))
        child = Text(
          content["display"],
          style: TextStyle(color: onTap != null ? Colors.blue : Colors.black),
        );
    } else
      child = content;
    return GestureDetector(
      onTap: onTap,
      child:
          Container(padding: EdgeInsets.fromLTRB(7, 10, 7, 10), child: child),
    );
  }
}

class AppTableRow {
  List<dynamic> data;
  Function onTap;

  AppTableRow({this.data, this.onTap});
}
