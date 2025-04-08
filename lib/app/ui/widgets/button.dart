import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyTextButton extends StatelessWidget {
  const MyTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height,
  });
  final String text;
  final VoidCallback? onPressed;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 45,
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          backgroundColor: WidgetStateProperty.resolveWith<Color>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.disabled)) {
              return context.theme.colorScheme.outlineVariant;
            }
            return context.theme.colorScheme.secondaryContainer.withAlpha(80);
          }),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
        ),
        onPressed: onPressed,
        child: Text(text, style: context.textTheme.titleMedium),
      ),
    );
  }
}
