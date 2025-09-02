import 'package:flutter/material.dart';
import 'home_page.dart';
import 'bookmark_page.dart';
import 'simpan_page.dart';
import 'panduan_page.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int currentPageIndex = 0;

  Future<bool> _onWillPop() async {
  return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Keluar'),
            ),
          ],
        ),
      ) ??
      false;
}

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          indicatorColor: const Color(0xFF03a055),
          selectedIndex: currentPageIndex,
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.home_outlined, color: Color(0xFFFFFFFF)),
              icon: Icon(Icons.home_outlined, color: Color(0xFF03a055)),
              label: 'Home',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.bookmark_border_outlined, color: Color(0xFFFFFFFF)),
              icon: Icon(Icons.bookmark_border_outlined, color: Color(0xFF03a055)),
              label: 'Bookmark',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.save_outlined, color: Color(0xFFFFFFFF)),
              icon: Icon(Icons.save_sharp, color: Color(0xFF03a055)),
              label: 'Baca Offline',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.menu_book_outlined, color: Color(0xFFFFFFFF)),
              icon: Icon(Icons.menu_book_sharp, color: Color(0xFF03a055)),
              label: 'Panduan',
            ),
          ],
        ),
        body: [
          const Home(),
          const Bookmark(),
          const SimpanPage(),
          const PanduanPage(),
        ][currentPageIndex],
      ),
    );
  }
}
