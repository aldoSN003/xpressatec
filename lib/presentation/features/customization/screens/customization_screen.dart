import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:xpressatec/core/constants/app_constants.dart';
import 'package:xpressatec/presentation/features/customization/controllers/customization_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/category_mapper.dart';

class CustomizationScreen extends GetView<CustomizationController> {
  const CustomizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<TreeNode<CategoryData>>(
        future: _loadCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('No hay categorías disponibles'),
            );
          }

          return _buildTreeView(context, snapshot.data!);
        },
      ),
    );
  }

  Widget _buildTreeView(BuildContext context, TreeNode<CategoryData> tree) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;

    return TreeView.simpleTyped<CategoryData, TreeNode<CategoryData>>(
      tree: tree,
      showRootNode: false,
      expansionIndicatorBuilder: (context, node) => ChevronIndicator.rightDown(
        tree: node,
        color: Colors.teal[700]!,
        padding: EdgeInsets.all(_getResponsiveValue(
          mobile: 6.0,
          tablet: 8.0,
          desktop: 10.0,
          screenWidth: screenWidth,
        )),
      ),
      indentation: Indentation(
        style: IndentStyle.squareJoint,
        width: _getResponsiveValue(
          mobile: 30.0,
          tablet: 40.0,
          desktop: 50.0,
          screenWidth: screenWidth,
        ),
      ),
      onItemTap: (item) => _handleItemTap(item),
      builder: (context, node) => _buildCategoryTile(
        context,
        node,
        isTablet: isTablet,
        isDesktop: isDesktop,
      ),
    );
  }

  Widget _buildCategoryTile(
      BuildContext context,
      TreeNode<CategoryData> node, {
        required bool isTablet,
        required bool isDesktop,
      }) {
    final categoryData = node.data;
    if (categoryData == null) return const SizedBox.shrink();

    final color = AppColors.getColor(categoryData.colorName);
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive sizing
    final cardMargin = EdgeInsets.symmetric(
      horizontal: _getResponsiveValue(
        mobile: 8.0,
        tablet: 12.0,
        desktop: 16.0,
        screenWidth: screenWidth,
      ),
      vertical: _getResponsiveValue(
        mobile: 4.0,
        tablet: 6.0,
        desktop: 8.0,
        screenWidth: screenWidth,
      ),
    );

    final iconSize = _getResponsiveValue(
      mobile: 50.0,
      tablet: 60.0,
      desktop: 70.0,
      screenWidth: screenWidth,
    );

    final iconInnerSize = _getResponsiveValue(
      mobile: 28.0,
      tablet: 34.0,
      desktop: 40.0,
      screenWidth: screenWidth,
    );

    final fontSize = _getResponsiveValue(
      mobile: 16.0,
      tablet: 18.0,
      desktop: 20.0,
      screenWidth: screenWidth,
    );

    final tileHeight = _getResponsiveValue(
      mobile: 72.0,
      tablet: 85.0,
      desktop: 95.0,
      screenWidth: screenWidth,
    );

    return Card(
      margin: cardMargin,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        height: tileHeight,
        padding: EdgeInsets.symmetric(
          horizontal: _getResponsiveValue(
            mobile: 12.0,
            tablet: 16.0,
            desktop: 20.0,
            screenWidth: screenWidth,
          ),
          vertical: 8.0,
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                categoryData.icon,
                color: Colors.white,
                size: iconInnerSize,
              ),
            ),

            SizedBox(width: _getResponsiveValue(
              mobile: 12.0,
              tablet: 16.0,
              desktop: 20.0,
              screenWidth: screenWidth,
            )),

            // Title
            Expanded(
              child: Text(
                categoryData.name,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            SizedBox(width: _getResponsiveValue(
              mobile: 8.0,
              tablet: 12.0,
              desktop: 16.0,
              screenWidth: screenWidth,
            )),

            // Trailing Icon
            Icon(
              Icons.arrow_forward_ios,
              size: _getResponsiveValue(
                mobile: 16.0,
                tablet: 18.0,
                desktop: 20.0,
                screenWidth: screenWidth,
              ),
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  void _handleItemTap(TreeNode<CategoryData> item) {
    final categoryName = item.data?.name ?? '';
    final colorName = item.data?.colorName ?? '';

    print('Categoría seleccionada: $categoryName');

    Get.snackbar(
      'Categoría Seleccionada',
      categoryName,
      backgroundColor: AppColors.getColor(colorName),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  Future<TreeNode<CategoryData>> _loadCategories() async {
    final categoryMapper = CategoryMapper();
    await categoryMapper.initialize();
    return _buildCategoryTree(categoryMapper);
  }

  TreeNode<CategoryData> _buildCategoryTree(CategoryMapper categoryMapper) {
    final root = TreeNode<CategoryData>.root();
    final categories = categoryMapper.getAllCategories();
    final icons = AppConstants.categoryIcons;

    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      final colorName = categoryMapper.getColorForCategory(category);
      final icon = i < icons.length ? icons[i] : Icons.category;

      root.add(
        TreeNode<CategoryData>(
          key: category,
          data: CategoryData(
            name: category,
            colorName: colorName ?? 'gris',
            icon: icon,
          ),
        ),
      );
    }

    return root;
  }

  double _getResponsiveValue({
    required double mobile,
    required double tablet,
    required double desktop,
    required double screenWidth,
  }) {
    if (screenWidth > 1200) return desktop;
    if (screenWidth > 600) return tablet;
    return mobile;
  }
}

// Data class to hold category information
class CategoryData {
  final String name;
  final String colorName;
  final IconData icon;

  CategoryData({
    required this.name,
    required this.colorName,
    required this.icon,
  });
}