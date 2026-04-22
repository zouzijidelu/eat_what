import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api/api_client.dart';
import '../api/api_models.dart';
import '../theme/app_colors.dart';
import '../widgets/card_container.dart';
import 'recipe_detail_screen.dart';

class RecipeSearchScreen extends StatefulWidget {
  const RecipeSearchScreen({super.key});

  @override
  State<RecipeSearchScreen> createState() => _RecipeSearchScreenState();
}

class _RecipeSearchScreenState extends State<RecipeSearchScreen> {
  static const int _pageSize = 10;

  final _searchCtrl = TextEditingController();
  final _scroll = ScrollController();
  final _focus = FocusNode();

  List<CaipinSummary> _items = const [];
  int _currentPage = 0;
  bool _hasMore = false;
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;
  /// 是否已执行过至少一次搜索
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _searchCtrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_loading || _loadingMore || !_hasMore) return;
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    if (pos.pixels >= pos.maxScrollExtent * 0.88) {
      _loadNextPage();
    }
  }

  Future<void> _runSearch({required bool reset}) async {
    final keyword = _searchCtrl.text;
    if (reset) {
      setState(() {
        _error = null;
        _loading = true;
        _items = const [];
        _currentPage = 0;
        _hasMore = false;
        _hasSearched = true;
      });
    }
    try {
      final rawKeyword = keyword.trim();
      final payload = await ApiClient.instance.searchCaipin(
        page: 1,
        limit: _pageSize,
        keyword: rawKeyword.isEmpty ? null : rawKeyword,
      );
      if (!mounted) return;
      setState(() {
        _items = List<CaipinSummary>.from(payload.list);
        _currentPage = payload.currentPage;
        _hasMore = payload.hasMore || payload.currentPage < payload.lastPage;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        if (reset) {
          _items = const [];
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        if (reset) {
          _items = const [];
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadNextPage() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    final nextPage = _currentPage + 1;
    final rawKeyword = _searchCtrl.text.trim();
    try {
      final payload = await ApiClient.instance.searchCaipin(
        page: nextPage,
        limit: _pageSize,
        keyword: rawKeyword.isEmpty ? null : rawKeyword,
      );
      if (!mounted) return;
      setState(() {
        _items = [..._items, ...payload.list];
        _currentPage = payload.currentPage;
        _hasMore = payload.hasMore || payload.currentPage < payload.lastPage;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('加载更多失败，请稍后再试')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingMore = false);
      }
    }
  }

  void _onSubmitSearch() {
    if (_loading) return;
    if (_searchCtrl.text.trim().isEmpty) return;
    SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
    _runSearch(reset: true);
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
                '搜菜谱',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                '输入关键词，发现更多食谱',
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
        title: '暂无匹配菜谱',
        subtitle: '换几个关键词再试',
      );
    }
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      itemCount: _items.length + (_loadingMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == _items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final c = _items[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ResultTile(
            item: c,
            onTap: () {
              final imageUrl = ApiClient.absoluteUrl(c.image);
              Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => RecipeDetailScreen(
                    caipinId: c.id,
                    fallbackTitle: c.name,
                    fallbackDesc: c.desc,
                    fallbackImageUrl: imageUrl,
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

class _ResultTile extends StatelessWidget {
  final CaipinSummary item;
  final VoidCallback onTap;

  const _ResultTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiClient.absoluteUrl(item.image);
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
                  item.desc,
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
                    _tag('${item.calory} kcal', AppColors.brand50, AppColors.brand600),
                    if (item.protein > 0) _tag('蛋白 ${item.protein}', AppColors.slate50, AppColors.slate700),
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
