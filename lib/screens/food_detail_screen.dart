import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../api/api_client.dart';
import '../api/api_models.dart';
import '../widgets/card_container.dart';
import 'recipe_detail_screen.dart';

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

  static const _imgFood = 'https://placehold.co/240x240/png?text=%E9%A3%9F%E6%9D%90';

  @override
  Widget build(BuildContext context) {
    final future = Future.wait([
      ApiClient.instance.getFoodNutritionDetail(foodId: foodId),
      ApiClient.instance.getFoodCaipin(foodId: foodId),
    ]);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
                  FutureBuilder<List<dynamic>>(
                    future: future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(48),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final nutrients = (snapshot.data?[0] as List<FoodNutritionItem>?) ?? const <FoodNutritionItem>[];
                      final caipinList = (snapshot.data?[1] as List<CaipinSummary>?) ?? const <CaipinSummary>[];
                      final hasError = snapshot.hasError;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoCard(context, nutrients: nutrients),
                          const SizedBox(height: 16),
                          _buildNutrients(context, items: nutrients, hasError: hasError),
                          const SizedBox(height: 24),
                          _buildRecommendedWays(context, caipinList: caipinList),
                          const SizedBox(height: 24),
                          _buildRelatedRecipes(context, caipinList: caipinList),
                        ],
                      );
                    },
                  ),
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

  Widget _buildInfoCard(BuildContext context, {required List<FoodNutritionItem> nutrients}) {
    final imageUrl = ApiClient.absoluteUrl(thumbImageUrl);
    final tags = nutrients.take(3).toList();

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
                if (tags.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: List.generate(tags.length, (i) => _tag(tags[i].name, brand: i == 0)),
                  ),
                if (tags.isNotEmpty) const SizedBox(height: 8),
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
          Text('营养素加载失败', style: TextStyle(fontSize: 14, color: AppColors.slate600)),
        ],
      );
    }

    if (items.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('营养素', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text('暂无营养素数据', style: TextStyle(fontSize: 14, color: AppColors.slate600)),
        ],
      );
    }

    final weigh = items.first.weigh;
    final displayItems = items.length <= 8 ? items : items.sublist(0, 8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('营养素', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(width: 8),
            Text('(${weigh}g)', style: TextStyle(fontSize: 12, color: AppColors.slate500)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: displayItems.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _buildNutrientCard(displayItems[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedWays(BuildContext context, {required List<CaipinSummary> caipinList}) {
    final ways = caipinList.take(2).toList();
    if (ways.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('推荐吃法', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        ...ways.map((caipin) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _WayCard(
            title: caipin.name,
            desc: caipin.desc,
            imageUrl: caipin.image,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RecipeDetailScreen(
                  caipinId: caipin.id,
                  fallbackTitle: caipin.name,
                  fallbackDesc: caipin.desc,
                  fallbackImageUrl: caipin.image,
                ),
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildRelatedRecipes(BuildContext context, {required List<CaipinSummary> caipinList}) {
    final recipes = caipinList.length > 2 ? caipinList.sublist(2) : <CaipinSummary>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('相关食谱', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        if (recipes.isEmpty)
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
          )
        else
          ...recipes.map((caipin) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _WayCard(
              title: caipin.name,
              desc: caipin.desc,
              imageUrl: caipin.image,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RecipeDetailScreen(
                    caipinId: caipin.id,
                    fallbackTitle: caipin.name,
                    fallbackDesc: caipin.desc,
                    fallbackImageUrl: caipin.image,
                  ),
                ),
              ),
            ),
          )),
      ],
    );
  }

  Widget _buildNutrientCard(FoodNutritionItem item) {
    final hasNrv = (item.nrv ?? '').trim().isNotEmpty;
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.rose100.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            item.name,
            style: TextStyle(fontSize: 11, color: AppColors.slate500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            item.value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, height: 1),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            item.unit,
            style: TextStyle(fontSize: 11, color: AppColors.slate600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          if (hasNrv) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.brand50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'NRV ${item.nrv}',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.brand600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _placeholder(double size) => Container(width: size, height: size, color: AppColors.slate200, child: const Icon(Icons.image_not_supported));
}

class _WayCard extends StatelessWidget {
  final String title;
  final String desc;
  final String imageUrl;
  final VoidCallback? onTap;

  const _WayCard({required this.title, required this.desc, required this.imageUrl, this.onTap});

  @override
  Widget build(BuildContext context) {
    final image = ApiClient.absoluteUrl(imageUrl);
    return GestureDetector(
      onTap: onTap,
      child: CardContainer(
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(image, width: 64, height: 64, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder()),
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
      ),
    );
  }

  Widget _placeholder() => Container(width: 64, height: 64, color: AppColors.slate200, child: const Icon(Icons.image_not_supported));
}