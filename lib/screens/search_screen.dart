import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asmrapp/presentation/viewmodels/search_viewmodel.dart';
import 'package:asmrapp/widgets/work_grid_view.dart';
import 'package:asmrapp/presentation/layouts/work_layout_strategy.dart';
import 'package:asmrapp/utils/logger.dart';
import 'package:asmrapp/widgets/pagination_controls.dart';

class SearchScreen extends StatelessWidget {
  final String? initialKeyword;

  const SearchScreen({
    super.key,
    this.initialKeyword,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchViewModel(),
      child: SearchScreenContent(initialKeyword: initialKeyword),
    );
  }
}

class SearchScreenContent extends StatefulWidget {
  final String? initialKeyword;

  const SearchScreenContent({
    super.key,
    this.initialKeyword,
  });

  @override
  State<SearchScreenContent> createState() => _SearchScreenContentState();
}

class _SearchScreenContentState extends State<SearchScreenContent> {
  late final TextEditingController _searchController;
  final _layoutStrategy = const WorkLayoutStrategy();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialKeyword);
    
    // 如果有初始关键词，自动执行搜索
    if (widget.initialKeyword?.isNotEmpty == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onSearch();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) return;

    AppLogger.debug('执行搜索: $keyword');
    context.read<SearchViewModel>().search(keyword);
  }

  void _onPageChanged(int page) async {
    final viewModel = context.read<SearchViewModel>();
    await viewModel.loadPage(page);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _getOrderText(String order, String sort) {
    switch (order) {
      case 'create_date':
        return sort == 'desc' ? 'Newest' : 'Oldest';
      case 'release':
        return sort == 'desc' ? 'Release Date (Newest)' : 'Release Date (Oldest)';
      case 'dl_count':
        return sort == 'desc' ? 'Most Downloaded' : 'Least Downloaded';
      case 'price':
        return sort == 'desc' ? 'Price (High)' : 'Price (Low)';
      case 'rate_average_2dp':
        return 'Highest Rated';
      case 'review_count':
        return 'Most Reviewed';
      case 'id':
        return sort == 'desc' ? 'RJ Code (Desc)' : 'RJ Code (Asc)';
      case 'random':
        return 'Random';
      default:
        return 'Sort';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              bottom: 8,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                context.read<SearchViewModel>().clear();
                              },
                            )
                          : null,
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _onSearch(),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // 字幕选项
                      Consumer<SearchViewModel>(
                        builder: (context, viewModel, _) => FilterChip(
                          label: const Text('Subtitle'),
                          selected: viewModel.hasSubtitle,
                          onSelected: (_) => viewModel.toggleSubtitle(),
                          showCheckmark: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 排序选项
                      Consumer<SearchViewModel>(
                        builder: (context, viewModel, _) =>
                            PopupMenuButton<(String, String)>(
                          child: Chip(
                            label: Text(
                                _getOrderText(viewModel.order, viewModel.sort)),
                            deleteIcon:
                                const Icon(Icons.arrow_drop_down, size: 18),
                            onDeleted: null,
                          ),
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: ('create_date', 'desc'), child: Text('Newest')),
  const PopupMenuItem(value: ('release', 'desc'), child: Text('Release Date (Newest)')),
  const PopupMenuItem(value: ('release', 'asc'), child: Text('Release Date (Oldest)')),
  const PopupMenuItem(value: ('dl_count', 'desc'), child: Text('Most Downloaded')),
  const PopupMenuItem(value: ('price', 'asc'), child: Text('Price (Low)')),
  const PopupMenuItem(value: ('price', 'desc'), child: Text('Price (High)')),
  const PopupMenuItem(value: ('rate_average_2dp', 'desc'), child: Text('Highest Rated')),
  const PopupMenuItem(value: ('review_count', 'desc'), child: Text('Most Reviewed')),
  const PopupMenuItem(value: ('id', 'desc'), child: Text('RJ Code (Desc)')),
  const PopupMenuItem(value: ('id', 'asc'), child: Text('RJ Code (Asc)')),
  const PopupMenuItem(value: ('random', 'desc'), child: Text('Random')),
                          ],
                          onSelected: (value) =>
                              viewModel.setOrder(value.$1, value.$2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<SearchViewModel>(
              builder: (context, viewModel, child) {
                Widget? emptyWidget;
                if (viewModel.works.isEmpty && viewModel.keyword.isEmpty) {
                  emptyWidget = const Center(
                    child: Text('Enter keyword to search'),
                  );
                } else if (viewModel.works.isEmpty) {
                  emptyWidget = const Center(
                    child: Text('No results found'),
                  );
                }

                return WorkGridView(
                  works: viewModel.works,
                  isLoading: viewModel.isLoading,
                  error: viewModel.error,
                  onRetry: _onSearch,
                  customEmptyWidget: emptyWidget,
                  layoutStrategy: _layoutStrategy,
                  scrollController: _scrollController,
                  bottomWidget: viewModel.works.isNotEmpty
                      ? PaginationControls(
                          currentPage: viewModel.currentPage,
                          totalPages: viewModel.totalPages,
                          isLoading: viewModel.isLoading,
                          onPageChanged: _onPageChanged,
                        )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
