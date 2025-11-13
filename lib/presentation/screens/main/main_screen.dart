import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/quote_card.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/quote_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/services/analytics_service.dart';
import '../profile/profile_screen.dart';
import '../create/create_screen.dart';

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

  List<QuoteModel> get filteredQuotes {
    List<QuoteModel> quotes = List.from(MockData.mockQuotes);

    if (selectedTab == 1) {
      final currentUserEmail = _authRepository.currentUser?.email;
      quotes = quotes.where((q) => q.userId == currentUserEmail).toList();
    } else if (selectedTab == 2) {
      quotes = quotes.where((q) => q.isFavorite).toList();
    }

    if (searchQuery.isNotEmpty) {
      quotes = quotes.where((q) {
        return q.text.toLowerCase().contains(searchQuery.toLowerCase()) ||
            q.author.toLowerCase().contains(searchQuery.toLowerCase()) ||
            q.tags.any(
              (tag) => tag.toLowerCase().contains(searchQuery.toLowerCase()),
            );
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

  List<String> get allAuthors {
    return MockData.mockQuotes.map((q) => q.author).toSet().toList()..sort();
  }

  List<String> get allTags {
    return MockData.mockQuotes.expand((q) => q.tags).toSet().toList()..sort();
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
        child: Column(
          children: [_buildHeader(context), _buildQuotesGrid(context)],
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

  Widget _buildHeader(BuildContext context) {
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
              const SizedBox(height: 16),
              _buildSearchField(),
              const SizedBox(height: 12),
              _buildFiltersRow(),
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

  Widget _buildFiltersRow() {
    return Row(
      children: [
        Expanded(child: _buildAuthorFilter()),
        const SizedBox(width: 12),
        Expanded(child: _buildTagFilter()),
      ],
    );
  }

  Widget _buildAuthorFilter() {
    return DropdownButtonFormField<String>(
      menuMaxHeight: 130,
      initialValue: selectedAuthor.isEmpty ? null : selectedAuthor,
      decoration: const InputDecoration(
        hintText: AppStrings.allAuthors,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: [
        const DropdownMenuItem(value: '', child: Text(AppStrings.allAuthors)),
        ...allAuthors.map((author) {
          return DropdownMenuItem(value: author, child: Text(author));
        }),
      ],
      onChanged: (value) {
        setState(() => selectedAuthor = value ?? '');
      },
    );
  }

  Widget _buildTagFilter() {
    return DropdownButtonFormField<String>(
      menuMaxHeight: 130,
      initialValue: selectedTag.isEmpty ? null : selectedTag,
      decoration: const InputDecoration(
        hintText: AppStrings.allTags,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: [
        const DropdownMenuItem(value: '', child: Text(AppStrings.allTags)),
        ...allTags.map((tag) {
          return DropdownMenuItem(value: tag, child: Text(tag));
        }),
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

  Widget _buildQuotesGrid(BuildContext context) {
    final quotes = filteredQuotes;

    return Expanded(
      child: quotes.isEmpty
          ? _buildEmptyState()
          : _buildQuotesGridView(context, quotes),
    );
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
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: quotes.length,
      itemBuilder: (context, index) {
        return _buildQuoteCard(context, quotes[index]);
      },
    );
  }

  Widget _buildQuoteCard(BuildContext context, QuoteModel quote) {
    final isOwner = quote.userId == _authRepository.currentUser?.email;

    return QuoteCard(
      quote: quote,
      isOwner: isOwner,
      onFavoriteToggle: () => _handleFavoriteToggle(context, quote),
      onEdit: () => _handleEdit(context),
      onDelete: () => _handleDelete(context),
    );
  }

  Future<void> _handleFavoriteToggle(
    BuildContext context,
    QuoteModel quote,
  ) async {
    setState(() {
      quote.isFavorite = !quote.isFavorite;
    });

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

  void _handleEdit(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(AppStrings.editPlaceholder)));
  }

  Future<void> _handleDelete(BuildContext context) async {
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
