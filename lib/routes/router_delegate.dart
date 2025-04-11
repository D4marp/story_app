import 'package:flutter/material.dart';
import 'package:story_app/data/preferences/token.dart';
import 'package:story_app/page/add_story.dart';
import 'package:story_app/page/detail_story.dart';
import 'package:story_app/page/list_story.dart';
import 'package:story_app/page/login.dart';
import 'package:story_app/page/register.dart';
import 'package:story_app/page/splash_screen.dart';

class MyRouterDelegate extends RouterDelegate
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  bool? isLoggedIn;
  bool isRegister = false;
  bool isAddStory = false;
  String? storyId;

  List<Page> historyStack = [];

  MyRouterDelegate() {
    _initialize();
  }

  void _initialize() async {
    final tokenPref = Token();
    final token = await tokenPref.getToken();

    isLoggedIn = token.isNotEmpty;
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn == null) {
      historyStack = _splashStack;
    } else if (isLoggedIn == true) {
      historyStack = _loggedInStack;
    } else {
      historyStack = _loggedOutStack;
    }

    return Navigator(
      key: navigatorKey,
      pages: historyStack,
      onPopPage: (route, result) {
        final didPop = route.didPop(result);
        if (!didPop) return false;

        // Reset navigasi spesifik
        isRegister = false;
        isAddStory = false;
        storyId = null;
        notifyListeners();
        return true;
      },
    );
  }

  List<Page> get _splashStack => const [
        MaterialPage(
          key: ValueKey("SplashPage"),
          child: SplashPage(),
        ),
      ];

  List<Page> get _loggedOutStack => [
        MaterialPage(
          key: const ValueKey("LoginPage"),
          child: LoginPage(
            onLoginSuccess: () {
              isLoggedIn = true;
              notifyListeners();
            },
            onRegisterClicked: () {
              isRegister = true;
              notifyListeners();
            },
          ),
        ),
        if (isRegister)
          MaterialPage(
            key: const ValueKey("RegisterPage"),
            child: RegisterPage(
              onRegisterSuccess: () {
                isRegister = false;
                notifyListeners();
              },
            ),
          ),
      ];

  List<Page> get _loggedInStack => [
        MaterialPage(
          key: const ValueKey("ListStoryPage"),
          child: ListStoryPage(
            onLogoutSuccess: () {
              isLoggedIn = false;
              notifyListeners();
            },
            onStoryClicked: (String? id) {
              storyId = id;
              notifyListeners();
            },
            onAddStoryClicked: () {
              isAddStory = true;
              notifyListeners();
            },
          ),
        ),
        if (storyId != null)
          MaterialPage(
            key: const ValueKey("DetailStoryPage"),
            child: DetailStoryPage(
              storyId: storyId!,
              onCloseDetailPage: () {
                storyId = null;
                notifyListeners();
              },
            ),
          ),
        if (isAddStory)
          MaterialPage(
            key: const ValueKey("AddStoryPage"),
            child: AddStoryPage(
              onSuccessAddStory: () {
                isAddStory = false;
                notifyListeners();
              },
            ),
          ),
      ];

  @override
  Future<void> setNewRoutePath(configuration) async {
    // Kamu bisa menambahkan logika parsing route di sini jika menggunakan deep linking
    return;
  }
}
