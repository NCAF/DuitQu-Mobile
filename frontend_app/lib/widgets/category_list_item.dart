import 'package:flutter/material.dart';

class CategoryListItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final String type;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final int index; // Tambahkan parameter index

  const CategoryListItem({
    super.key,
    required this.name,
    required this.icon,
    required this.type,
    required this.onEdit,
    required this.index, // Tambahkan required index
    this.onDelete,
  });

  // Daftar warna pastel yang harmonis
  static const List<Color> cardColors = [
    Color(0xFFF8E8EE), // Light Pink
    Color(0xFFE3F2C1), // Light Mint
    Color(0xFFDEF5E5), // Soft Green
    Color(0xFFFFEBEB), // Peach
    Color(0xFFE5E0FF), // Lavender
    Color(0xFFFFF8E1), // Light Yellow
    Color(0xFFE0F7FA), // Light Cyan
    Color(0xFFF5E6CC), // Light Brown
  ];

  @override
  Widget build(BuildContext context) {
    final isExpense = type == 'expense';
    final color = isExpense ? const Color(0xFFE76161) : const Color(0xFF7DB9B6);
    final cardColor = cardColors[index % cardColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shadowColor: color.withOpacity(0.3),
        color: cardColor, // Set background warna card
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: const Color(0xFFFFC0CB).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withOpacity(0.7), // White background untuk icon
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFD14D72),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          type.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: onEdit,
                      tooltip: 'Edit',
                      style: IconButton.styleFrom(
                        foregroundColor: const Color(0xFFD14D72),
                        backgroundColor: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    if (onDelete != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: onDelete,
                        tooltip: 'Delete',
                        style: IconButton.styleFrom(
                          foregroundColor: const Color(0xFFE76161),
                          backgroundColor: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
