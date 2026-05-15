import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api/api_client.dart';
import '../api/api_models.dart';
import '../theme/app_colors.dart';
import '../widgets/card_container.dart';
import 'food_detail_screen.dart';

/// 在某一一级分类下搜索食材：对 [subRankIds] 中每个二级 rank 调用
/// GET /sp/index/SearchFoodList（与 [ApiClient.getFoodList] 的 rank 语义一致），再合并去重。
///
/// 说明：接口里的 `rank_id` 与 `foodList` 相同，应对 **二级分类**（subs 里的 rank_id）。
/// 一级 `FoodCategory.rankId` 与二级 `FoodSubCategory.rankId` 不是同一套 id，
/// 把一级 rank 当作 foodList 的 rank 传容易造成 500 或始终无数据。
///
/// UI 与 [RecipeSearchScreen]（搜菜谱）对齐：顶栏、搜索条、占位/错误/空列表/结果卡片。
class FoodRankSearchScreen extends StatefulWidget {
  /// 当前一级分类下各二级格子的 rank_id（去重后传入亦可）
  final List<int> subRankIds;
  final String categoryName;

  const FoodRankSearchScreen({
    super.key,
    required this.subRankIds,
    required this.categoryName,
  });

  @override
  State<FoodRankSearchScreen> createState() => _FoodRankSearchScreenState();
}

class _FoodRankSearchScreenState extends State<FoodRankSearchScreen> {
  final _searchCtrl = TextEditingController();
  final _focus = FocusNode();

  /// 递增以丢弃过期的异步结果（连点搜索时取消在途请求）
  int _requestId = 0;

  bool _loading = false;
  bool _hasSearched = false;
  List<FoodListItem> _items = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focus.requestFocus();
      }
    });
  }

  Future<void> _runSearch() async {
    final id = ++_requestId;
    SystemChannels.textInput.invokeMethod<void>('TextInput.hide');

    setState(() {
      _loading = true;
      _error = null;
      _items = const [];
      _hasSearched = true;
    });

    final kw = _searchCtrl.text.trim();
    final rankIds = widget.subRankIds.toSet().toList();
    if (rankIds.isEmpty) {
      if (!mounted || id != _requestId) return;
      setState(() {
        _loading = false;
        _error = '该大类下没有二级分类，无法搜索';
        _items = const [];
      });
      return;
    }

    Object? firstError;
    final byId = <int, FoodListItem>{};
    for (final rid in rankIds) {
      try {
        final part = await ApiClient.instance.searchFoodList(
          rankId: rid,
          keyword: kw.isEmpty ? null : kw,
        );
        for (final item in part) {
          byId[item.id] = item;
        }
      } catch (e) {
        firstError ??= e;
      }
    }
    if (!mounted || id != _requestId) return;

    final merged = byId.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    if (merged.isEmpty && firstError != null) {
      setState(() {
        _loading = false;
        final fe = firstError!;
        _error = fe is ApiException ? fe.message : fe.toString();
        _items = const [];
      });
      return;
    }

    setState(() {
      _items = merged;
      _loading = false;
      _error = null;
    });
  }

  void _onSubmitSearch() {
    if (_loading) return;
    _runSearch();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              _buildTopBar(context),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildSearchField(),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _buildListArea(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
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
            child: const Center(
              child: Text('‹', style: TextStyle(fontSize: 24, height: 1)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '搜食材',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
              ),
              Text(
                '「${widget.categoryName}」· 关键词可留空查看本大类',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: AppColors.slate500),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildSearchField() {
    return CardContainer(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(left: 8),
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
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              focusNode: _focus,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _onSubmitSearch(),
              decoration: const InputDecoration(
                hintText: '例如：西兰花、低卡、虾仁…',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              ),
              style: const TextStyle(fontSize: 15, color: AppColors.ink),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: TextButton(
              onPressed: _loading ? null : _onSubmitSearch,
              child: const Text('搜索', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListArea() {
    if (!_hasSearched) {
      return _buildPlaceholder(
        icon: Icons.restaurant_menu,
        title: '寻找今日灵感',
      );
    }
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CardContainer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_tethering_error, color: AppColors.slate500, size: 40),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.slate600, height: 1.4),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _loading ? null : _onSubmitSearch,
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }
    if (_items.isEmpty) {
      return _buildPlaceholder(
        icon: Icons.search_off,
        title: '暂无匹配食材',
        subtitle: '换几个关键词再试',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      itemCount: _items.length,
      itemBuilder: (context, i) {
        final item = _items[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _IngredientResultTile(
            item: item,
            onTap: () {
              Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => FoodDetailScreen(
                    foodId: item.id,
                    name: item.name,
                    thumbImageUrl: item.thumbImageUrl,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    final s = (subtitle ?? '').trim();
    return ListView(
      children: [
        const SizedBox(height: 40),
        Icon(icon, size: 56, color: AppColors.slate200),
        const SizedBox(height: 16),
        Center(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        if (s.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              s,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.slate500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _IngredientResultTile extends StatelessWidget {
  final FoodListItem item;
  final VoidCallback onTap;

  const _IngredientResultTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiClient.absoluteUrl(item.thumbImageUrl);
    final desc = (item.suggest ?? item.lights ?? '').toString().trim();
    final tag = (item.healthLabel ?? '').toString().trim();

    return CardContainer(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              imageUrl.isEmpty ? 'https://placehold.co/88x88/png?text=+' : imageUrl,
              width: 88,
              height: 88,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _imgFallback(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc.isEmpty ? '—' : desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.slate600,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _tag(
                      item.calory == null ? '— kcal' : '${item.calory} kcal',
                      AppColors.brand50,
                      AppColors.brand600,
                    ),
                    if (tag.isNotEmpty) _tag(tag, AppColors.slate50, AppColors.slate700),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.slate200),
        ],
      ),
    );
  }

  static Widget _tag(String t, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.rose100.withValues(alpha: 0.5)),
      ),
      child: Text(
        t,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  static Widget _imgFallback() {
    return Container(
      width: 88,
      height: 88,
      color: AppColors.slate200,
      child: const Icon(Icons.image_not_supported, color: AppColors.slate500),
    );
  }
}
