import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/helpers/view_helper.dart';
import 'package:fptbooking_app/widgets/app_card.dart';
import 'package:fptbooking_app/widgets/simple_info.dart';
import 'package:fptbooking_app/widgets/tag.dart';
import 'package:fptbooking_app/widgets/tags_container.dart';

class BookingDetailForm extends StatelessWidget {
  static const int FEEDBACK_IDX = 9;
  final dynamic data;
  final Widget Function() feedbackWidgetBuilder;
  final Widget Function() managerMessageBuilder;
  final List<Widget> Function() opsBuilder;
  final Widget Function() changeRoomBtnBuilder;
  final Function(dynamic data) onRemoveService;

  BookingDetailForm(
      {@required this.data,
      @required this.feedbackWidgetBuilder,
      this.onRemoveService,
      this.managerMessageBuilder,
      this.changeRoomBtnBuilder,
      this.opsBuilder});

  @override
  Widget build(BuildContext context) {
    var roomCodeWidgets = <Widget>[
      Text(
        data["room"]["code"],
        style: TextStyle(color: Colors.blue),
      )
    ];
    if (changeRoomBtnBuilder != null)
      roomCodeWidgets.add(changeRoomBtnBuilder());
    var widgets = <Widget>[
      Text(
        "BOOKING INFORMATION",
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      SimpleInfo(
        labelText: 'Room',
        child: Row(
          children: roomCodeWidgets,
        ),
      ),
      SimpleInfo(
        labelText: 'Status',
        child: ViewHelper.getTextByBookingStatus(status: data["status"]),
      ),
      _getTimeStr(),
      SimpleInfo(
        labelText: 'Number of people',
        child: Text(data["num_of_people"].toString()),
      ),
      _getAttachedServicesTags(),
      SimpleInfo(
        labelText: 'Booking person',
        child: Text(
          data["book_person"],
          style: TextStyle(color: Colors.blue),
        ),
      ),
      SimpleInfo(
        labelText: 'Using person(s)',
        child: Text(
          (data["using_person"] as List<dynamic>).join('\n'),
          style: TextStyle(color: Colors.blue),
        ),
      ),
      SimpleInfo(
        labelText: 'Note',
        child: Text(data["note"] ?? ""),
      ),
    ];
    if (managerMessageBuilder != null) widgets.add(managerMessageBuilder());
    if (opsBuilder != null) widgets.addAll(opsBuilder());
    var fbWidget = feedbackWidgetBuilder();
    widgets.insert(FEEDBACK_IDX, fbWidget);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: widgets,
      ),
    );
  }

  Widget _getAttachedServicesTags() {
    var services = data["attached_services"] as List<dynamic>;
    Widget widget = Text("Nothing");
    if (services != null) {
      var tags = services
          .map((e) => Tag(
                child: Text(e["name"]),
                onRemove:
                    onRemoveService != null ? () => onRemoveService(e) : null,
              ))
          .toList(growable: true);
      widget = TagsContainer(tags: tags);
    }
    return SimpleInfo(
      labelText: 'Attached services',
      child: widget,
    );
  }

  Widget _getTimeStr() {
    return SimpleInfo(
        labelText: 'Status',
        child: Text(data["booked_date"] +
            ", " +
            data["from_time"] +
            " - " +
            data["to_time"]));
  }
}
