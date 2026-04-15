import 'package:flutter/material.dart';

 
class NavigationTabModel {
   final String id;

   final IconData icon;

   final String labelKey;

   final Widget Function() contentBuilder;

  
  final List<String>? allowedRoles;

   final int index;

  NavigationTabModel({
    required this.id,
    required this.icon,
    required this.labelKey,
    required this.contentBuilder,
    this.allowedRoles,
    required this.index,
  });

   bool isVisibleForRole(String? role) {
     if (allowedRoles == null || allowedRoles!.isEmpty) {
      return true;
    }

     if (role == null) {
      return false;
    }

     return allowedRoles!.contains(role.toLowerCase());
  }

 
  static List<NavigationTabModel> getDefaultTabs({
    required Widget Function() homeBuilder,
    required Widget Function() reservationsBuilder,
    required Widget Function() dashboardBuilder,
    required Widget Function() favoriteBuilder,
    required Widget Function() profileBuilder,
  }) {
    return [
      NavigationTabModel(
        id: 'home',
        icon: Icons.home,
        labelKey: 'Home',
        contentBuilder: homeBuilder,
        allowedRoles: null, // Visible to all
        index: 0,
      ),
      NavigationTabModel(
        id: 'reservations',
        icon: Icons.event_note,
        labelKey: 'Reservations',
        contentBuilder: reservationsBuilder,
        allowedRoles: null, // Visible to all
        index: 1,
      ),
      NavigationTabModel(
        id: 'dashboard',
        icon: Icons.dashboard,
        labelKey: 'Dashboard',
        contentBuilder: dashboardBuilder,
        allowedRoles: null, // Visible to all (content will differ based on role)
        index: 2,
      ),
      NavigationTabModel(
        id: 'favorite',
        icon: Icons.favorite,
        labelKey: 'Favorite',
        contentBuilder: favoriteBuilder,
        allowedRoles: null, // Visible to all
        index: 3,
      ),
      NavigationTabModel(
        id: 'profile',
        icon: Icons.person,
        labelKey: 'Profile',
        contentBuilder: profileBuilder,
        allowedRoles: null, // Visible to all
        index: 4,
      ),
    ];
  }
}
