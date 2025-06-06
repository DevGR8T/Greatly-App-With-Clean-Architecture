import 'package:flutter/material.dart';

class CheckoutProgressIndicator extends StatelessWidget {
  final int currentStep;
  
  const CheckoutProgressIndicator({
    Key? key,
    required this.currentStep,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const steps = [
      'Address',
      'Payment',
      'Review',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          // If it's an even index, render a step
          if (index % 2 == 0) {
            final stepIndex = index ~/ 2;
            return Expanded(
              child: _buildStep(
                context,
                steps[stepIndex],
                stepIndex,
              ),
            );
          }
          // Otherwise, render a separator
          return _buildSeparator(context, index ~/ 2);
        }),
      ),
    );
  }

  Widget _buildStep(BuildContext context, String label, int stepIndex) {
    final isActive = stepIndex == currentStep;
    final isCompleted = stepIndex < currentStep;
    
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? Theme.of(context).primaryColor
                : isCompleted
                    ? Theme.of(context).primaryColor.withOpacity(0.7)
                    : Colors.grey.shade300,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 18,
                  )
                : Text(
                    '${stepIndex + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive
                ? Theme.of(context).primaryColor
                : isCompleted
                    ? Colors.black
                    : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator(BuildContext context, int beforeStep) {
    final isActive = beforeStep < currentStep;
    
    return Expanded(
      child: Container(
        height: 2,
        color: isActive
            ? Theme.of(context).primaryColor
            : Colors.grey.shade300,
      ),
    );
  }
}