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
              // Top coin flip area
              Expanded(
                child: Center(
                  child: _buildCoinArea(),
                ),
              ),

              // Bottom history part
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: HistoryComponent(
                  currentBetResults: currentBetResults,
                ),
              ),
              const SizedBox(height: 16), // Add some bottom padding
            ],
          ),

          // Winning screen overlay
          if (isBetEnded) _buildWinningOverlay(),
        ],
      ),
    );
  }

  Widget _buildCoinArea() {
    if (betResultAwaiting) {
      return const CoinAnimationComponent();
    } else {
      return betResult == "heads" 
          ? const HeadsComponent() 
          : const TailsComponent();
    }
  }

  Widget _buildWinningOverlay() {
    return Center(
      child: Container(
        height: 144, // 36 * 4 (converting from rem/tailwind units)
        width: 160, // 40 * 4
        decoration: BoxDecoration(
          color: const Color(0xFF0F212E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF00E701),
            width: 6,
          ),
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
            Container(
              height: 1,
              width: 64, // 40% of container width
              color: const Color(0xFF2F4553),
            ),
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

// Placeholder components - you'll need to implement these
class CoinAnimationComponent extends StatelessWidget {
  const CoinAnimationComponent({super.key});

  @override
  Widget build(BuildContext context) {
    // Implement coin animation
    return const Center(child: CircularProgressIndicator());
  }
}

class HeadsComponent extends StatelessWidget {
  const HeadsComponent({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the screen width to make responsive sizes
    double screenWidth = MediaQuery.of(context).size.width;
    
    // Determine size based on screen width
    double size = 192; // Default size (w-48 = 12rem = 192px)
    double innerPadding = 56; // Default padding (inset-14 = 3.5rem = 56px)
    
    if (screenWidth > 640) { // sm and above
      size = 288; // w-72 = 18rem = 288px
      innerPadding = 80; // inset-20 = 5rem = 80px
    }
    
    if (screenWidth > 1536) { // 2xl
      size = 320; // w-80 = 20rem = 320px
      innerPadding = 112; // inset-28 = 7rem = 112px
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Outer circle
          Container(
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          
          // Inner circle
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
    // Get the screen width to make responsive sizes
    double screenWidth = MediaQuery.of(context).size.width;
    
    // Determine size based on screen width
    double size = 192; // Default size (w-48 = 12rem = 192px)
    double innerPadding = 64; // Default padding (inset-16 = 4rem = 64px)
    
    if (screenWidth > 640) { // sm and above
      size = 288; // w-72 = 18rem = 288px
      innerPadding = 96; // inset-24 = 6rem = 96px
    }
    
    if (screenWidth > 1536) { // 2xl
      size = 320; // w-80 = 20rem = 320px
      innerPadding = 112; // inset-28 = 7rem = 112px
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Outer circle
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF4D6FFF),
              shape: BoxShape.circle,
            ),
          ),
          
          // Inner square (rotated)
          Padding(
            padding: EdgeInsets.all(innerPadding),
            child: Transform.rotate(
              angle: 45 * 3.14159 / 180,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF0F212E),
                ),
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

  const HistoryComponent({
    super.key,
    required this.currentBetResults,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96, // h-24 = 6rem = 96px
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
                final result = index < currentBetResults.length 
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
        child: Container(
          width: 8,
          height: 8,
          color: const Color(0xFF4D6FFF),
        ),
      );
    }
  }
}
