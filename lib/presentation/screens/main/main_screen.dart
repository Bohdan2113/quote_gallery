import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/quote_card.dart';
import '../../../data/models/quote_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../state/quotes_provider.dart';
import '../create/create_screen.dart';
import '../profile/profile_screen.dart';
import 'quote_detail_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedTab = 0; // 0 - Усі, 1 - Мої, 2 - Улюблені
  String searchQuery = '';
  String selectedAuthor = '';
  String selectedTag = '';
  final AuthRepository _authRepository = AuthRepository();
  final _analytics = AnalyticsService();

  List<QuoteModel> _applyFilters(List<QuoteModel> source) {
    var quotes = List<QuoteModel>.from(source);

    if (selectedTab == 1) {
      final currentUserUid = _authRepository.currentUser?.uid;
      quotes = quotes.where((q) => q.userId == currentUserUid).toList();
    } else if (selectedTab == 2) {
      quotes = quotes.where((q) => q.isFavorite).toList();
    }

    if (searchQuery.isNotEmpty) {
      quotes = quotes.where((q) {
        final query = searchQuery.toLowerCase();
        return q.text.toLowerCase().contains(query) ||
            q.author.toLowerCase().contains(query) ||
            q.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }

    if (selectedAuthor.isNotEmpty) {
      quotes = quotes.where((q) => q.author == selectedAuthor).toList();
    }

    if (selectedTag.isNotEmpty) {
      quotes = quotes.where((q) => q.tags.contains(selectedTag)).toList();
    }

    return quotes;
  }

  List<String> _allAuthors(List<QuoteModel> source) {
    return source.map((q) => q.author).toSet().toList()..sort();
  }

  List<String> _allTags(List<QuoteModel> source) {
    return source.expand((q) => q.tags).toSet().toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(context),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      decoration: _buildBackgroundDecoration(),
      child: SafeArea(
        child: Consumer<QuotesProvider>(
          builder: (context, quotesProvider, _) {
            return Column(
              children: [
                _buildHeader(context, quotesProvider),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildFiltersSection(quotesProvider),
                        const SizedBox(height: 16),
                        _buildQuotesGrid(context, quotesProvider),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF8FAFC), AppTheme.background],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, QuotesProvider quotesProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              _buildHeaderRow(context),
              const SizedBox(height: 16),
              _buildTabs(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersSection(QuotesProvider quotesProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              _buildSearchField(),
              const SizedBox(height: 12),
              _buildFiltersRow(quotesProvider),
              const SizedBox(height: 8),
              _buildUserInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    return Row(
      children: [
        _buildLogo(),
        const SizedBox(width: 12),
        _buildTitle(),
        _buildUserButton(context),
      ],
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, Color(0xFF7B85FF)],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'QG',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.appTitle,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildUserButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        await _analytics.logOpenProfile();
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileScreen()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            Text(
              _authRepository.currentUser?.displayName ?? AppStrings.user,
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Text('▾', style: TextStyle(color: AppTheme.primary)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        _TabButton(
          text: AppStrings.allQuotes,
          isActive: selectedTab == 0,
          onTap: () async {
            await _analytics.logViewAllQuotes();
            setState(() => selectedTab = 0);
          },
        ),
        const SizedBox(width: 8),
        _TabButton(
          text: AppStrings.myQuotes,
          isActive: selectedTab == 1,
          onTap: () async {
            await _analytics.logViewMyQuotes();
            setState(() => selectedTab = 1);
          },
        ),
        const SizedBox(width: 8),
        _TabButton(
          text: AppStrings.favorites,
          isActive: selectedTab == 2,
          onTap: () async {
            await _analytics.logViewFavorites();
            setState(() => selectedTab = 2);
          },
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: (value) async {
        setState(() => searchQuery = value);
        if (value.isNotEmpty) {
          await _analytics.logSearch(query: value);
        }
      },
      decoration: InputDecoration(
        hintText: AppStrings.searchPlaceholder,
        prefixIcon: const Icon(Icons.search),
      ),
    );
  }

  Widget _buildFiltersRow(QuotesProvider quotesProvider) {
    final baseQuotes = quotesProvider.quotes;
    return Row(
      children: [
        Expanded(child: _buildAuthorFilter(baseQuotes)),
        const SizedBox(width: 12),
        Expanded(child: _buildTagFilter(baseQuotes)),
      ],
    );
  }

  Widget _buildAuthorFilter(List<QuoteModel> baseQuotes) {
    final authors = _allAuthors(baseQuotes);
    return DropdownButtonFormField<String>(
      menuMaxHeight: 130,
      initialValue: selectedAuthor.isEmpty ? null : selectedAuthor,
      decoration: const InputDecoration(
        hintText: AppStrings.allAuthors,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: [
        const DropdownMenuItem(value: '', child: Text(AppStrings.allAuthors)),
        ...authors.map(
          (author) => DropdownMenuItem(value: author, child: Text(author)),
        ),
      ],
      onChanged: (value) {
        setState(() => selectedAuthor = value ?? '');
      },
    );
  }

  Widget _buildTagFilter(List<QuoteModel> baseQuotes) {
    final tags = _allTags(baseQuotes);
    return DropdownButtonFormField<String>(
      menuMaxHeight: 130,
      initialValue: selectedTag.isEmpty ? null : selectedTag,
      decoration: const InputDecoration(
        hintText: AppStrings.allTags,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: [
        const DropdownMenuItem(value: '', child: Text(AppStrings.allTags)),
        ...tags.map((tag) => DropdownMenuItem(value: tag, child: Text(tag))),
      ],
      onChanged: (value) {
        setState(() => selectedTag = value ?? '');
      },
    );
  }

  Widget _buildUserInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '${AppStrings.user}: ',
          style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
        ),
        Text(
          _authRepository.currentUser?.displayName ?? '—',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildQuotesGrid(BuildContext context, QuotesProvider quotesProvider) {
    if (quotesProvider.status == QuotesStatus.loading ||
        quotesProvider.status == QuotesStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (quotesProvider.status == QuotesStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              quotesProvider.errorMessage ??
                  'Сталася неочікувана помилка при завантаженні.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.danger, fontSize: 14),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => quotesProvider.loadQuotes(),
              child: const Text('Повторити спробу'),
            ),
          ],
        ),
      );
    }

    final filtered = _applyFilters(quotesProvider.quotes);

    return filtered.isEmpty
        ? _buildEmptyState()
        : _buildQuotesGridView(context, filtered);
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        AppStrings.nothingFound,
        style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
      ),
    );
  }

  Widget _buildQuotesGridView(BuildContext context, List<QuoteModel> quotes) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallWidth = constraints.maxWidth < 600;
        final crossAxisCount = isSmallWidth ? 1 : 2;
        final childAspectRatio = isSmallWidth ? 3.0 : 5.0;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: quotes.length,
          itemBuilder: (context, index) {
            return _buildQuoteCard(context, quotes[index]);
          },
        );
      },
    );
  }

  Widget _buildQuoteCard(BuildContext context, QuoteModel quote) {
    final isOwner = quote.userId == _authRepository.currentUser?.uid;

    return QuoteCard(
      quote: quote,
      onTap: () => _openDetails(context, quote, isOwner),
      isOwner: isOwner,
      onFavoriteToggle: () => _handleFavoriteToggle(context, quote),
      onEdit: () => _handleEdit(context, quote),
      onDelete: () => _handleDelete(context, quote),
    );
  }

  void _openDetails(BuildContext context, QuoteModel quote, bool isOwner) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuoteDetailScreen(quote: quote, isOwner: isOwner),
      ),
    );
  }

  Future<void> _handleFavoriteToggle(
    BuildContext context,
    QuoteModel quote,
  ) async {
    await context.read<QuotesProvider>().toggleFavorite(quote);

    if (quote.isFavorite) {
      await _analytics.logAddToFavorites(quoteId: quote.id);
    } else {
      await _analytics.logRemoveFromFavorites(quoteId: quote.id);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            quote.isFavorite
                ? AppStrings.addedToFavorites
                : AppStrings.removedFromFavorites,
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _handleEdit(BuildContext context, QuoteModel quote) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateScreen(initialQuote: quote),
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context, QuoteModel quote) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteQuote),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              AppStrings.delete,
              style: TextStyle(color: AppTheme.danger),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await context.read<QuotesProvider>().deleteQuote(quote.id);
      await _analytics.logDeleteQuote();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text(AppStrings.quoteDeleted)));
      }
    }
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        await _analytics.logOpenCreateQuote();
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateScreen()),
          );
        }
      },
      backgroundColor: AppTheme.primary,
      child: const Icon(Icons.add, size: 30),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.text,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    colors: [Color(0x1F5B6CFF), Color(0x0F5B6CFF)],
                  )
                : null,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive ? const Color(0x1F5B6CFF) : Colors.transparent,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isActive ? AppTheme.primary : AppTheme.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
