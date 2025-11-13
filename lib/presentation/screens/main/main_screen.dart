import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/quote_card.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/quote_model.dart';
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

  List<QuoteModel> get filteredQuotes {
    List<QuoteModel> quotes = List.from(MockData.mockQuotes);

    if (selectedTab == 1) {
      quotes = quotes
          .where((q) => q.userId == MockData.currentUser?.email)
          .toList();
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
            'QuoteGallery',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildUserButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
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
              MockData.currentUser?.name ?? 'Користувач',
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
          text: 'Усі цитати',
          isActive: selectedTab == 0,
          onTap: () => setState(() => selectedTab = 0),
        ),
        const SizedBox(width: 8),
        _TabButton(
          text: 'Мої цитати',
          isActive: selectedTab == 1,
          onTap: () => setState(() => selectedTab = 1),
        ),
        const SizedBox(width: 8),
        _TabButton(
          text: 'Улюблені',
          isActive: selectedTab == 2,
          onTap: () => setState(() => selectedTab = 2),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: (value) => setState(() => searchQuery = value),
      decoration: const InputDecoration(
        hintText: 'Пошук цитат...',
        prefixIcon: Icon(Icons.search),
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
        hintText: 'Всі автори',
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: [
        const DropdownMenuItem(value: '', child: Text('Всі автори')),
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
        hintText: 'Всі теги',
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: [
        const DropdownMenuItem(value: '', child: Text('Всі теги')),
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
          'Користувач: ',
          style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
        ),
        Text(
          MockData.currentUser?.name ?? '—',
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
        'Нічого не знайдено.',
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
    final isOwner = quote.userId == MockData.currentUser?.email;

    return QuoteCard(
      quote: quote,
      isOwner: isOwner,
      onFavoriteToggle: () => _handleFavoriteToggle(context, quote),
      onEdit: () => _handleEdit(context),
      onDelete: () => _handleDelete(context),
    );
  }

  void _handleFavoriteToggle(BuildContext context, QuoteModel quote) {
    setState(() {
      quote.isFavorite = !quote.isFavorite;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          quote.isFavorite ? 'Додано до улюблених' : 'Вилучено з улюблених',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleEdit(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Редагування (заглушка)')));
  }

  void _handleDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Видалити цитату?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Скасувати'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Видалення (заглушка)')),
              );
            },
            child: const Text(
              'Видалити',
              style: TextStyle(color: AppTheme.danger),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateScreen()),
        );
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
