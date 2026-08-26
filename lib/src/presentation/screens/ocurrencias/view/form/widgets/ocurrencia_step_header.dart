import 'package:flutter/material.dart';

class OcurrenciaStepHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final ValueChanged<int> onStepPressed;

  const OcurrenciaStepHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.onStepPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final safeTotalSteps = totalSteps < 1 ? 1 : totalSteps;
    final safeCurrentStep = currentStep.clamp(0, safeTotalSteps - 1);

    final progress = (safeCurrentStep + 1) / safeTotalSteps;

    return Material(
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          children: [
            // ==================================================
            // INDICADOR CIRCULAR DE STEPS
            // ==================================================
            Row(
              children: List.generate(safeTotalSteps, (index) {
                final selected = index == safeCurrentStep;
                final completed = index < safeCurrentStep;
                final enabled = index <= safeCurrentStep;
                final isLast = index == safeTotalSteps - 1;

                return Expanded(
                  flex: isLast ? 0 : 1,
                  child: Row(
                    children: [
                      _StepCircle(
                        stepNumber: index + 1,
                        selected: selected,
                        completed: completed,
                        enabled: enabled,
                        onPressed: enabled ? () => onStepPressed(index) : null,
                      ),

                      // Línea que conecta los círculos
                      if (!isLast)
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            height: 3,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              color: index < safeCurrentStep
                                  ? colors.primary
                                  : colors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),

            const SizedBox(height: 12),

            // ==================================================
            // INFORMACIÓN DEL STEP
            // ==================================================
            Row(
              children: [
                Text(
                  'Paso ${safeCurrentStep + 1} de $safeTotalSteps',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(progress * 100).round()}%',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CÍRCULO DEL STEP
// ============================================================

class _StepCircle extends StatelessWidget {
  final int stepNumber;
  final bool selected;
  final bool completed;
  final bool enabled;
  final VoidCallback? onPressed;

  const _StepCircle({
    required this.stepNumber,
    required this.selected,
    required this.completed,
    required this.enabled,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final backgroundColor = selected || completed
        ? colors.primary
        : colors.surfaceContainerHighest;

    final foregroundColor = selected || completed
        ? colors.onPrimary
        : enabled
        ? colors.onSurfaceVariant
        : colors.outline;

    final borderColor = selected
        ? colors.primary
        : completed
        ? colors.primary
        : colors.outlineVariant;

    final circleSize = selected ? 30.0 : 24.0;// 40.0 : 34.0;

    return Semantics(
      button: enabled,
      enabled: enabled,
      selected: selected,
      label: completed
          ? 'Paso $stepNumber completado'
          : selected
          ? 'Paso $stepNumber actual'
          : 'Paso $stepNumber pendiente',
      child: Tooltip(
        message: completed
            ? 'Volver al paso $stepNumber'
            : selected
            ? 'Paso actual'
            : 'Completa los pasos anteriores',
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: circleSize,
              height: circleSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor,
                  width: selected ? 3 : 1.5,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: colors.primary.withAlpha(60),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: completed
                    ? Icon(
                        Icons.check_rounded,
                        key: ValueKey('completed-$stepNumber'),
                        size: 20,
                        color: foregroundColor,
                      )
                    : Text(
                        '$stepNumber',
                        key: ValueKey('number-$stepNumber'),
                        style: TextStyle(
                          color: foregroundColor,
                          fontSize: selected ? 15 : 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';

// class OcurrenciaStepHeader extends StatelessWidget {
//   final int currentStep;
//   final int totalSteps;
//   final ValueChanged<int> onStepPressed;

//   const OcurrenciaStepHeader({
//     super.key,
//     required this.currentStep,
//     required this.totalSteps,
//     required this.onStepPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final colors = Theme.of(context).colorScheme;

//     return Material(
//       color: colors.surface,
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
//         child: Column(
//           children: [
//             Row(
//               children: List.generate(totalSteps, (index) {
//                 final selected = index == currentStep;
//                 final completed = index < currentStep;

//                 return Expanded(
//                   child: InkWell(
//                     onTap: index <= currentStep
//                         ? () => onStepPressed(index)
//                         : null,
//                     child: Container(
//                       height: 6,
//                       margin: EdgeInsets.only(
//                         right: index < totalSteps - 1 ? 6 : 0,
//                       ),
//                       decoration: BoxDecoration(
//                         color: selected || completed
//                             ? colors.primary
//                             : colors.surfaceContainerHighest,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                 );
//               }),
//             ),
//             const SizedBox(height: 10),
//             Row(
//               children: [
//                 Text(
//                   'Paso ${currentStep + 1} de $totalSteps',
//                   style: Theme.of(context).textTheme.labelLarge?.copyWith(
//                     color: colors.primary,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 const Spacer(),
//                 Text(
//                   '${((currentStep + 1) / totalSteps * 100).round()}%',
//                   style: Theme.of(context).textTheme.labelMedium,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
