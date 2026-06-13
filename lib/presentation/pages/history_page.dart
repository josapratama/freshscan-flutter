import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/services/firestore_history_service.dart';
import '../../data/models/scan_result_model.dart';
import '../widgets/history_tile.dart';
import 'result_page.dart';

/// Halaman riwayat scan
/// Menampilkan semua hasil scan sebelumnya dengan swipe-to-delete dan search
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  static const String routeName = '/history';

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterKategori = 'semua'; // 'semua', 'buah', 'sayuran'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: Consumer<FirestoreHistoryService>(
              builder: (context, historyService, _) {
                if (historyService.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryGreen),
                  );
                }

                final filtered = _getFilteredItems(historyService);

                if (historyService.isEmpty) {
                  return _buildEmptyState(isSearch: false);
                }

                if (filtered.isEmpty) {
                  return _buildEmptyState(isSearch: true);
                }

                return _buildHistoryList(filtered, historyService);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Consumer<FirestoreHistoryService>(
        builder: (_, service, __) =>
            Text('${AppStrings.historyTitle} (${service.jumlahScan})'),
      ),
      actions: [
        Consumer<FirestoreHistoryService>(
          builder: (_, service, __) {
            if (service.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              tooltip: AppStrings.historyDeleteAll,
              onPressed: () => _confirmDeleteAll(context, service),
            );
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Search Bar ─────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: 'Cari buah atau sayuran...',
          hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
          prefixIcon:
              const Icon(Icons.search_rounded, color: AppColors.primaryGreen),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.cardWhite,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.softGreen),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.softGreen),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primaryGreen, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ── Filter Chips ───────────────────────────────────────────────────────────

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          _buildChip('semua', 'Semua', Icons.apps_rounded),
          const SizedBox(width: 8),
          _buildChip('buah', 'Buah 🍎', Icons.apple_rounded),
          const SizedBox(width: 8),
          _buildChip('sayuran', 'Sayuran 🥦', Icons.eco_rounded),
        ],
      ),
    );
  }

  Widget _buildChip(String value, String label, IconData icon) {
    final isSelected = _filterKategori == value;
    return GestureDetector(
      onTap: () => setState(() => _filterKategori = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.softGreen,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textGrey,
          ),
        ),
      ),
    );
  }

  // ── Filter Logic ───────────────────────────────────────────────────────────

  List<ScanResultModel> _getFilteredItems(FirestoreHistoryService service) {
    List<ScanResultModel> items = service.history;

    // Filter kategori
    if (_filterKategori != 'semua') {
      items = items
          .where((item) => item.kategori.toLowerCase() == _filterKategori)
          .toList();
    }

    // Filter search query
    if (_searchQuery.isNotEmpty) {
      final lower = _searchQuery.toLowerCase();
      items = items
          .where((item) =>
              item.namaIndonesia.toLowerCase().contains(lower) ||
              item.namaItem.toLowerCase().contains(lower))
          .toList();
    }

    return items;
  }

  // ── Empty State ────────────────────────────────────────────────────────────

  Widget _buildEmptyState({required bool isSearch}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.softGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearch ? Icons.search_off_rounded : Icons.history_rounded,
                size: 50,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isSearch ? 'Tidak ada hasil' : AppStrings.historyEmpty,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearch
                  ? 'Coba kata kunci lain atau ubah filter'
                  : AppStrings.historyEmptyDesc,
              style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
              textAlign: TextAlign.center,
            ),
          ],
        )
            .animate()
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.0, 1.0),
              duration: 400.ms,
              curve: Curves.easeOut,
            )
            .fadeIn(duration: 400.ms),
      ),
    );
  }

  // ── History List ───────────────────────────────────────────────────────────

  Widget _buildHistoryList(
    List<ScanResultModel> items,
    FirestoreHistoryService service,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildDismissibleTile(context, item, service),
        )
            .animate()
            .slideX(
              begin: 0.2,
              end: 0,
              delay: Duration(milliseconds: index * 50),
              duration: 300.ms,
              curve: Curves.easeOut,
            )
            .fadeIn(
              delay: Duration(milliseconds: index * 50),
              duration: 300.ms,
            );
      },
    );
  }

  Widget _buildDismissibleTile(
    BuildContext context,
    ScanResultModel item,
    FirestoreHistoryService service,
  ) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(),
      confirmDismiss: (_) async {
        return await _confirmDeleteItem(context);
      },
      onDismissed: (_) async {
        await service.hapusScan(item.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '"${item.namaIndonesia}" ${AppStrings.historyDeletedMsg}',
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              action: SnackBarAction(label: 'OK', onPressed: () {}),
            ),
          );
        }
      },
      child: HistoryTile(
        scanResult: item,
        onTap: () => _navigateToResult(context, item),
        onDelete: () async {
          final confirm = await _confirmDeleteItem(context);
          if (confirm == true) {
            await service.hapusScan(item.id);
          }
        },
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.red[400],
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_rounded, color: Colors.white, size: 26),
          SizedBox(height: 4),
          Text(
            'Hapus',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _navigateToResult(BuildContext context, ScanResultModel item) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ResultPage(scanResult: item)));
  }

  // ── Confirmations ──────────────────────────────────────────────────────────

  Future<bool?> _confirmDeleteItem(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.delete),
        content: const Text(AppStrings.historyDeleteItem),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAll(
    BuildContext context,
    FirestoreHistoryService service,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.historyDeleteAll),
        content: const Text(AppStrings.historyDeleteAllConfirm),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await service.hapusSemua();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semua riwayat berhasil dihapus'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
