import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../api/api_client.dart';
import '../api/api_models.dart';
import 'food_list_screen.dart';
import 'plan_list_screen.dart';
import 'plan_detail_screen.dart';
import 'food_detail_screen.dart';
import 'recipe_detail_screen.dart';
import '../widgets/card_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _recipeController = PageController(viewportFraction: 0.92);
  int _recipeIndex = 0;
  List<CaipinSummary> _recipeRecommend = const [];
  List<RcmdFoodItem> _ingredientRecommend = const [];
  Future<DietPlanListPayload>? _futurePlans;

  @override
  void initState() {
    super.initState();
    _futurePlans = ApiClient.instance.getDietPlanList(page: 1, limit: 3);
    _loadRecommend();
  }

  Future<void> _loadRecommend() async {
    List<CaipinSummary> recipes = _recipeRecommend;
    List<RcmdFoodItem> ingredients = _ingredientRecommend;
    try {
      recipes = await ApiClient.instance.recommendFoodList();
    } catch (_) {
      // 保留原数据
    }
    try {
      ingredients = await ApiClient.instance.rcmdFoodList();
    } catch (_) {
      // 保留原数据
    }
    if (!mounted) return;
    setState(() {
      _recipeRecommend = recipes;
      _ingredientRecommend = ingredients;
      _recipeIndex = 0;
    });
    _startAutoPlay();
  }

  void _startAutoPlay() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted) return false;
      if (_recipeRecommend.isEmpty) return true;
      final next = (_recipeIndex + 1) % _recipeRecommend.length;
      _recipeController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      setState(() => _recipeIndex = next);
      return true;
    });
  }

  @override
  void dispose() {
    _recipeController.dispose();
    super.dispose();
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildRecipeSection(),
                  const SizedBox(height: 10),
                  _buildFoodSection(),
                  const SizedBox(height: 28),
                  _buildPlanSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.brand500, Color(0xFFE879F9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('🍽️', style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '吃啥',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.brand50,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.brand500.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Text(
                            '今日推荐',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.brand600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '生活有态度，生活有温度',
                      style: TextStyle(fontSize: 14, color: AppColors.slate600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.slate200.withValues(alpha: 0.7),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.brand50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.brand500.withValues(alpha: 0.18),
                    ),
                  ),
                  child: const Center(
                    child: Text('⌕', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '搜索食谱 / 食物 / 计划',
                    style: TextStyle(fontSize: 14, color: AppColors.slate500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '食谱推荐',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SizedBox(
              height: 220,
              child: PageView.builder(
                controller: _recipeController,
                itemCount: _recipeRecommend.isEmpty ? 1 : _recipeRecommend.length,
                onPageChanged: (i) => setState(() => _recipeIndex = i),
                itemBuilder: (context, i) {
                  final c = _recipeRecommend.isEmpty ? null : _recipeRecommend[i];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 28),
                    child: _RecipeCard(caipin: c),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_recipeRecommend.isEmpty ? 1 : _recipeRecommend.length, (i) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _recipeIndex
                          ? AppColors.brand600.withValues(alpha: 0.9)
                          : AppColors.slate200,
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFoodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '食材推荐',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FoodListScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.rose100.withValues(alpha: 0.8),
                  ),
                ),
                child: Text(
                  '更多 →',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brand600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.7,
          children: List.generate(4, (i) {
            final item = _ingredientRecommend.isEmpty || _ingredientRecommend.length <= i
                ? null
                : _ingredientRecommend[i];
            return _FoodGridItem(food: item);
          }),
        ),
      ],
    );
  }

  Widget _buildPlanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '饮食计划',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlanListScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.rose100.withValues(alpha: 0.8),
                  ),
                ),
                child: Text(
                  '更多 →',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brand600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FutureBuilder<DietPlanListPayload>(
          future: _futurePlans,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final plans = snapshot.data?.list ?? const <DietPlanSummary>[];
            if (plans.isEmpty) {
              return const Text('暂无计划', style: TextStyle(color: AppColors.slate600));
            }
            return Column(
              children: plans
                  .map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PlanCard(plan: p),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final CaipinSummary? caipin;

  const _RecipeCard({required this.caipin});

  @override
  Widget build(BuildContext context) {
    final imageUrl = caipin == null ? '' : ApiClient.absoluteUrl(caipin!.image);
    final title = caipin?.name ?? '暂无数据';
    final desc = caipin?.desc ?? '';

    return GestureDetector(
      onTap: caipin == null
          ? null
          : () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RecipeDetailScreen(
                    caipinId: caipin!.id,
                    fallbackTitle: title,
                    fallbackDesc: desc,
                    fallbackImageUrl: imageUrl,
                  ),
                ),
              ),
      child: CardContainer(
        padding: EdgeInsets.zero,
        onTap: null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              _chip('推荐'),
                              if (caipin?.calory != null) _chip('${caipin!.calory}kcal'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            desc,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.slate600,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Wrap(
                            spacing: 8,
                            children: [
                              _chip('菜谱'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        imageUrl.isEmpty ? 'https://placehold.co/112x112/png?text=%E9%A4%90%E8%B0%B1' : imageUrl,
                        width: 112,
                        height: 112,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(112),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: AppColors.slate50,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.slate700,
      ),
    ),
  );

  Widget _placeholder(double size) => Container(
    width: size,
    height: size,
    color: AppColors.slate200,
    child: const Icon(Icons.image_not_supported),
  );
}

class _FoodGridItem extends StatelessWidget {
  final RcmdFoodItem? food;

  const _FoodGridItem({required this.food});

  @override
  Widget build(BuildContext context) {
    final imageUrl = food == null ? '' : ApiClient.absoluteUrl(food!.imagePathForDisplay);
    final name = food?.name ?? '—';
    final cal = (food?.calory ?? '').trim();
    final subtitle = cal.isEmpty ? '—' : '${cal}kcal';

    return GestureDetector(
      onTap: food == null
          ? null
          : () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FoodDetailScreen(
                    foodId: food!.id,
                    name: name,
                    thumbImageUrl: food!.thumbImageUrl ?? food!.largeImageUrl,
                  ),
                ),
              ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.06),
              blurRadius: 4,
            ),
          ],
          border: Border.all(color: AppColors.rose100.withValues(alpha: 0.7)),
        ),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl.isEmpty ? 'https://placehold.co/200x200/png?text=%E5%8D%A0%E4%BD%8D' : imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: AppColors.slate500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: AppColors.slate200,
    child: const Icon(Icons.image_not_supported),
  );
}

class _PlanCard extends StatelessWidget {
  final DietPlanSummary plan;

  const _PlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiClient.absoluteUrl(plan.image);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PlanDetailScreen(plan: plan)),
      ),
      child: CardContainer(
        padding: const EdgeInsets.all(16),
        onTap: null,
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
                        child: Text(
                          plan.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.brand50,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppColors.brand500.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Text(
                          '${plan.dayCount} 天',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brand600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '周期：${plan.cycle}',
                    style: TextStyle(fontSize: 12, color: AppColors.slate600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 80,
    height: 80,
    color: AppColors.slate200,
    child: const Icon(Icons.image_not_supported),
  );
}