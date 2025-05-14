import 'package:flutter/material.dart';
import 'components/header.dart';
import 'components/sidebar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/game_container.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coin Flip',
      theme: ThemeData(
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
  List<String> currentBetResults = [];

  @override
  void initState() {
    super.initState();
    loadWalletBalance();
  }

  Future<void> loadWalletBalance() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      walletBalance = prefs.getDouble('walletBalance') ?? 10000.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          HeaderComponent(walletBalance: walletBalance),

          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 300,
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

                        if (betResult.isNotEmpty) {
                          currentBetResults = [...currentBetResults, betResult];
                          if (currentBetResults.length > 20) {
                            currentBetResults = currentBetResults.sublist(
                              currentBetResults.length - 20,
                            );
                          }
                        }

                        // CLEARING THE BET HISTORY WHEN GAME ENDS/CASHOUT CLICKED
                        if (isBetEnded) {
                          currentBetResults = [];
                        }
                      });
                    },
                    onWalletBalanceUpdate: (newBalance) {
                      setState(() {
                        walletBalance = newBalance;
                      });
                    },
                    initialWalletBalance: walletBalance,
                  ),
                ),

                // GAME CONTAINER ON THE RIGHT SIDE
                Expanded(
                  child: GameContainerComponent(
                    betResult: betResult,
                    betResultAwaiting: betResultAwaiting,
                    isBetEnded: isBetEnded,
                    amountWon: amountWon,
                    multiplier: multiplier,
                    currentBetResults: currentBetResults,
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
