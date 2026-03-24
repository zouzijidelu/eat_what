import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../data/mock_data.dart';
import 'food_items_screen.dart';
import 'food_detail_screen.dart';
import '../widgets/card_container.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key});

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  String _activeId = MockData.foodCategories.first.id;

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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CardContainer(
                    padding: EdgeInsets.zero,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTabs(),
                        Expanded(child: _buildSecondaryGrid()),
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
          Text('食物分类', style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          )),
        ],
      ),
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
        children: MockData.foodCategories.map((c) {
          final isActive = c.id == _activeId;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _activeId = c.id),
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
    final category = MockData.foodCategories.firstWhere((c) => c.id == _activeId, orElse: () => MockData.foodCategories.first);
    return Padding(
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
                  Text(category.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                  Text('选择左侧分类查看二级分类', style: TextStyle(fontSize: 11, color: AppColors.slate500)),
                ],
              ),
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
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.75,
              children: category.items.map((i) => _SubCategoryItem(
                name: i.name,
                desc: i.desc,
                img: i.img,
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

  const _SubCategoryItem({required this.name, required this.desc, required this.img});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => FoodItemsScreen(category: name),
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
                child: Image.network(img, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder()),
              ),
            ),
            const SizedBox(height: 6),
            Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(desc, style: TextStyle(fontSize: 10, color: AppColors.slate500, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(color: AppColors.slate200, child: const Icon(Icons.image_not_supported, size: 24));
}
