import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String username;
  final VoidCallback onLogout;
  final VoidCallback? onBack;
  final List<Tab>? tabs;

  const AppHeader({
    super.key,
    required this.title,
    required this.username,
    required this.onLogout,
    this.onBack,
    this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00D09C), Color(0xFF00B386)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: kToolbarHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (onBack != null)
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: onBack,
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SizedBox(
                          width: 200,
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (username.isNotEmpty)
                    PopupMenuButton<String>(
                      offset: const Offset(0, 40),
                      onSelected: (value) {
                        if (value == 'logout') {
                          onLogout();
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem<String>(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, color: Colors.black, size: 18),
                              SizedBox(width: 8),
                              Text('Log out'),
                            ],
                          ),
                        ),
                      ],
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (tabs != null)
            TabBar(
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(color: Colors.white, width: 2.5),
                insets: EdgeInsets.symmetric(horizontal: 16),
              ),
              indicatorSize: TabBarIndicatorSize.label,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.2),
              unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              tabs: tabs!,
            ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (tabs != null ? kTextTabBarHeight : 0));
}
