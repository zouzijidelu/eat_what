import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../api/api_client.dart';
import '../api/api_models.dart';
import 'recipe_detail_screen.dart';
import 'food_detail_screen.dart';
import '../widgets/card_container.dart';

class PlanDetailScreen extends StatefulWidget {
  final DietPlanSummary plan;

  const PlanDetailScreen({super.key, required this.plan});

  @override
  State<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends State<PlanDetailScreen> {
  int _activeDay = 1;
  Future<DietPlanDetailPayload>? _futureDetail;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _futureDetail = ApiClient.instance.getDietPlanDetail(id: widget.plan.id, day: _activeDay);
  }

  void _onDayTap(int day) {
    setState(() => _activeDay = day);
    _load();
  }

  _DietMeal? _mealForType(DietPlanDetailPayload? payload, int type) {
    if (payload == null) return null;
    final items = payload.planDays
        .where((g) => g.type == type)
        .expand((g) => g.detail)
        .toList();

    if (items.isEmpty) return null;

    final first = items.first;
    final title = items.map((e) => e.sourceName).firstWhere((e) => e.isNotEmpty, orElse: () => '—');
    final desc = items.map((e) => e.sourceName).where((e) => e.isNotEmpty).join(' + ');

    VoidCallback? action;
    if (first.sourceType == 'recipe') {
      action = () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecipeDetailScreen(
                caipinId: first.sourceId,
                fallbackTitle: title,
                fallbackDesc: '',
                fallbackImageUrl: '',
              ),
            ),
          );
    } else if (first.sourceType == 'food') {
      action = () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FoodDetailScreen(
                foodId: first.sourceId,
                name: title,
                thumbImageUrl: null,
              ),
            ),
          );
    }

    return _DietMeal(title: title, desc: desc, action: action);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: FutureBuilder<DietPlanDetailPayload>(
                future: _futureDetail,
                builder: (context, snapshot) {
                  final payload = snapshot.data;

                  final breakfast = _mealForType(payload, 1);
                  final lunch = _mealForType(payload, 2);
                  final dinner = _mealForType(payload, 3);

                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 80),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildPlanInfo(),
                      const SizedBox(height: 24),
                      _buildDayPicker(),
                      const SizedBox(height: 12),
                      _buildMealSection('早', '早餐', '清爽开局', breakfast?.title ?? '—', breakfast?.desc ?? '—', onTap: breakfast?.action),
                      const SizedBox(height: 12),
                      _buildMealSection('午', '午餐', '稳稳饱腹', lunch?.title ?? '—', lunch?.desc ?? '—', onTap: lunch?.action),
                      const SizedBox(height: 12),
                      _buildMealSection('晚', '晚餐', '轻一点', dinner?.title ?? '—', dinner?.desc ?? '—', onTap: dinner?.action),
                      const SizedBox(height: 24),
                      _buildPlanNotes(),
                      const SizedBox(height: 32),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
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
              Text('${widget.plan.name}（${widget.plan.dayCount} 天）', style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlanInfo() {
    final imageUrl = ApiClient.absoluteUrl(widget.plan.image);
    final tagList = <String>[
      widget.plan.cycle,
      '累计${widget.plan.userCount}人使用',
      '状态：${widget.plan.status}',
    ];

    return CardContainer(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              imageUrl.isEmpty ? 'https://placehold.co/80x80/png?text=%E8%AE%A1%E5%88%92' : imageUrl,
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
                      child: Text(widget.plan.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.brand50,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.brand500.withValues(alpha: 0.18)),
                      ),
                      child: Text('${widget.plan.dayCount} 天', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.brand600)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('周期：${widget.plan.cycle}，状态：${widget.plan.status}', style: TextStyle(fontSize: 14, color: AppColors.slate600), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: tagList.map((t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.slate200.withValues(alpha: 0.8)),
                    ),
                    child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.slate700)),
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('今日安排', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(widget.plan.dayCount, (i) {
              final d = i + 1;
              final isActive = d == _activeDay;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => _onDayTap(d),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.brand50 : Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: isActive ? AppColors.brand500.withValues(alpha: 0.18) : AppColors.slate200.withValues(alpha: 0.7)),
                    ),
                    child: Text('第 $d 天', style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive ? AppColors.brand600 : AppColors.slate700,
                    )),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildMealSection(
    String icon,
    String title,
    String subtitle,
    String mealTitle,
    String mealDesc, {
    VoidCallback? onTap,
  }) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: icon == '早' ? AppColors.brand50 : AppColors.slate50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: icon == '早' ? AppColors.brand500.withValues(alpha: 0.18) : AppColors.slate200.withValues(alpha: 0.7)),
                    ),
                    child: Center(child: Text(icon, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: icon == '早' ? AppColors.brand600 : AppColors.slate700))),
                  ),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.slate50,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.slate200.withValues(alpha: 0.8)),
                ),
                child: Text(subtitle, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.slate700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.rose50.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.rose100.withValues(alpha: 0.7)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network('https://placehold.co/200x200/png?text=%E9%A3%9F%E8%B0%B1', width: 48, height: 48, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder()),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mealTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                        Text(mealDesc, style: TextStyle(fontSize: 12, color: AppColors.slate600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('计划说明', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        CardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _noteItem('以清淡烹饪为主，优先蒸/煮/炖，减少油炸和重口味。'),
              _noteItem('三餐尽量规律；如果加餐，选择水果或酸奶等轻负担选项。'),
              _noteItem('占位内容：后续可扩展为第 1～7 天的完整菜单。'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _noteItem(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.brand600.withValues(alpha: 0.8),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(fontSize: 14, color: AppColors.slate700), maxLines: 2, overflow: TextOverflow.ellipsis)),
      ],
    ),
  );

  Widget _placeholder() => Container(width: 80, height: 80, color: AppColors.slate200, child: const Icon(Icons.image_not_supported));
}

class _DietMeal {
  final String title;
  final String desc;
  final VoidCallback? action;

  const _DietMeal({required this.title, required this.desc, required this.action});
}
