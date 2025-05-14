import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' show pow, pi, max, Random;

class SidebarComponent extends StatefulWidget {
  final Function({
    required String betResult,
    required bool betResultAwaiting,
    required bool isBetEnded,
    required double amountWon,
    required double multiplier,
  })
  onGameStateUpdate;
  final Function(double newBalance) onWalletBalanceUpdate;

  const SidebarComponent({
    super.key,
    required this.onGameStateUpdate,
    required this.onWalletBalanceUpdate,
  });

  @override
  State<SidebarComponent> createState() => _SidebarComponentState();
}

class _SidebarComponentState extends State<SidebarComponent> {
  // STATES
  bool isBetStarted = false;
  double betAmount = 0.0;
  bool isFirstClick = true;
  double walletBalance = 10000.0;
  List<String> currentBetResults = [];
  bool betResultAwaiting = false;
  int numberOfBets = 0;
  double amountWon = 0.0;
  final TextEditingController betAmountController = TextEditingController();

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

  void handleBetStart() {
    if (betAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot place a bet less than Rs.0")),
      );
      return;
    }
    if (betAmount > walletBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Cannot place bet higher than your wallet balance. Please deposit!",
          ),
        ),
      );
      return;
    }

    setState(() {
      walletBalance -= betAmount;
      isBetStarted = true;
    });

    widget.onWalletBalanceUpdate(walletBalance);

    // RESETTING EVERY STATE WHEN BET BUTTON CLICKED
    widget.onGameStateUpdate(
      betResult: "",
      betResultAwaiting: false,
      isBetEnded: false,
      amountWon: 0.0,
      multiplier: 0.0,
    );

    saveWalletBalance();
  }

  Future<void> handleOptionClick(String option) async {
    setState(() {
      isFirstClick = false;
      betResultAwaiting = true;
    });

    widget.onGameStateUpdate(
      betResult: "",
      betResultAwaiting: true,
      isBetEnded: false,
      amountWon: amountWon,
      multiplier: pow(1.96, numberOfBets).toDouble(),
    );

    // IF USER SELECTS RANDOM, CHOOSE RANDOMLY
    if (option == "random") {
      option = Random().nextInt(2) == 0 ? "heads" : "tails";
    }

    // DELAY TO SHOW COIN ANIMATION
    await Future.delayed(const Duration(seconds: 1));

    // 0 -> HEADS, 1-> TAILS
    final result = Random().nextInt(2) == 0 ? "heads" : "tails";

    widget.onGameStateUpdate(
      betResult: result,
      betResultAwaiting: false,
      isBetEnded: result != option || numberOfBets >= 20,
      amountWon:
          result == option ? betAmount * pow(1.96, numberOfBets + 1) : 0.0,
      multiplier:
          result == option ? pow(1.96, numberOfBets + 1).toDouble() : 0.0,
    );

    if (result == option) {
      setState(() {
        betResultAwaiting = false;
        currentBetResults.add(result);
        numberOfBets++;
        amountWon = betAmount * pow(1.96, numberOfBets);
      });

      if (numberOfBets >= 20) {
        endBet(true);
      }
    } else {
      setState(() {
        betResultAwaiting = false;
        currentBetResults.add(result);
      });
      endBet(false);
    }
  }

  void endBet(bool won) {
    setState(() {
      if (won) {
        walletBalance += amountWon;
        widget.onWalletBalanceUpdate(walletBalance);
        saveWalletBalance();
      }

      isBetStarted = false;
      isFirstClick = true;
      numberOfBets = 0;
      currentBetResults = [];
      amountWon = 0.0;
    });

    widget.onGameStateUpdate(
      betResult: currentBetResults.last,
      betResultAwaiting: false,
      isBetEnded: true,
      amountWon: won ? amountWon : 0.0,
      multiplier: won ? pow(1.96, numberOfBets).toDouble() : 0.0,
    );
  }

  void handleCashout() {
    widget.onGameStateUpdate(
      betResult: currentBetResults.last,
      betResultAwaiting: false,
      isBetEnded: true,
      amountWon: amountWon,
      multiplier: pow(1.96, numberOfBets).toDouble(),
    );

    setState(() {
      walletBalance += amountWon;
      isBetStarted = false;
      isFirstClick = true;
      numberOfBets = 0;
      currentBetResults = [];
      amountWon = 0.0;
    });

    widget.onWalletBalanceUpdate(walletBalance);
    saveWalletBalance();
  }

  Future<void> saveWalletBalance() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('walletBalance', walletBalance);
  }

  void handleDoubleAmount() {
    final newAmount = betAmount * 2;
    if (newAmount > walletBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot double bet amount beyond wallet balance"),
        ),
      );
      return;
    }
    setState(() {
      betAmount = newAmount;
      betAmountController.text = newAmount.toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF213743),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // BET AMOUNT COMPONENT
          _buildBetAmountSection(),

          // Profit Box
          if (isBetStarted) _buildProfitBox(),

          const SizedBox(height: 16),

          // RANDOM PICK BUTTON
          _buildRandomPickButton(),

          const SizedBox(height: 16),

          // HEADS TAILS BUTTON
          _buildHeadsTailsButtons(),

          const SizedBox(height: 16),

          // BET/CASHOUT BUTTON
          _buildBetButton(),
        ],
      ),
    );
  }

  Widget _buildBetAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bet Amount',
          style: TextStyle(
            color: Color(0xFFB1BACA),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF2F4553),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 7,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F212E),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                    ),
                  ),
                  child: TextField(
                    controller: betAmountController,
                    enabled: !isBetStarted,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0xFF0F212E),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onChanged: (value) {
                      double newAmount = double.tryParse(value) ?? 0.0;
                      if (newAmount > walletBalance) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Cannot enter amount greater than wallet balance",
                            ),
                          ),
                        );
                        newAmount = walletBalance;
                        betAmountController.text = walletBalance
                            .toStringAsFixed(2);
                      }
                      setState(() {
                        betAmount = newAmount;
                      });
                    },
                  ),
                ),
              ),
              _buildAmountButton("1/2", () {
                setState(() {
                  betAmount = max(0.0, betAmount / 2);
                  betAmountController.text = betAmount.toStringAsFixed(2);
                });
              }),
              _buildAmountButton("2x", () {
                setState(() {
                  betAmount = betAmount * 2;
                  betAmountController.text = betAmount.toStringAsFixed(2);
                });
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountButton(String text, VoidCallback onPressed) {
    return Expanded(
      flex: 3,
      child: TextButton(
        onPressed: isBetStarted ? null : onPressed,
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFF2F4553),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildProfitBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Total Profit (${isFirstClick ? "1.00x" : (pow(1.96, numberOfBets)).toStringAsFixed(2)}x)',
          style: const TextStyle(
            color: Color(0xFFB1BACA),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 40,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF2F4553),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            (betAmount * pow(1.96, numberOfBets)).toStringAsFixed(2),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRandomPickButton() {
    return ElevatedButton(
      onPressed:
          (!isBetStarted || betResultAwaiting)
              ? null
              : () => handleOptionClick("random"),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF283E4B),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: const Text(
        'Pick Random Side',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildHeadsTailsButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed:
                (!isBetStarted || betResultAwaiting)
                    ? null
                    : () => handleOptionClick("heads"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF283E4B),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Heads',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 16,
                  width: 16,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed:
                (!isBetStarted || betResultAwaiting)
                    ? null
                    : () => handleOptionClick("tails"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF283E4B),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Tails',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Transform.rotate(
                  angle: 45 * pi / 180,
                  child: Container(
                    height: 12,
                    width: 12,
                    color: const Color(0xFF4D6FFF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBetButton() {
    return ElevatedButton(
      onPressed:
          isBetStarted
              ? (isFirstClick || betResultAwaiting ? null : handleCashout)
              : handleBetStart,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return const Color(0xFF006400);
          }
          return const Color(0xFF00E701);
        }),
        minimumSize: WidgetStateProperty.all(const Size(double.infinity, 48)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      child: Text(
        isBetStarted ? 'Cashout' : 'Bet',
        style: const TextStyle(
          color: Color(0xFF05080A),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
