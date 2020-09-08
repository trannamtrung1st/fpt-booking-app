import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/helpers/view_helper.dart';
import 'package:fptbooking_app/widgets/app_card.dart';
import 'package:fptbooking_app/widgets/simple_info.dart';
import 'package:fptbooking_app/widgets/tag.dart';
import 'package:fptbooking_app/widgets/tags_container.dart';

class BookingDetailForm extends StatelessWidget {
  static const int FEEDBACK_IDX = 10;
  final dynamic data;
  final Widget feedbackWidget;
  final Widget managerMessage;
  final List<Widget> operations;
  final Widget changeRoomBtn;
  final Function(dynamic data) onRemoveService;

  BookingDetailForm(
      {@required this.data,
      @required this.feedbackWidget,
      this.onRemoveService,
      this.managerMessage,
      this.changeRoomBtn,
      this.operations});

  @override
  Widget build(BuildContext context) {
    print("build ${this.runtimeType}");
    var roomCodeWidgets = <Widget>[
      SelectableText(
        data["room"]["code"],
        style: TextStyle(color: Colors.blue),
      )
    ];
    if (changeRoomBtn != null) roomCodeWidgets.add(changeRoomBtn);
    var widgets = <Widget>[
      Text(
        "BOOKING INFORMATION",
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      SimpleInfo(
        labelText: 'Code',
        child: SelectableText(data["code"]),
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
      _getRequestedTimeStr(),
      _getTimeStr(),
      SimpleInfo(
        labelText: 'Number of people',
        child: SelectableText(data["num_of_people"].toString()),
      ),
      _getAttachedServicesTags(),
      SimpleInfo(
        labelText: 'Booking person',
        child: SelectableText(
          data["book_member"]["email"],
          style: TextStyle(color: Colors.blue),
        ),
      ),
      SimpleInfo(
        labelText: 'Using person(s)',
        child: SelectableText(
          (data["using_emails"] as List<dynamic>).join('\n'),
          style: TextStyle(color: Colors.blue),
        ),
      ),
      SimpleInfo(
        labelText: 'Note',
        child: SelectableText(
            (data["note"]?.isEmpty == true ? "Nothing" : data["note"]) ??
                "Nothing"),
      ),
    ];
    if (managerMessage != null) widgets.add(managerMessage);
    if (operations != null) widgets.addAll(operations);
    widgets.insert(FEEDBACK_IDX, feedbackWidget);

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
                child: SelectableText(e["name"]),
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
        labelText: 'Booked time',
        child: SelectableText(data["booked_date"]["display"] +
            ", " +
            data["from_time"] +
            " - " +
            data["to_time"]));
  }

  Widget _getRequestedTimeStr() {
    return SimpleInfo(
        labelText: 'Created time',
        child: SelectableText(data["sent_date"]["display"]));
  }
}
