import 'package:flutter/material.dart';
import 'game/ui/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BlockponsApp());
}

class BlockponsApp extends StatelessWidget {
  const BlockponsApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Blockpons',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF101827),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF59D6BB),
            brightness: Brightness.dark,
          ),
        ),
        home: const GameScreen(),
      );
}
