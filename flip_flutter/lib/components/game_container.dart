import 'package:flutter/material.dart';

class GameContainerComponent extends StatelessWidget {
  final String betResult;
  final bool betResultAwaiting;
  final bool isBetEnded;
  final double amountWon;
  final double multiplier;
  final List<String> currentBetResults;

  const GameContainerComponent({
    super.key,
    required this.betResult,
    required this.betResultAwaiting,
    required this.isBetEnded,
    required this.amountWon,
    required this.multiplier,
    required this.currentBetResults,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F212E),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // MAIN COIN AREA
              Expanded(child: Center(child: _buildCoinArea())),

              // HISTORY OF BETS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: HistoryComponent(currentBetResults: currentBetResults),
              ),
              const SizedBox(height: 16),
            ],
          ),

          // WINNING SCREEN
          if (isBetEnded) _buildWinningOverlay(),
        ],
      ),
    );
  }

  Widget _buildCoinArea() {
    if (betResultAwaiting) {
      return const CoinAnimationComponent();
    } else if (betResult.isEmpty) {
      return const HeadsComponent();
    } else {
      return betResult == "heads"
          ? const HeadsComponent()
          : const TailsComponent();
    }
  }

  Widget _buildWinningOverlay() {
    return Center(
      child: Container(
        height: 144,
        width: 160,
        decoration: BoxDecoration(
          color: const Color(0xFF0F212E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF00E701), width: 6),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              multiplier == 0 ? "0.00x" : "${multiplier.toStringAsFixed(2)}x",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF00E701),
              ),
            ),
            const SizedBox(height: 12),
            Container(height: 1, width: 64, color: const Color(0xFF2F4553)),
            const SizedBox(height: 12),
            Text(
              "₹${amountWon.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00E701),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CoinAnimationComponent extends StatefulWidget {
  const CoinAnimationComponent({super.key});

  @override
  State<CoinAnimationComponent> createState() => _CoinAnimationComponentState();
}

class _CoinAnimationComponentState extends State<CoinAnimationComponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159, // 360 DEGREES ROTATION
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double size = 192;

    if (screenWidth > 640) {
      size = 288;
    }

    if (screenWidth > 1536) {
      size = 320;
    }

    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform(
            transform:
                Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // PERSPECTIVE
                  ..rotateY(_animation.value),
            alignment: Alignment.center,
            child:
                _animation.value < 3.14159
                    ? const HeadsComponent()
                    : Transform(
                      transform: Matrix4.identity()..rotateY(3.14159),
                      alignment: Alignment.center,
                      child: const TailsComponent(),
                    ),
          );
        },
      ),
    );
  }
}

class HeadsComponent extends StatelessWidget {
  const HeadsComponent({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double size = 192;
    double innerPadding = 56;

    if (screenWidth > 640) {
      size = 288;
      innerPadding = 80;
    }

    if (screenWidth > 1536) {
      size = 320;
      innerPadding = 112;
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
          ),

          Padding(
            padding: EdgeInsets.all(innerPadding),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0F212E),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TailsComponent extends StatelessWidget {
  const TailsComponent({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double size = 192;
    double innerPadding = 64;

    if (screenWidth > 640) {
      size = 288;
      innerPadding = 96;
    }

    if (screenWidth > 1536) {
      size = 320;
      innerPadding = 112;
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF4D6FFF),
              shape: BoxShape.circle,
            ),
          ),

          Padding(
            padding: EdgeInsets.all(innerPadding),
            child: Transform.rotate(
              angle: 45 * 3.14159 / 180,
              child: Container(
                decoration: const BoxDecoration(color: Color(0xFF0F212E)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryComponent extends StatelessWidget {
  final List<String> currentBetResults;

  const HistoryComponent({super.key, required this.currentBetResults});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF213743),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 2),
            child: Text(
              'History',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 40,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF071D2A),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(20, (index) {
                final result =
                    index < currentBetResults.length
                        ? currentBetResults[index]
                        : null;

                return _buildHistoryItem(result);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String? result) {
    if (result == null) {
      return Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          color: Color(0xFF0F212E),
          shape: BoxShape.circle,
        ),
      );
    }

    if (result == 'heads') {
      return Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
        ),
      );
    } else {
      return Transform.rotate(
        angle: 45 * 3.14159 / 180,
        child: Container(width: 8, height: 8, color: const Color(0xFF4D6FFF)),
      );
    }
  }
}
