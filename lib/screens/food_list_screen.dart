import 'dart:async';

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../api/api_client.dart';
import '../api/api_models.dart';
import 'food_detail_screen.dart';
import 'food_items_screen.dart';
import '../widgets/card_container.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key});

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  String _activeId = '';
  List<FoodCategory> _categories = const [];

  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  bool _searchLoading = false;
  List<FoodListItem> _searchResults = const [];
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);
    ApiClient.instance.getFoodCateList().then((value) {
      if (!mounted) return;
      setState(() {
        _categories = value;
        _activeId = value.isNotEmpty ? value.first.id.toString() : '';
      });
    });
  }

  void _onSearchTextChanged() {
    _searchDebounce?.cancel();
    final kw = _searchController.text.trim();
    if (kw.isEmpty) {
      setState(() {
        _searchLoading = false;
        _searchResults = const [];
        _searchError = null;
      });
      return;
    }
    setState(() {
      _searchLoading = true;
      _searchError = null;
      _searchResults = const [];
    });
    _searchDebounce = Timer(const Duration(milliseconds: 400), () => _runFoodSearch(kw));
  }

  Future<void> _runFoodSearch(String keyword) async {
    setState(() {
      _searchLoading = true;
      _searchError = null;
      _searchResults = const [];
    });
    try {
      final list = await ApiClient.instance.foodSearch(keyword: keyword);
      if (!mounted) return;
      if (_searchController.text.trim() != keyword) return;
      setState(() {
        _searchResults = list;
        _searchLoading = false;
        _searchError = null;
      });
    } catch (e) {
      if (!mounted) return;
      if (_searchController.text.trim() != keyword) return;
      setState(() {
        _searchLoading = false;
        _searchError = e.toString();
        _searchResults = const [];
      });
    }
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
  }

  bool get _showSearchPanel => _searchController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: _buildSearchBar(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CardContainer(
                    padding: EdgeInsets.zero,
                    child: _showSearchPanel ? _buildSearchPanel() : _buildCategoryPanel(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
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
          Text('食材分类', style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          )),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return AnimatedBuilder(
      animation: _searchController,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.slate200.withValues(alpha: 0.7)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.brand50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.brand500.withValues(alpha: 0.18)),
                ),
                child: const Center(child: Text('⌕', style: TextStyle(fontSize: 16))),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: '搜索全库食材',
                    hintStyle: TextStyle(fontSize: 14, color: AppColors.slate500),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (_searchController.text.isNotEmpty)
                IconButton(
                  onPressed: _clearSearch,
                  icon: Icon(Icons.close, size: 20, color: AppColors.slate500),
                  visualDensity: VisualDensity.compact,
                  tooltip: '清空',
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryPanel() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTabs(),
        Expanded(child: _buildSecondaryGrid()),
      ],
    );
  }

  Widget _buildSearchPanel() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '搜索结果',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          Text(
            _searchLoading ? '正在搜索…' : '共 ${_searchResults.length} 条',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.slate500),
          ),
          const SizedBox(height: 10),
          Expanded(child: _buildSearchBody()),
        ],
      ),
    );
  }

  Widget _buildSearchBody() {
    if (_searchError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_searchError!, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.slate600)),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () => _runFoodSearch(_searchController.text.trim()),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }
    if (_searchLoading && _searchResults.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_searchLoading && _searchResults.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.rose50.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.rose100.withValues(alpha: 0.7)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('没有找到相关食材', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
              Text('换个关键词试试', style: TextStyle(fontSize: 12, color: AppColors.slate500)),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      itemCount: _searchResults.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final item = _searchResults[i];
        return _IngredientSearchRow(
          item: item,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FoodDetailScreen(
                foodId: item.id,
                name: item.name,
                thumbImageUrl: item.thumbImageUrl,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabs() {
    return Container(
      width: 92,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, AppColors.rose50.withValues(alpha: 0.3)],
        ),
        border: Border(right: BorderSide(color: AppColors.rose100.withValues(alpha: 0.7))),
      ),
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: _categories.map((c) {
          final isActive = c.id.toString() == _activeId;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _activeId = c.id.toString()),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.brand50 : Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isActive ? AppColors.brand500.withValues(alpha: 0.18) : AppColors.slate200.withValues(alpha: 0.7),
                    ),
                  ),
                  child: Text(c.name, style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isActive ? AppColors.brand600 : AppColors.slate700,
                  )),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSecondaryGrid() {
    if (_categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final category = _categories.cast<FoodCategory?>().firstWhere(
      (c) => c!.id.toString() == _activeId,
      orElse: () => _categories.isNotEmpty ? _categories.first : null,
    );
    if (category == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
              Text('选择左侧分类查看二级分类', style: TextStyle(fontSize: 11, color: AppColors.slate500)),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.6,
              children: category.subs.map((i) => _SubCategoryItem(
                    name: i.name,
                    desc: i.desc,
                    img: i.image,
                    rankId: i.rankId,
                  )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubCategoryItem extends StatelessWidget {
  final String name;
  final String desc;
  final String img;
  final int rankId;

  const _SubCategoryItem({
    required this.name,
    required this.desc,
    required this.img,
    required this.rankId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => FoodItemsScreen(rankId: rankId, categoryName: name),
      )),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: AppColors.ink.withValues(alpha: 0.06), blurRadius: 4)],
          border: Border.all(color: AppColors.rose100.withValues(alpha: 0.7)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  ApiClient.absoluteUrl(img),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(),
                ),
              ),
            ),
            Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(desc, style: TextStyle(fontSize: 10, color: AppColors.slate500, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(color: AppColors.slate200, child: const Icon(Icons.image_not_supported, size: 24));
}

class _IngredientSearchRow extends StatelessWidget {
  final FoodListItem item;
  final VoidCallback onTap;

  const _IngredientSearchRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tag = (item.healthLabel ?? item.suggest ?? '').toString();
    final kcal = item.calory == null ? '—' : '${item.calory}kcal';
    final imageUrl = ApiClient.absoluteUrl(item.thumbImageUrl);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: AppColors.ink.withValues(alpha: 0.06), blurRadius: 4)],
            border: Border.all(color: AppColors.rose100.withValues(alpha: 0.7)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(imageUrl, width: 56, height: 56, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _imgPlaceholder()),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        if (tag.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.brand50,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.brand500.withValues(alpha: 0.18)),
                            ),
                            child: Text(tag, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.brand600)),
                          ),
                      ],
                    ),
                    Text(kcal, style: TextStyle(fontSize: 12, color: AppColors.slate600), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imgPlaceholder() => Container(width: 56, height: 56, color: AppColors.slate200, child: const Icon(Icons.image_not_supported, size: 24));
}