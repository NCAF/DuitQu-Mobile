// lib/controllers/category_controller.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../utils/constants.dart';

class CategoryController {
  static final CategoryController _instance = CategoryController._internal();
  factory CategoryController() => _instance;
  CategoryController._internal();

  static const String baseUrl = '${ApiConstants.baseUrl}/categories';

  Future<List<Category>> getAllCategories() async {
    try {
      print('📍 GET Request to: $baseUrl');
      final response = await http.get(Uri.parse(baseUrl));
      print('📥 Response Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          final categories = (data['data'] as List)
              .map((item) => Category.fromJson(item))
              .toList();
          print('✅ Successfully fetched ${categories.length} categories');
          return categories;
        }
        print('❌ API returned status false');
        throw 'Failed to load categories: API returned status false';
      }
      print('❌ Failed with status code: ${response.statusCode}');
      throw 'Failed to load categories: Server returned ${response.statusCode}';
    } catch (e) {
      print('❌ Error getting categories: $e');
      throw 'Error getting categories: $e';
    }
  }

  Future<Category> addCategory(String name, String type) async {
    try {
      print('📍 POST Request to: $baseUrl');
      print('📤 Request Body: {"name": "$name", "type": "$type"}');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'type': type}),
      );

      print('📥 Response Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          final category = Category.fromJson(data['data']);
          print('✅ Successfully created category: ${category.name}');
          return category;
        }
        print('❌ API returned status false');
        throw 'Failed to add category: API returned status false';
      }
      print('❌ Failed with status code: ${response.statusCode}');
      throw 'Failed to add category: Server returned ${response.statusCode}';
    } catch (e) {
      print('❌ Error adding category: $e');
      throw 'Error adding category: $e';
    }
  }

  Future<Category> updateCategory(int id, String name, String type) async {
    try {
      print('📍 PUT Request to: $baseUrl/$id');
      print('📤 Request Body: {"name": "$name", "type": "$type"}');

      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'type': type}),
      );

      print('📥 Response Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          final category = Category.fromJson(data['data']);
          print('✅ Successfully updated category: ${category.name}');
          return category;
        }
        print('❌ API returned status false');
        throw 'Failed to update category: API returned status false';
      }
      print('❌ Failed with status code: ${response.statusCode}');
      throw 'Failed to update category: Server returned ${response.statusCode}';
    } catch (e) {
      print('❌ Error updating category: $e');
      throw 'Error updating category: $e';
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      print('📍 DELETE Request to: $baseUrl/$id');

      final response = await http.delete(Uri.parse('$baseUrl/$id'));

      print('📥 Response Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final success = data['status'] == true;
        if (success) {
          print('✅ Successfully deleted category with ID: $id');
        } else {
          print('❌ Failed to delete: API returned status false');
        }
        return success;
      }
      print('❌ Failed with status code: ${response.statusCode}');
      throw 'Failed to delete category: Server returned ${response.statusCode}';
    } catch (e) {
      print('❌ Error deleting category: $e');
      throw 'Error deleting category: $e';
    }
  }
}
