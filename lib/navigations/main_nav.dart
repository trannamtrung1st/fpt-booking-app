import 'package:flutter/material.dart';
import 'package:fptbooking_app/contexts/login_context.dart';
import 'package:fptbooking_app/contexts/page_context.dart';
import 'package:fptbooking_app/helpers/color_helper.dart';
import 'package:fptbooking_app/helpers/view_helper.dart';
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
final List<Screen> normalPages = <Screen>[
  Screen(
      widget: CalendarView(),
      title: "Calendar",
      icon: Icon(Icons.perm_contact_calendar)),
  Screen(
      widget: BookingView(),
      title: "Booking",
      icon: Icon(Icons.playlist_add_check)),
  Screen(widget: RoomListView(), title: "Room list", icon: Icon(Icons.home)),
  Screen(widget: SettingsView(), title: "Settings", icon: Icon(Icons.settings)),
];
final List<Screen> managerPages = normalPages.toList(growable: true);

class Screen {
  final Widget widget;
  final String title;
  final Icon icon;

  Screen({this.widget, this.title, this.icon});
}

class MainNav extends StatefulWidget {
  static void init() {
    print("Init tabs");
    managerTabs.insert(
        1,
        BottomNavigationBarItem(
          icon: Icon(Icons.check),
          title: Text('Approval'),
        ));
    managerPages.insert(
        1,
        Screen(
            widget: ApprovalListView(),
            title: "Approval",
            icon: Icon(Icons.check)));
  }

  static void Function({dynamic refreshParam, Type type}) navigate;

  @override
  _MainNavState createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  LoginContext loginContext;
  PageContext pageContext;
  _MainNavPresenter _presenter;
  PageController pageController = PageController(keepPage: true);
  List<Screen> pages;
  List<Widget> _pageWidgets;
  List<BottomNavigationBarItem> tabs;

  static const int TAB_CALENDAR = 0;

//  static const int TAB_APPROVAL = 1;
//  static const int TAB_BOOKING = 2;
//  static const int TAB_ROOM = 3;
//  static const int TAB_SETTINGS = 4;
  int _state = TAB_CALENDAR;

  void changeTab(int tab) {
    pageContext.currentTabWidgetType = _pageWidgets[_state].runtimeType;
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
    tabs =
        loginContext.isManager() ? managerTabs.toList() : normalTabs.toList();
    pages =
        loginContext.isManager() ? managerPages.toList() : normalPages.toList();
    if (loginContext.isViewOnlyUser()) {
      //not allowed booking
      for (var i = 0; i < tabs.length; i++) {
        if (pages[i].widget.runtimeType == BookingView) {
          pages.removeAt(i);
          tabs.removeAt(i);
          i = tabs.length;
        }
      }
    }
    _pageWidgets = pages.map((e) => e.widget).toList();
    MainNav.navigate = ({dynamic refreshParam, Type type}) {
      for (var i = 0; i < pages.length; i++) {
        var rt = pages[i].widget.runtimeType;
        if (rt == type) {
          _presenter.onPageNavigation(i, refreshParam);
          i = pages.length;
        }
      }
    };
    _presenter = _MainNavPresenter(view: this);
  }

  @override
  Widget build(BuildContext context) {
    print("build ${this.runtimeType}");
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: ViewHelper.getPageAppBar(
          title: pages[_state].title,
          icon: pages[_state].icon,
        ),
        backgroundColor: "#F5F5F5".toColor(),
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: pageController,
          children: _pageWidgets,
//          onPageChanged: ,
        ),
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
}

class _MainNavPresenter {
  _MainNavState view;

  _MainNavPresenter({this.view});

  void onItemTapped(int index) {
    view.pageController.jumpToPage(index);
    view.changeTab(index);
    view.pageContext.refreshIfNeeded(view.pages[index].widget.runtimeType);
  }

  void onPageNavigation(int index, dynamic refreshParam) {
    view.pageController.jumpToPage(index);
    view.changeTab(index);
    view.pageContext.refreshIfNeeded(view.pages[index].widget.runtimeType,
        refreshParam: refreshParam);
  }
}
