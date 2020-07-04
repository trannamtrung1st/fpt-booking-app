import 'package:flutter/material.dart';
import 'package:fptbooking_app/contexts/login_context.dart';
import 'package:fptbooking_app/helpers/color_helper.dart';
import 'package:fptbooking_app/views/booking_view.dart';
import 'package:fptbooking_app/views/calendar_view.dart';
import 'package:fptbooking_app/views/main_view.dart';
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
];
final List<BottomNavigationBarItem> managerTabs =
    normalTabs.toList(growable: true);
bool initTabs = false;
final List<Widget> pages = <Widget>[
  CalendarView(),
  MainView(),
  BookingView(),
  MainView(),
];

class MainNav extends StatefulWidget {
  MainNav() {
    if (!initTabs) {
      initTabs = true;
      print("Init tabs");
      managerTabs.insert(
          1,
          BottomNavigationBarItem(
            icon: Icon(Icons.check),
            title: Text('Approval'),
          ));
    }
  }

  @override
  _MainNavState createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  LoginContext loginContext;
  _MainNavPresenter _presenter;

  static const int TAB_CALENDAR = 0;
  static const int TAB_APPROVAL = 1;
  static const int TAB_BOOKING = 2;
  static const int TAB_ROOM = 3;
  int _state = TAB_CALENDAR;

  void changeTab(int tab) {
    setState(() {
      _state = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    loginContext = Provider.of<LoginContext>(context);
    _presenter = _MainNavPresenter(view: this);
    return Scaffold(
      backgroundColor: "#F5F5F5".toColor(),
      body: IndexedStack(
        index: _state,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: loginContext.isManager() ? managerTabs : normalTabs,
        currentIndex: _presenter.getIndexFromTab(_state),
        selectedItemColor: Colors.orange,
        onTap: _presenter.onItemTapped,
      ),
    );
  }
}

class _MainNavPresenter {
  _MainNavState view;
  LoginContext _loginContext;

  _MainNavPresenter({this.view}) {
    _loginContext = view.loginContext;
  }

  void onItemTapped(int index) {
    int tabState = _getTabFromIndex(index);
    view.changeTab(tabState);
  }

  int _getTabFromIndex(int index) {
    if (!_loginContext.isManager()) return index != 0 ? index + 1 : index;
    return index;
  }

  int getIndexFromTab(int index) {
    if (!_loginContext.isManager()) return index != 0 ? index - 1 : index;
    return index;
  }
}
