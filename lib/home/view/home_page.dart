import 'package:companion_connect/app/utils/responsive.dart';
import 'package:companion_connect/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// Home page that adapts to different screen sizes
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<NavigationDestination> _mobileDestinations = [
    const NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    const NavigationDestination(
      icon: Icon(Icons.explore_outlined),
      selectedIcon: Icon(Icons.explore),
      label: 'Explore',
    ),
    const NavigationDestination(
      icon: Icon(Icons.favorite_outline),
      selectedIcon: Icon(Icons.favorite),
      label: 'Favorites',
    ),
    const NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  final List<NavigationRailDestination> _tabletDestinations = [
    const NavigationRailDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: Text('Home'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.explore_outlined),
      selectedIcon: Icon(Icons.explore),
      label: Text('Explore'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.favorite_outline),
      selectedIcon: Icon(Icons.favorite),
      label: Text('Favorites'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: Text('Profile'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: _buildMobileLayout(context),
      tabletBody: _buildTabletLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Companion Connect'),
        centerTitle: true,
      ),
      body: _buildBody(context),
      bottomNavigationBar: context.isLandscape 
          ? null // Hide bottom nav in landscape mobile for more content space
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: _mobileDestinations,
            ),
      drawer: context.isLandscape 
          ? Drawer(
              child: ListView(
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Text(
                      'Companion Connect',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  ..._mobileDestinations.asMap().entries.map((entry) {
                    final index = entry.key;
                    final destination = entry.value;
                    return ListTile(
                      leading: _selectedIndex == index 
                          ? destination.selectedIcon 
                          : destination.icon,
                      title: Text(destination.label),
                      selected: _selectedIndex == index,
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                        Navigator.of(context).pop();
                      },
                    );
                  }),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Companion Connect'),
        centerTitle: true,
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            // Use different label types based on screen space
            labelType: context.isLandscape && context.screenWidth > 1200
                ? NavigationRailLabelType.all
                : context.isLandscape
                    ? NavigationRailLabelType.selected
                    : NavigationRailLabelType.all,
            destinations: _tabletDestinations,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _buildBody(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent(context);
      case 1:
        return _buildExploreContent(context);
      case 2:
        return _buildFavoritesContent(context);
      case 3:
        return _buildProfileContent(context);
      default:
        return _buildHomeContent(context);
    }
  }

  Widget _buildHomeContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.isTabletOrLarger ? 24.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Companion Connect',
            style: context.isTabletOrLarger 
                ? Theme.of(context).textTheme.headlineMedium
                : Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            'Your AI companion is ready to help you connect and communicate.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          if (context.isTabletOrLarger)
            _buildTabletGrid(context)
          else
            _buildMobileList(context),
        ],
      ),
    );
  }

  Widget _buildTabletGrid(BuildContext context) {
    // More sophisticated column count logic for different screen sizes
    int crossAxisCount = 2; // Default for tablet portrait
    if (context.isDesktop) {
      crossAxisCount = context.isLandscape ? 4 : 3;
    } else if (context.isTablet) {
      crossAxisCount = context.isLandscape ? 3 : 2;
    }
    
    return Expanded(
      child: GridView.count(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildFeatureCard(
            context,
            'Chat',
            'Start a conversation with your AI companion',
            Icons.chat_bubble_outline,
          ),
          _buildFeatureCard(
            context,
            'Learn',
            'Discover new topics and expand your knowledge',
            Icons.school_outlined,
          ),
          _buildFeatureCard(
            context,
            'Create',
            'Generate content and ideas with AI assistance',
            Icons.create_outlined,
          ),
          _buildFeatureCard(
            context,
            'Explore',
            'Find new connections and communities',
            Icons.explore_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList(BuildContext context) {
    if (context.isLandscape) {
      // Use a 2-column grid for mobile landscape
      return Expanded(
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildFeatureCard(
              context,
              'Chat',
              'Start a conversation with your AI companion',
              Icons.chat_bubble_outline,
            ),
            _buildFeatureCard(
              context,
              'Learn',
              'Discover new topics and expand your knowledge',
              Icons.school_outlined,
            ),
            _buildFeatureCard(
              context,
              'Create',
              'Generate content and ideas with AI assistance',
              Icons.create_outlined,
            ),
            _buildFeatureCard(
              context,
              'Explore',
              'Find new connections and communities',
              Icons.explore_outlined,
            ),
          ],
        ),
      );
    }
    
    // Original vertical list for mobile portrait
    return Expanded(
      child: ListView(
        children: [
          _buildFeatureCard(
            context,
            'Chat',
            'Start a conversation with your AI companion',
            Icons.chat_bubble_outline,
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            'Learn',
            'Discover new topics and expand your knowledge',
            Icons.school_outlined,
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            'Create',
            'Generate content and ideas with AI assistance',
            Icons.create_outlined,
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            'Explore',
            'Find new connections and communities',
            Icons.explore_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, String description, IconData icon) {
    // Adjust card height based on orientation and device type
    double? cardHeight;
    if (context.isMobile && context.isLandscape) {
      cardHeight = 140; // Shorter cards for mobile landscape
    } else if (context.isTabletOrLarger && context.isLandscape) {
      cardHeight = 160; // Medium height for tablet landscape
    }
    
    return SizedBox(
      height: cardHeight,
      child: Card(
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title feature coming soon!')),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: context.isTabletOrLarger ? 48 : 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: context.isTabletOrLarger
                      ? Theme.of(context).textTheme.titleLarge
                      : Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                    maxLines: context.isMobile && context.isLandscape ? 2 : 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExploreContent(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.explore, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Explore content coming soon!', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildFavoritesContent(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Favorites feature coming soon!', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Profile settings coming soon!', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}