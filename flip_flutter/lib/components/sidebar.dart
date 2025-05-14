import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For local storage
// import 'package:audioplayers/audioplayers.dart'; // For sound effects
import 'dart:math' show pow, pi, max, Random;

class SidebarComponent extends StatefulWidget {
  final Function({
    required String betResult,
    required bool betResultAwaiting,
    required bool isBetEnded,
    required double amountWon,
    required double multiplier,
  }) onGameStateUpdate;
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
  // State variables
  bool isBetStarted = false;
  double betAmount = 0.0;
  bool isFirstClick = true;
  double walletBalance = 10000.0;
  List<String> currentBetResults = [];
  bool betResultAwaiting = false;
  int numberOfBets = 0;
  double amountWon = 0.0;
  final TextEditingController betAmountController = TextEditingController();
  
  // Audio players
  // final AudioPlayer betSoundPlayer = AudioPlayer();
  // final AudioPlayer cashoutSoundPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    loadWalletBalance();
    // setupAudioPlayers();
  }

  // Future<void> setupAudioPlayers() async {
  //   await betSoundPlayer.setSource(AssetSource('betButtonSound.mp3'));
  //   await cashoutSoundPlayer.setSource(AssetSource('cashoutSound.mp3'));
  // }

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
        const SnackBar(content: Text("Cannot place bet higher than your wallet balance. Please deposit!")),
      );
      return;
    }

    setState(() {
      walletBalance -= betAmount;
      isBetStarted = true;
    });
    
    // Update parent component about wallet balance change
    widget.onWalletBalanceUpdate(walletBalance);
    
    // Reset game state to clear winning screen, using empty string for betResult
    widget.onGameStateUpdate(
      betResult: "", // Changed from "heads" to empty string
      betResultAwaiting: false,
      isBetEnded: false,
      amountWon: 0.0,
      multiplier: 0.0,
    );
    
    saveWalletBalance();
  }

  Future<void> handleOptionClick(String option) async {
    // Update awaiting state
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

    // If random is selected, randomly choose heads or tails
    if (option == "random") {
      option = Random().nextInt(2) == 0 ? "heads" : "tails";
    }

    // Simulate delay for animation
    await Future.delayed(const Duration(seconds: 1));
    
    // Generate result (0 for heads, 1 for tails)
    final result = Random().nextInt(2) == 0 ? "heads" : "tails";
    
    // First update the game container with the result
    widget.onGameStateUpdate(
      betResult: result,
      betResultAwaiting: false,
      isBetEnded: result != option || numberOfBets >= 20,
      amountWon: result == option ? betAmount * pow(1.96, numberOfBets + 1) : 0.0,
      multiplier: result == option ? pow(1.96, numberOfBets + 1).toDouble() : 0.0,
    );

    // Then update the local state
    if (result == option) {
      // User won
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
      // User lost - update state and end bet
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
        // Notify parent about wallet balance change
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
    // First update the game container to show the winning screen
    widget.onGameStateUpdate(
      betResult: currentBetResults.last,
      betResultAwaiting: false,
      isBetEnded: true,
      amountWon: amountWon,
      multiplier: pow(1.96, numberOfBets).toDouble(),
    );

    // Then update the local state
    setState(() {
      walletBalance += amountWon;
      isBetStarted = false;
      isFirstClick = true;
      numberOfBets = 0;
      currentBetResults = [];
      amountWon = 0.0;
    });
    
    // Notify parent about wallet balance change
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
        const SnackBar(content: Text("Cannot double bet amount beyond wallet balance")),
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
          // Bet Amount Input Section
          _buildBetAmountSection(),
          
          // Profit Box
          if (isBetStarted) _buildProfitBox(),
          
          const SizedBox(height: 16),
          
          // Random Pick Button
          _buildRandomPickButton(),
          
          const SizedBox(height: 16),
          
          // Heads/Tails Buttons
          _buildHeadsTailsButtons(),
          
          const SizedBox(height: 16),
          
          // Bet/Cashout Button
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
                          const SnackBar(content: Text("Cannot enter amount greater than wallet balance")),
                        );
                        newAmount = walletBalance;
                        betAmountController.text = walletBalance.toStringAsFixed(2);
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
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
      onPressed: (!isBetStarted || betResultAwaiting) 
          ? null 
          : () => handleOptionClick("random"),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF283E4B),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
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
            onPressed: (!isBetStarted || betResultAwaiting)
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
            onPressed: (!isBetStarted || betResultAwaiting)
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
    final bool isDisabled = isBetStarted ? (isFirstClick || betResultAwaiting) : false;
    
    return ElevatedButton(
      onPressed: isBetStarted
          ? (isFirstClick || betResultAwaiting ? null : handleCashout)
          : handleBetStart,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return const Color(0xFF006400); // Darker green when disabled
            }
            return const Color(0xFF00E701); // Original green when enabled
          },
        ),
        minimumSize: WidgetStateProperty.all(
          const Size(double.infinity, 48),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
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
