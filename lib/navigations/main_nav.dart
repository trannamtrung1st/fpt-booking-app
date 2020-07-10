import 'package:flutter/material.dart';
import 'package:fptbooking_app/contexts/login_context.dart';
import 'package:fptbooking_app/contexts/page_context.dart';
import 'package:fptbooking_app/helpers/color_helper.dart';
import 'package:fptbooking_app/views/approval_list_view.dart';
import 'package:fptbooking_app/views/booking_view.dart';
import 'package:fptbooking_app/views/calendar_view.dart';
import 'package:fptbooking_app/views/room_list_view.dart';
import 'package:fptbooking_app/views/settings_view.dart';
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
  SettingsView()
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

  static List<Widget> pages;

  static void Function({Widget widget, Type type}) navigate;

  @override
  _MainNavState createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  LoginContext loginContext;
  PageContext pageContext;
  _MainNavPresenter _presenter;
  PageController pageController = PageController(keepPage: true);

  static const int TAB_CALENDAR = 0;

//  static const int TAB_APPROVAL = 1;
//  static const int TAB_BOOKING = 2;
//  static const int TAB_ROOM = 3;
//  static const int TAB_SETTINGS = 4;
  int _state = TAB_CALENDAR;
  Widget replacementWidget;

  void changeTab(int tab) {
    setState(() {
      _state = tab;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loginContext = Provider.of<LoginContext>(context, listen: false);
    pageContext = Provider.of<PageContext>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    print("build ${this.runtimeType}");
    var tabs = loginContext.isManager() ? managerTabs : normalTabs;
    MainNav.pages = loginContext.isManager() ? managerPages : normalPages;
    if (loginContext.isViewOnlyUser()) {
      //not allowed booking
      for (var i = 0; i < tabs.length; i++) {
        if (MainNav.pages[i].runtimeType == BookingView) {
          MainNav.pages.removeAt(i);
          tabs.removeAt(i);
          i = tabs.length;
        }
      }
    }
    MainNav.navigate = ({Widget widget, Type type}) {
      type = type ?? widget.runtimeType;
      for (var i = 0; i < MainNav.pages.length; i++) {
        var rt = MainNav.pages[i].runtimeType;
        if (rt == type) {
          _presenter.onPageNavigation(i, widget);
          i = MainNav.pages.length;
        }
      }
    };
    _presenter = _MainNavPresenter(view: this);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: "#F5F5F5".toColor(),
        body: _getPageView(),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: tabs,
          currentIndex: _state,
          selectedItemColor: Colors.orange,
          onTap: _presenter.onItemTapped,
        ),
      ),
    );
  }

  Widget _getPageView() {
    var pages = MainNav.pages.toList();
    if (replacementWidget != null) {
      var tempWidget = this.replacementWidget;
      this.replacementWidget = null;
      for (var i = 0; i < pages.length; i++) {
        if (pages[i].runtimeType == tempWidget.runtimeType) {
          pages[i] = tempWidget;
          i = pages.length;
        }
      }
    }
    return PageView(
      physics: NeverScrollableScrollPhysics(),
      controller: pageController,
      children: pages,
      onPageChanged: _presenter.onPageChanged,
    );
  }
}

class _MainNavPresenter {
  _MainNavState view;

  _MainNavPresenter({this.view});

  void onItemTapped(int index) {
    view.pageController.jumpToPage(index);
  }

  void onPageNavigation(int index, Widget rWidget) {
    view.replacementWidget = rWidget;
    view.pageController.jumpToPage(index);
  }

  void onPageChanged(int tab) {
    view.pageContext.refreshIfNeeded(MainNav.pages[tab].runtimeType);
    view.changeTab(tab);
  }
}
