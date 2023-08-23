import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'screens/home.dart';
import 'screens/chatHistory.dart';
import 'screens/profile.dart';
class ButtonBarWidget extends StatefulWidget {
  const ButtonBarWidget({super.key});

  @override
  State<ButtonBarWidget> createState() => _ButtonBarWidgetState();
}

class _ButtonBarWidgetState extends State<ButtonBarWidget> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    ChatPage(),
    profilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: SizedBox(
          height: 60,
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home, size: 30,),
                // activeIcon: SvgPicture.asset('assets/bible_new_black.svg', height: 30,),
                label: 'home',
                // backgroundColor: Colors.blue,
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble, size: 25),
                // SvgPicture.asset('assets/images/chats.svg', height: 30,),
                // activeIcon: SvgPicture.asset('assets/bible_new_black.svg', height: 30,),
                label: 'Chats',
                // backgroundColor: Colors.blue,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person, size: 30),
                // Image.asset('assets/images/Setting.png'),
                // activeIcon: SvgPicture.asset('assets/hagah_new_black.svg', height: 30,),
                label: 'Setting',
                // backgroundColor: Colors.blue,
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.black,
            onTap: _onItemTapped,
          ),
        )
    );
  }
}