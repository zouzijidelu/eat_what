import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../data/mock_data.dart';
import 'food_detail_screen.dart';
import '../widgets/card_container.dart';

class FoodItemsScreen extends StatefulWidget {
  final String category;

  const FoodItemsScreen({super.key, required this.category});

  @override
  State<FoodItemsScreen> createState() => _FoodItemsScreenState();
}

class _FoodItemsScreenState extends State<FoodItemsScreen> {
  final _searchController = TextEditingController();
  List<Map<String, String>> _items = [];
  List<Map<String, String>> _filtered = [];

  @override
  void initState() {
    super.initState();
    _items = List<Map<String, String>>.from(
      MockData.foodItemsByCategory[widget.category] ??
      [{'name': '示例食物 A', 'tag': '占位', 'kcal': '—'}, {'name': '示例食物 B', 'tag': '占位', 'kcal': '—'}],
    );
    _filtered = _items;
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty ? _items : _items.where((x) => (x['name'] ?? '').toLowerCase().contains(q)).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearch);
    _searchController.dispose();
    super.dispose();
  }

  String _imgUrl(String name) => 'https://placehold.co/200x200/png?text=${Uri.encodeComponent(name)}';

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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildSearchBar(),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CardContainer(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('共 ${_filtered.length} 个食物', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.slate500)),
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FoodDetailScreen(name: '牛油果'))),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.brand50,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: AppColors.brand500.withValues(alpha: 0.18)),
                                ),
                                child: Text('示例详情 →', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.brand600)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: _filtered.isEmpty
                            ? Center(
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
                                      Text('没有找到相关食物', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                                      Text('换个关键词试试', style: TextStyle(fontSize: 12, color: AppColors.slate500)),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.separated(
                                itemCount: _filtered.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 8),
                                itemBuilder: (_, i) {
                                  final item = _filtered[i];
                                  return _FoodListItem(
                                    name: item['name'] ?? '',
                                    tag: item['tag'] ?? '',
                                    kcal: item['kcal'] ?? '',
                                    imageUrl: _imgUrl(item['name'] ?? ''),
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FoodDetailScreen(name: item['name'] ?? ''))),
                                  );
                                },
                              ),
                        ),
                      ],
                    ),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('食物列表', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.slate500)),
                Text(widget.category, style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                )),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.popUntil(context, (r) => r.isFirst),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.slate200.withValues(alpha: 0.7)),
              ),
              child: Text('首页', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.slate700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
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
              decoration: InputDecoration(
                hintText: '搜索本分类食物',
                hintStyle: TextStyle(fontSize: 14, color: AppColors.slate500),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodListItem extends StatelessWidget {
  final String name;
  final String tag;
  final String kcal;
  final String imageUrl;
  final VoidCallback onTap;

  const _FoodListItem({
    required this.name,
    required this.tag,
    required this.kcal,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                child: Image.network(imageUrl, width: 56, height: 56, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder()),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis)),
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

  Widget _placeholder() => Container(width: 56, height: 56, color: AppColors.slate200, child: const Icon(Icons.image_not_supported, size: 24));
}
