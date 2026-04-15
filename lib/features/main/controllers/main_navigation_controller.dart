import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:my_havenly_application/core/controllers/auth_state_controller.dart';
import 'package:my_havenly_application/features/main/models/navigation_tab_model.dart';
import 'package:my_havenly_application/features/reservations/controllers/reservation_request_controller.dart';

class MainNavigationController extends GetxController {
  final AuthStateController _authStateController =
      Get.find<AuthStateController>();

  late PageController pageController;

  final List<NavigationTabModel> _allTabs = [];

  final RxList<NavigationTabModel> visibleTabs = <NavigationTabModel>[].obs;

  RxInt selectedTabIndex = 0.obs;

  final Map<String, Widget?> _contentCache = {};

  String? pendingInitialTabId;
  bool _initialTabApplied = false;

  @override
  void onInit() {
    super.onInit();

    pageController = PageController(initialPage: 0);

    _initializeTabs();

    _updateVisibleTabs();

    ever(_authStateController.isLoggedInRx, (_) => _updateVisibleTabs());
  }

  @override
  void onClose() {
    pageController.dispose();
    _contentCache.clear();
    super.onClose();
  }

  void _initializeTabs() {
    _allTabs.clear();
  }

  void initializeTabs(List<NavigationTabModel> tabs) {
    if (_allTabs.isNotEmpty) return;

    _allTabs.clear();
    _allTabs.addAll(tabs);
    _updateVisibleTabs();

    if (!_initialTabApplied && pendingInitialTabId != null) {
      applyInitialTab(pendingInitialTabId!);
      _initialTabApplied = true;
    }
  }

  void _updateVisibleTabs() {
    visibleTabs.value = List.from(_allTabs);

    if (selectedTabIndex.value >= visibleTabs.length) {
      selectedTabIndex.value = 0;
    }

    if (pageController.hasClients &&
        visibleTabs.length != _contentCache.length) {}
  }

  NavigationTabModel? getVisibleTab(int index) {
    if (index < 0 || index >= visibleTabs.length) return null;
    return visibleTabs[index];
  }

  NavigationTabModel? getTabById(String id) {
    try {
      return visibleTabs.firstWhere((tab) => tab.id == id);
    } catch (e) {
      return null;
    }
  }

  int? getVisibleTabIndexById(String id) {
    for (int i = 0; i < visibleTabs.length; i++) {
      if (visibleTabs[i].id == id) {
        return i;
      }
    }
    return null;
  }

  Widget? getTabContent(String tabId) {
    if (_contentCache.containsKey(tabId)) {
      return _contentCache[tabId];
    }

    NavigationTabModel? tab;
    try {
      tab = _allTabs.firstWhere((t) => t.id == tabId);
    } catch (e) {
      return null;
    }

    final content = tab.contentBuilder();

    _contentCache[tabId] = content;

    return content;
  }

  void setSelectedTab(int index, {bool animate = true}) {
    if (index < 0 || index >= visibleTabs.length) return;
    if (selectedTabIndex.value == index) return;

    final currentIndex = selectedTabIndex.value;
    final targetIndex = index;
    final distance = (targetIndex - currentIndex).abs();

    selectedTabIndex.value = index;

    _ensureSingleAttachment();

    final tab = visibleTabs[index];
    getTabContent(tab.id);

    if (pageController.hasClients) {
      if (animate && distance == 1) {
        pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        pageController.jumpToPage(index);
      }
    }
  }

  void navigateToTab(String tabId, {bool animate = true}) {
    final index = getVisibleTabIndexById(tabId);
    if (index != null) {
      setSelectedTab(index, animate: animate);

      if (tabId == 'reservations') {
        _refreshReservationsData();
      }
    }
  }

  void onPageChanged(int index) {
    _ensureSingleAttachment();
    if (index >= 0 && index < visibleTabs.length) {
      selectedTabIndex.value = index;

      final tab = visibleTabs[index];
      getTabContent(tab.id);

      if (tab.id == 'reservations') {
        _refreshReservationsData();
      }
    }
  }

  void _refreshReservationsData() {
    try {
      final reservationRequestController =
          Get.find<ReservationRequestController>();
      Future.delayed(const Duration(milliseconds: 300), () {
        reservationRequestController.fetchSentReservationRequests();
      });
    } catch (e) {}
  }

  void onHomePressed() {
    navigateToTab('home');
  }

  void onReservationsPressed() {
    navigateToTab('reservations');
  }

  void onExplorePressed() {
    navigateToTab('reservations');
  }

  void onDashboardPressed() {
    navigateToTab('dashboard');
  }

  void onFavoritePressed() {
    navigateToTab('favorite');
  }

  void onProfilePressed() {
    navigateToTab('profile');
  }

  void setSelectedBottomNav(int index, {bool animate = true}) {
    setSelectedTab(index, animate: animate);
  }

  void _ensureSingleAttachment() {
    try {
      if (pageController.positions.length > 1) {
        final currentIndex = selectedTabIndex.value;
        pageController.dispose();
        pageController = PageController(initialPage: currentIndex);
      }
    } catch (_) {}
  }

  void applyInitialTab(String tabId) {
    pendingInitialTabId = tabId;

    if (_allTabs.isEmpty) {
      return;
    }

    final index = getVisibleTabIndexById(tabId);
    if (index != null) {
      selectedTabIndex.value = index;

      final tab = visibleTabs[index];
      getTabContent(tab.id);

      if (pageController.hasClients) {
        pageController.jumpToPage(index);
      } else {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (pageController.hasClients) {
            final retryIndex = getVisibleTabIndexById(tabId);
            if (retryIndex != null) {
              selectedTabIndex.value = retryIndex;
              pageController.jumpToPage(retryIndex);
            }
          }
        });
      }
    }
  }
}
