import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../data/mock_data.dart';
import '../widgets/card_container.dart';

class RecipeDetailScreen extends StatelessWidget {
  final RecipeItem recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  static const _imgIngredient = 'https://placehold.co/200x200/png?text=%E9%A3%9F%E6%9D%90';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  _buildInfoCard(context),
                  const SizedBox(height: 16),
                  _buildNutrients(context),
                  const SizedBox(height: 24),
                  _buildIngredients(context),
                  const SizedBox(height: 24),
                  _buildSteps(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
        Text(recipe.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        )),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return CardContainer(
      child: Row(
        children: [
          ClipOval(
            child: Image.network(recipe.imageUrl, width: 96, height: 96, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder(96)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _tag(recipe.category),
                    _tag(recipe.duration),
                  ],
                ),
                const SizedBox(height: 8),
                Text(recipe.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(recipe.desc, style: TextStyle(fontSize: 14, color: AppColors.slate600), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: text == recipe.category ? AppColors.brand50 : AppColors.slate50,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: text == recipe.category ? AppColors.brand500.withValues(alpha: 0.18) : AppColors.slate200.withValues(alpha: 0.8)),
    ),
    child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: text == recipe.category ? AppColors.brand600 : AppColors.slate700)),
  );

  Widget _buildNutrients(BuildContext context) {
    // 菜谱营养素（与食物详情数值不同）
    final nutrients = [
      _Nutrient('🔥', '热量', '520kcal', true),
      _Nutrient('🍗', '蛋白质', '28g', false),
      _Nutrient('🍚', '碳水', '62g', false),
      _Nutrient('🥑', '脂肪', '16g', false),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('营养素', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.9,
          children: nutrients.map((n) => CardContainer(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: n.brand ? AppColors.brand50 : AppColors.slate50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: n.brand ? AppColors.brand500.withValues(alpha: 0.18) : AppColors.slate200.withValues(alpha: 0.7)),
                  ),
                  child: Center(child: Text(n.icon, style: const TextStyle(fontSize: 18))),
                ),
                const SizedBox(height: 4),
                Text(n.label, style: TextStyle(fontSize: 10, color: AppColors.slate500)),
                Text(n.value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.slate800)),
              ],
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildIngredients(BuildContext context) {
    final ingredients = [
      ('番茄', '1 个', '热量 22kcal · 碳水 5g'),
      ('鸡蛋', '2 个', '蛋白质 12g · 脂肪 10g'),
      ('面条', '80g', '热量 280kcal · 碳水 56g'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('食材清单', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        ...ingredients.map((i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CardContainer(
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(_imgIngredient, width: 64, height: 64, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder(64)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(i.$1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.slate50,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.slate200.withValues(alpha: 0.7)),
                            ),
                            child: Text(i.$2, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.slate700)),
                          ),
                        ],
                      ),
                      Text(i.$3, style: TextStyle(fontSize: 12, color: AppColors.slate600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildSteps(BuildContext context) {
    final steps = [
      _Step('1', '处理食材', '番茄切小块，鸡蛋打散；锅中烧水备用。', true),
      _Step('2', '炒番茄与鸡蛋', '少油热锅，下番茄炒出汁，倒入鸡蛋滑散。', false),
      _Step('3', '煮面出锅', '加入开水调味，下面条煮熟，撒葱花即可。', false),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('制作步骤', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        ...steps.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CardContainer(
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: s.brand ? AppColors.brand50 : AppColors.slate50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: s.brand ? AppColors.brand500.withValues(alpha: 0.18) : AppColors.slate200.withValues(alpha: 0.7)),
                  ),
                  child: Center(child: Text(s.stepNum, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: s.brand ? AppColors.brand600 : AppColors.slate700))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                      Text(s.desc, style: TextStyle(fontSize: 12, color: AppColors.slate600), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _placeholder(double size) => Container(width: size, height: size, color: AppColors.slate200, child: const Icon(Icons.image_not_supported));
}

class _Nutrient {
  final String icon;
  final String label;
  final String value;
  final bool brand;
  _Nutrient(this.icon, this.label, this.value, this.brand);
}

class _Step {
  final String stepNum;
  final String title;
  final String desc;
  final bool brand;
  _Step(this.stepNum, this.title, this.desc, this.brand);
}
