import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../api/api_client.dart';
import '../api/api_models.dart';
import '../widgets/card_container.dart';

class FoodDetailScreen extends StatelessWidget {
  final int foodId;
  final String name;
  final String? thumbImageUrl;

  const FoodDetailScreen({
    super.key,
    required this.foodId,
    required this.name,
    this.thumbImageUrl,
  });

  static const _imgFood = 'https://placehold.co/240x240/png?text=%E9%A3%9F%E7%89%A9';
  static const _imgRecipe = 'https://placehold.co/200x200/png?text=%E8%8F%9C%E8%B0%B1';

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
                  FutureBuilder<List<FoodNutritionItem>>(
                    future: ApiClient.instance.getFoodNutritionDetail(foodId: foodId),
                    builder: (context, snapshot) {
                      final items = snapshot.data ?? const <FoodNutritionItem>[];
                      return _buildNutrients(
                        context,
                        items: items,
                        hasError: snapshot.hasError,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildRecommendedWays(context),
                  const SizedBox(height: 24),
                  _buildRelatedRecipes(context),
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
        Text(name, style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        )),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final imageUrl = ApiClient.absoluteUrl(thumbImageUrl);
    return CardContainer(
      child: Row(
        children: [
          ClipOval(
            child: Image.network(
              imageUrl.isEmpty ? _imgFood : imageUrl,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(96),
            ),
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
                    _tag('优质脂肪', brand: true),
                    _tag('百搭'),
                    _tag('饱腹'),
                  ],
                ),
                const SizedBox(height: 8),
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('口感细腻像黄油，适合做沙拉、吐司或奶昔。占位文案可替换。', style: TextStyle(fontSize: 14, color: AppColors.slate600), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, {bool brand = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: brand ? AppColors.brand50 : AppColors.slate50,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: brand ? AppColors.brand500.withValues(alpha: 0.18) : AppColors.slate200.withValues(alpha: 0.8)),
    ),
    child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: brand ? AppColors.brand600 : AppColors.slate700)),
  );

  Widget _buildNutrients(
    BuildContext context, {
    required List<FoodNutritionItem> items,
    required bool hasError,
  }) {
    if (hasError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('营养素', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text('营养素加载失败', style: TextStyle(fontSize: 12, color: AppColors.slate600)),
        ],
      );
    }

    if (items.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('营养素', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text('暂无营养素数据', style: TextStyle(fontSize: 12, color: AppColors.slate600)),
        ],
      );
    }

    final cells = items.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('营养素', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        Text('每 ${items.first.weigh}g 含量（接口单位）', style: TextStyle(fontSize: 12, color: AppColors.slate500)),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.9,
          children: cells
              .map(
                (n) => _NutrientCell(
                  icon: '•',
                  label: n.name,
                  value: '${n.value}${n.unit}',
                  brand: false,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildRecommendedWays(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('推荐吃法', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        _WayCard(title: '牛油果吐司', desc: '压泥抹面包，撒黑胡椒和少许盐，再配一个溏心蛋更满足。'),
        const SizedBox(height: 12),
        _WayCard(title: '清爽沙拉', desc: '与生菜、番茄、鸡胸肉搭配，淋柠檬汁或油醋汁即可。'),
      ],
    );
  }

  Widget _buildRelatedRecipes(BuildContext context) {
    // 当前接口未提供「相关菜谱」列表接口，因此先做占位。
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('相关菜谱', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.rose50.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.rose100.withValues(alpha: 0.7)),
          ),
          child: Text(
            '暂无相关菜谱数据',
            style: TextStyle(fontSize: 12, color: AppColors.slate600),
          ),
        ),
      ],
    );
  }

  Widget _placeholder(double size) => Container(width: size, height: size, color: AppColors.slate200, child: const Icon(Icons.image_not_supported));
}

class _NutrientCell extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final bool brand;

  const _NutrientCell({required this.icon, required this.label, required this.value, this.brand = false});

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: brand ? AppColors.brand50 : AppColors.slate50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: brand ? AppColors.brand500.withValues(alpha: 0.18) : AppColors.slate200.withValues(alpha: 0.7)),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: AppColors.slate500)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.slate800)),
        ],
      ),
    );
  }
}

class _WayCard extends StatelessWidget {
  final String title;
  final String desc;

  const _WayCard({required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network('https://placehold.co/200x200/png?text=%E5%90%83%E6%B3%95', width: 64, height: 64, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                Text(desc, style: TextStyle(fontSize: 12, color: AppColors.slate600), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(width: 64, height: 64, color: AppColors.slate200, child: const Icon(Icons.image_not_supported));
}
