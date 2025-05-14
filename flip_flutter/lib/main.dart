import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'components/header.dart';
import 'components/sidebar.dart';
import 'components/game_container.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String betResult = "heads";
  bool betResultAwaiting = false;
  bool isBetEnded = false;
  double amountWon = 0.0;
  double multiplier = 0.0;
  double walletBalance = 10000.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Pass wallet balance to header
          HeaderComponent(walletBalance: walletBalance),
          
          // Main content area takes remaining height
          Expanded(
            child: Row(
              children: [
                // Sidebar takes 30% width
                SizedBox(
                  width: 300, // Fixed width for larger screens
                  child: SidebarComponent(
                    onGameStateUpdate: ({
                      required String betResult,
                      required bool betResultAwaiting,
                      required bool isBetEnded,
                      required double amountWon,
                      required double multiplier,
                    }) {
                      setState(() {
                        this.betResult = betResult;
                        this.betResultAwaiting = betResultAwaiting;
                        this.isBetEnded = isBetEnded;
                        this.amountWon = amountWon;
                        this.multiplier = multiplier;
                      });
                    },
                    onWalletBalanceUpdate: (newBalance) {
                      setState(() {
                        walletBalance = newBalance;
                      });
                    },
                  ),
                ),
                
                // Game container takes remaining width
                Expanded(
                  child: GameContainerComponent(
                    betResult: betResult,
                    betResultAwaiting: betResultAwaiting,
                    isBetEnded: isBetEnded,
                    amountWon: amountWon,
                    multiplier: multiplier,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
