import 'package:run4share/app/material.dart';
import 'package:run4share/app/theme/app_colors.dart';

/// The small amber "PRO" pill on things that need run4share Pro.
class ProBadge extends StatelessWidget {
  const ProBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.warning60,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'PRO',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.neutral0,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
