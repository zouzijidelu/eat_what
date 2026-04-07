import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../api/api_client.dart';
import '../api/api_models.dart';
import 'plan_detail_screen.dart';
import '../widgets/card_container.dart';

class PlanListScreen extends StatelessWidget {
  const PlanListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          bottom: false, // 移除底部安全区域以避免额外空间
          child: Column(
            children: [
              const SizedBox(height: 12),
              _buildHeader(context),
              const SizedBox(height: 16),
              Expanded( // 使用Expanded让内容填充剩余空间
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CardContainer(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('为你精选', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                                    Text('点卡片进入计划详情', style: TextStyle(fontSize: 12, color: AppColors.slate500)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            FutureBuilder<DietPlanListPayload>(
                              future: ApiClient.instance.getDietPlanList(page: 1, limit: 10),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState != ConnectionState.done) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }
                                final plans = snapshot.data?.list ?? const <DietPlanSummary>[];
                                if (plans.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.only(bottom: 12),
                                    child: Text('暂无计划', style: TextStyle(color: AppColors.slate600)),
                                  );
                                }
                                return Column(
                                  children: plans.map(
                                    (p) => Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: _PlanCard(
                                        plan: p,
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => PlanDetailScreen(plan: p)),
                                        ),
                                      ),
                                    ),
                                  ).toList(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 20),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
              border: Border.all(color: AppColors.rose100.withValues(alpha: 0.8)),
            ),
            child: const Center(child: Text('‹', style: TextStyle(fontSize: 24, height: 1))),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('饮食计划', style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              )),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  final DietPlanSummary plan;
  final VoidCallback onTap;

  const _PlanCard({required this.plan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: AppColors.ink.withValues(alpha: 0.06), blurRadius: 4)],
          border: Border.all(color: AppColors.rose100.withValues(alpha: 0.7)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                ApiClient.absoluteUrl(plan.image),
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(plan.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.brand50,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.brand500.withValues(alpha: 0.18)),
                        ),
                        child: Text('${plan.dayCount} 天', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.brand600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('周期：${plan.cycle}，累计${plan.userCount}人使用', style: TextStyle(fontSize: 12, color: AppColors.slate600), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(width: 80, height: 80, color: AppColors.slate200, child: const Icon(Icons.image_not_supported));
}