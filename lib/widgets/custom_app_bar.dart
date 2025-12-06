import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tifli/features/navigation/presentation/state/app_bar_config.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    // Try to read AppBarConfig, but make it optional
    final appBarConfig = context.watch<AppBarConfig?>();
    final effectiveTitle = title ?? appBarConfig?.title ?? '';
    final canPop = Navigator.of(context).canPop();

    return AppBar(
      title: Text(
        effectiveTitle,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: canPop
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            )
          : IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                final scaffoldKey = context.read<GlobalKey<ScaffoldState>?>();
                if (scaffoldKey != null && scaffoldKey.currentState != null) {
                  scaffoldKey.currentState!.openDrawer();
                } else {
                  Scaffold.of(context).openDrawer();
                }
              },
            ),
      actions: actions ?? appBarConfig?.actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
