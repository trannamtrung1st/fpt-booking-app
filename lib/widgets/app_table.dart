import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/helpers/color_helper.dart';

class AppTable extends StatelessWidget {
  final Map<int, TableColumnWidth> columnWidths;
  final List<List<dynamic>> data;

  AppTable({@required this.data, this.columnWidths});

  @override
  Widget build(BuildContext context) {
    List<TableRow> rows = <TableRow>[];
    var headers = <Widget>[];
    var headerRow = data[0];
    for (dynamic o in headerRow) headers.add(_headerCell(content: o));
    rows.add(TableRow(children: headers));

    for (int i = 1; i < data.length; i++) {
      var rowData = data[i];
      var cells = <Widget>[];
      for (dynamic o in rowData) cells.add(_tableCell(content: o, rowIdx: i));
      rows.add(TableRow(children: cells));
    }

    return Table(
      border: TableBorder.all(style: BorderStyle.none, width: 0),
      columnWidths: columnWidths,
      children: rows,
    );
  }

  Widget _headerCell({@required dynamic content}) {
    Widget child;
    if (content is String)
      child = Text(
        content,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      );
    else
      child = content;
    return Container(
        color: Colors.orange, padding: EdgeInsets.all(7), child: child);
  }

  Widget _tableCell({@required dynamic content, @required int rowIdx}) {
    Widget child;
    if (content is String)
      child = Text(
        content,
        style: TextStyle(color: Colors.black),
      );
    else
      child = content;
    return Container(
        color: rowIdx % 2 == 0 ? "#EEEEEE".toColor() : Colors.white,
        padding: EdgeInsets.fromLTRB(7, 10, 7, 10),
        child: child);
  }
}
