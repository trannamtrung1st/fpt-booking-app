import 'package:flutter/material.dart';
import 'package:fptbooking_app/contexts/login_context.dart';
import 'package:fptbooking_app/helpers/color_helper.dart';
import 'package:fptbooking_app/views/approval_list_view.dart';
import 'package:fptbooking_app/views/booking_view.dart';
import 'package:fptbooking_app/views/calendar_view.dart';
import 'package:fptbooking_app/views/main_view.dart';
import 'package:fptbooking_app/views/room_list_view.dart';
import 'package:provider/provider.dart';

final List<BottomNavigationBarItem> normalTabs = <BottomNavigationBarItem>[
  BottomNavigationBarItem(
    icon: Icon(Icons.perm_contact_calendar),
    title: Text('Calendar'),
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.playlist_add_check),
    title: Text('Booking'),
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.home),
    title: Text('Room'),
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.settings),
    title: Text('Settings'),
  ),
];
final List<BottomNavigationBarItem> managerTabs =
    normalTabs.toList(growable: true);
final List<Widget> normalPages = <Widget>[
  CalendarView(),
  BookingView(),
  RoomListView(),
  MainView()
];
final List<Widget> managerPages = normalPages.toList(growable: true);

class MainNav extends StatefulWidget {
  static void init() {
    print("Init tabs");
    managerTabs.insert(
        1,
        BottomNavigationBarItem(
          icon: Icon(Icons.check),
          title: Text('Approval'),
        ));
    managerPages.insert(1, ApprovalListView());
  }

  @override
  _MainNavState createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  LoginContext loginContext;
  _MainNavPresenter _presenter;
  PageController pageController = PageController(keepPage: true);

  static const int TAB_CALENDAR = 0;

//  static const int TAB_APPROVAL = 1;
//  static const int TAB_BOOKING = 2;
//  static const int TAB_ROOM = 3;
//  static const int TAB_SETTINGS = 4;
  int _state = TAB_CALENDAR;

  void changeTab(int tab) {
    setState(() {
      _state = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    loginContext = Provider.of<LoginContext>(context, listen: false);
    _presenter = _MainNavPresenter(view: this);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: "#F5F5F5".toColor(),
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: pageController,
          children: loginContext.isManager() ? managerPages : normalPages,
          onPageChanged: _presenter.onPageChanged,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: loginContext.isManager() ? managerTabs : normalTabs,
          currentIndex: _state,
          selectedItemColor: Colors.orange,
          onTap: _presenter.onItemTapped,
        ),
      ),
    );
  }
}

class _MainNavPresenter {
  _MainNavState view;

  _MainNavPresenter({this.view});

  void onItemTapped(int index) {
    view.pageController.jumpToPage(index);
  }

  void onPageChanged(int tab) {
    view.changeTab(tab);
  }
}
