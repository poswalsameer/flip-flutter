import 'package:flutter/material.dart';

class GameContainerComponent extends StatelessWidget {
  final String betResult;
  final bool betResultAwaiting;
  final bool isBetEnded;
  final double amountWon;
  final double multiplier;

  const GameContainerComponent({
    super.key,
    required this.betResult,
    required this.betResultAwaiting,
    required this.isBetEnded,
    required this.amountWon,
    required this.multiplier,
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

              // Bottom history part (placeholder)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  // History component will go here
                ),
              ),
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
