import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class XpressatecHeaderAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const XpressatecHeaderAppBar({
    super.key,
    this.showBack = false,
    this.showMenu = false,
    this.onMenuTap,
  });

  final bool showBack;
  final bool showMenu;
  final VoidCallback? onMenuTap;

  @override
  Size get preferredSize => const Size.fromHeight(200);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;

    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: color,
      flexibleSpace: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SvgPicture.asset(
                'assets/images/imagen.svg',
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
            if (showBack)
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: color),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            if (showMenu)
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.menu, color: color),
                  onPressed: onMenuTap,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
