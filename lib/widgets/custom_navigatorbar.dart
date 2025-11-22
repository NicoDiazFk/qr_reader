import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_reader/providers/ui_provider.dart';

class CustomNavigatorbar extends StatelessWidget {
  const CustomNavigatorbar({super.key});

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);

    final currentIndex = uiProvider.selectedMenuOpt;

    return BottomNavigationBar(
      onTap: (int i) => uiProvider.selectedMenuOpt = i,

      currentIndex: currentIndex,
      elevation: 0,

      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Ubicaciones'),

        BottomNavigationBarItem(
          icon: Icon(Icons.link),
          label: 'Direcciones',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.more),
          label: 'Otros',
        ),
      ],
    );
  }
}
