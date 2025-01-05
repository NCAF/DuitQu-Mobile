import 'package:flutter/material.dart';
import '../controllers/category_controller.dart';
import '../models/category.dart';
import '../widgets/category_list_item.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen>
    with SingleTickerProviderStateMixin {
  final CategoryController _controller = CategoryController();
  List<Category> _categories = [];
  bool _isLoading = false;
  late TabController _tabController;

  // Pink theme colors
  final mainPink = const Color(0xFFD14D72); // Main pink
  final lightPink = const Color(0xFFFFC0CB); // Light pink
  final darkPink = const Color(0xFFBF4266); // Dark pink for gradients
  final expenseRed = const Color(0xFFE76161); // Expense color
  final incomeGreen = const Color(0xFF7DB9B6); // Income color

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final categories = await _controller.getAllCategories();
      setState(() => _categories = categories);
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? const Color(0xFFE76161) : const Color(0xFF7DB9B6),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> _deleteCategory(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          'Delete ${category.name}?',
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFFD14D72),
          ),
        ),
        content: Text(
          'This action cannot be undone. Are you sure you want to delete this category?',
          style: TextStyle(color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: mainPink),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE76161),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _controller.deleteCategory(category.id!);
        _showMessage('Category deleted successfully');
        _loadCategories();
      } catch (e) {
        _showMessage(e.toString(), isError: true);
      }
    }
  }

  void _showAddEditDialog([Category? category]) {
    final nameController = TextEditingController(text: category?.name);
    String selectedType = category?.type ?? 'expense';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        category == null ? Icons.add_circle : Icons.edit,
                        color: mainPink,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        category == null ? 'New Category' : 'Edit Category',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: mainPink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Category Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      prefixIcon: Icon(Icons.category, color: mainPink),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: mainPink, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: lightPink),
                      ),
                    ),
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: lightPink),
                    ),
                    child: Column(
                      children: [
                        _buildRadioTile(
                          'expense',
                          'Expense',
                          Icons.arrow_downward,
                          expenseRed,
                          selectedType,
                          (value) => setState(() => selectedType = value!),
                        ),
                        Divider(height: 1, color: lightPink),
                        _buildRadioTile(
                          'income',
                          'Income',
                          Icons.arrow_upward,
                          incomeGreen,
                          selectedType,
                          (value) => setState(() => selectedType = value!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            _showMessage('Please enter category name',
                                isError: true);
                            return;
                          }

                          try {
                            if (category == null) {
                              await _controller.addCategory(name, selectedType);
                              if (mounted) {
                                _showMessage('Category added successfully');
                              }
                            } else {
                              await _controller.updateCategory(
                                  category.id!, name, selectedType);
                              if (mounted) {
                                _showMessage('Category updated successfully');
                              }
                            }
                            if (mounted) {
                              Navigator.pop(context);
                              _loadCategories();
                            }
                          } catch (e) {
                            _showMessage(e.toString(), isError: true);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainPink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(category == null ? 'Create' : 'Update'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRadioTile(
    String value,
    String title,
    IconData icon,
    Color color,
    String groupValue,
    Function(String?) onChanged,
  ) {
    return RadioListTile<String>(
      title: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: color,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  List<Category> _getCategoriesByType(String type) {
    return _categories.where((category) => category.type == type).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: AppBarTheme(
          backgroundColor: mainPink,
          elevation: 0,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: mainPink,
          elevation: 4,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Categories',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [mainPink, darkPink],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.black.withOpacity(0.6),
                indicatorWeight: 3,
                tabs: [
                  Tab(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_downward, color: expenseRed),
                          const SizedBox(width: 8),
                          const Text(
                            'EXPENSE',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Tab(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_upward, color: incomeGreen),
                          const SizedBox(width: 8),
                          const Text(
                            'INCOME',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.grey[100]!,
                Colors.white,
              ],
            ),
          ),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCategoryList(_getCategoriesByType('expense')),
                    _buildCategoryList(_getCategoriesByType('income')),
                  ],
                ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddEditDialog(),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [mainPink, darkPink],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList(List<Category> categories) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined,
                size: 80, color: mainPink.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No categories yet',
              style: TextStyle(
                fontSize: 18,
                color: mainPink,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _showAddEditDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Category'),
              style: ElevatedButton.styleFrom(
                backgroundColor: mainPink,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryListItem(
          name: category.name,
          icon: Icons.category,
          type: category.type,
          onEdit: () => _showAddEditDialog(category),
          onDelete: () => _deleteCategory(category),
          index: index, // Tambahkan index
        );
      },
    );
  }
}
