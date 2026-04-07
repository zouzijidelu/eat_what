import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../api/api_client.dart';
import '../api/api_models.dart';
import '../widgets/card_container.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int caipinId;
  final String fallbackTitle;
  final String fallbackDesc;
  final String fallbackImageUrl;

  const RecipeDetailScreen({
    super.key,
    required this.caipinId,
    required this.fallbackTitle,
    required this.fallbackDesc,
    required this.fallbackImageUrl,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  static const _imgIngredient = 'https://placehold.co/200x200/png?text=%E9%A3%9F%E6%9D%90';

  late Future<CaipinDetailPayload> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiClient.instance.getCaipinDetail(widget.caipinId);
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
              child: FutureBuilder<CaipinDetailPayload>(
                future: _future,
                builder: (context, snapshot) {
                  final payload = snapshot.data;
                  final detail = payload?.detail;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, detail?.name ?? widget.fallbackTitle),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        context,
                        title: detail?.name ?? widget.fallbackTitle,
                        desc: detail?.desc ?? widget.fallbackDesc,
                        imageUrl: ApiClient.absoluteUrl(detail?.image).isEmpty
                            ? widget.fallbackImageUrl
                            : ApiClient.absoluteUrl(detail?.image),
                        chips: [
                          '推荐',
                          if (detail?.calory != null) '${detail!.calory}kcal',
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildNutrients(
                        context,
                        calory: detail?.calory,
                        protein: detail?.protein,
                        carbohydrate: detail?.carbohydrate,
                        water: detail?.water,
                      ),
                      const SizedBox(height: 24),
                      _buildIngredients(context, payload?.foods ?? const []),
                      const SizedBox(height: 24),
                      _buildSteps(context, payload?.steps ?? const []),
                      if (snapshot.hasError) ...[
                        const SizedBox(height: 16),
                        Text('加载失败：${snapshot.error}', style: TextStyle(fontSize: 12, color: AppColors.slate600)),
                      ],
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

  Widget _buildHeader(BuildContext context, String title) {
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
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        )),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String desc,
    required String imageUrl,
    required List<String> chips,
  }) {
    return CardContainer(
      child: Row(
        children: [
          ClipOval(
            child: Image.network(imageUrl, width: 96, height: 96, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder(96)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: chips.map(_tag).toList(),
                ),
                const SizedBox(height: 8),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(fontSize: 14, color: AppColors.slate600), maxLines: 2, overflow: TextOverflow.ellipsis),
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
      color: text == '推荐' ? AppColors.brand50 : AppColors.slate50,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: text == '推荐' ? AppColors.brand500.withValues(alpha: 0.18) : AppColors.slate200.withValues(alpha: 0.8)),
    ),
    child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: text == '推荐' ? AppColors.brand600 : AppColors.slate700)),
  );

  Widget _buildNutrients(
    BuildContext context, {
    required num? calory,
    required num? protein,
    required num? carbohydrate,
    required num? water,
  }) {
    final nutrients = [
      _Nutrient('🔥', '热量', calory == null ? '—' : '${calory}kcal', true),
      _Nutrient('🍗', '蛋白质', protein == null ? '—' : '${protein}g', false),
      _Nutrient('🍚', '碳水', carbohydrate == null ? '—' : '${carbohydrate}g', false),
      _Nutrient('💧', '水分', water == null ? '—' : '${water}g', false),
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

  Widget _buildIngredients(BuildContext context, List<CaipinFoodItem> foods) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('食材清单', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        if (foods.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text('暂无食材数据', style: TextStyle(fontSize: 12, color: AppColors.slate600)),
          )
        else
          ...foods.map((f) => Padding(
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
                          Expanded(child: Text(f.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.slate50,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.slate200.withValues(alpha: 0.7)),
                            ),
                            child: Text('${f.weight}g', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.slate700)),
                          ),
                        ],
                      ),
                      Text(
                        '热量 ${f.calory}kcal · 蛋白 ${f.protein}g · 碳水 ${f.carbohydrate}g · 水分 ${f.water}g',
                        style: TextStyle(fontSize: 12, color: AppColors.slate600),
                      ),
                      if ((f.healthLabel ?? '').isNotEmpty || (f.suggest ?? '').isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            [
                              if ((f.healthLabel ?? '').isNotEmpty) f.healthLabel!,
                              if ((f.suggest ?? '').isNotEmpty) f.suggest!,
                            ].join(' · '),
                            style: TextStyle(fontSize: 11, color: AppColors.slate500),
                          ),
                        ),
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

  Widget _buildSteps(BuildContext context, List<CaipinStep> steps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('制作步骤', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        if (steps.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text('暂无步骤数据', style: TextStyle(fontSize: 12, color: AppColors.slate600)),
          )
        else
          ...steps.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CardContainer(
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: (s.sort == 1) ? AppColors.brand50 : AppColors.slate50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: (s.sort == 1) ? AppColors.brand500.withValues(alpha: 0.18) : AppColors.slate200.withValues(alpha: 0.7)),
                  ),
                  child: Center(child: Text('${s.sort}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: (s.sort == 1) ? AppColors.brand600 : AppColors.slate700))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('步骤 ${s.sort}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                      Text(s.desc, style: TextStyle(fontSize: 12, color: AppColors.slate600), maxLines: 3, overflow: TextOverflow.ellipsis),
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
