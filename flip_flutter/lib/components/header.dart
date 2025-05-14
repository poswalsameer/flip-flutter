import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // You'll need to add provider package to pubspec.yaml

class HeaderComponent extends StatelessWidget {
  final double walletBalance;

  const HeaderComponent({
    super.key,
    required this.walletBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 64, // equivalent to h-16
      color: const Color(0xFF1A2C38), // equivalent to bg-[#1a2c38]
      child: Center(
        child: Container(
          height: 48, // equivalent to h-12
          width: 192, // equivalent to w-48
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 60, // equivalent to w-[60%]
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F212E), // equivalent to bg-[#0f212e]
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      bottomLeft: Radius.circular(6),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '₹${walletBalance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14, // equivalent to text-sm
                        fontWeight: FontWeight.w600, // equivalent to font-semibold
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 40, // equivalent to w-[40%]
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.blue, // equivalent to bg-blue-500
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Wallet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14, // equivalent to text-sm
                        fontWeight: FontWeight.w600, // equivalent to font-semibold
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
