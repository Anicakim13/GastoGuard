
import 'package:flutter/material.dart';

/// Budget Alert dialog matched to the GastoGuard UI/UX design.
class BudgetAlertDialog extends StatelessWidget {
  const BudgetAlertDialog({
    super.key,
    required this.alertMessage,
    required this.remainingMessage,
    this.onDismiss,
  });

  final String alertMessage;
  final String remainingMessage;
  final VoidCallback? onDismiss;

  static const Color _buttonGreen = Color(0xFF08804A);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.fromLTRB(24, 34, 24, 36),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.black, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/budget_alert_bell.png',
                width: 108,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 30),
              const Text(
                'Budget Alert!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                alertMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  height: 1.2,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                remainingMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  height: 1.2,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: onDismiss ?? () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _buttonGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                  child: const Text(
                    'Got it!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
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

Future<void> showBudgetAlertDialog(
  BuildContext context, {
  required String alertMessage,
  required String remainingMessage,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.30),
    builder: (_) => BudgetAlertDialog(
      alertMessage: alertMessage,
      remainingMessage: remainingMessage,
    ),
  );
}
