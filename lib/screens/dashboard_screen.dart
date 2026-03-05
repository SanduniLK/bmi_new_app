import 'package:bmi_new_app/profile/edit_profile_screen.dart';
import 'package:bmi_new_app/screens/bmr_calculator_screen.dart';
import 'package:bmi_new_app/screens/login_screen.dart';
import 'package:bmi_new_app/screens/register_screen.dart';
import 'package:bmi_new_app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import '../../models/bmi_record.dart';
import '../../utils/constants.dart';
import '../../widgets/premium_bmi_card.dart';
import '../../widgets/premium_action_card.dart';
import '../../widgets/premium_chart_widget.dart';
import '../../widgets/activity_tile.dart';
import '../../widgets/water_tracker_widget.dart';  // Add this import
import 'bmi_calculator_screen.dart';
import 'bmi_history_screen.dart';
import './food_recommendations_screen.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  AppUser? _currentUser;
  BMIRecord? _latestBMI;
  bool _isLoading = true;
  
  late AnimationController _fabAnimationController;
  late AnimationController _backgroundController;
  late Animation<double> _fabAnimation;
  
  final List<Widget> _screens = [
    const PremiumHomeScreen(),
    const BMICalculatorScreen(),
    const FoodRecommendationsScreen(),
    const BMIHistoryScreen(),
    
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat(reverse: true);
    
    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fabAnimationController.forward();
    });
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final firestoreService = FirestoreService();
      final userData = await firestoreService.getAppUser(user.uid);
      final latestBMI = await firestoreService.getLatestBMIRecord();
      
      if (mounted) {
        setState(() {
          _currentUser = userData;
          _latestBMI = latestBMI;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? _buildLoadingShimmer()
          : Stack(
              children: [
                // Animated Background
                AnimatedBuilder(
                  animation: _backgroundController,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.topLeft,
                          radius: 1.5,
                          colors: [
                            AppColors.primary.withValues(alpha: 0.1 + _backgroundController.value * 0.1),
                            AppColors.primaryLight.withValues(alpha: 0.05),
                            AppColors.background,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    );
                  },
                ),
                
                // Floating particles effect
                _buildParticles(),
                
                // Main content
                _screens[_selectedIndex],
              ],
            ),
      bottomNavigationBar: _buildPremiumBottomNavBar(),
      floatingActionButton: _buildPremiumFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildLoadingShimmer() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          ).animate().shimmer(duration: 1500.ms),
          const SizedBox(height: 24),
          const Text(
            'Preparing your health data...',
            style: TextStyle(fontSize: 16),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }

  Widget _buildParticles() {
    return Stack(
      children: List.generate(20, (index) {
        final randomX = (index * 37) % 100 / 100;
        final randomY = (index * 73) % 100 / 100;
        final size = (index % 3 + 1) * 2.0;
        
        return Positioned(
          left: MediaQuery.of(context).size.width * randomX,
          top: MediaQuery.of(context).size.height * randomY,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          ).animate().fadeIn().shimmer().then().shake(),
        );
      }),
    );
  }

Widget _buildPremiumBottomNavBar() {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.white.withValues(alpha: 0.9), Colors.white],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, -5),
        ),
      ],
    ),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
            const SizedBox(width: 60), // Space for FAB
            _buildNavItem(4, Icons.person_outlined, Icons.person, 'Profile'), // Using index 4 for Profile
          ],
        ),
      ),
    ),
  );
}

Widget _buildNavItem(int index, IconData outlinedIcon, IconData filledIcon, String label) {
  final isSelected = _selectedIndex == index;
  
  return GestureDetector(
    onTap: () async {
      // Handle profile button (index 4) - Go directly to Edit Profile
      if (index == 4) {
        if (_currentUser != null) {
          // Navigate directly to Edit Profile Screen
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfileScreen(user: _currentUser!),
            ),
          );
          
          // After returning from edit profile
          if (mounted) {
            if (result == true) {
              // Refresh user data if it was updated
              _loadUserData();
            }
            // ALWAYS set back to home (index 0) after returning
            setState(() {
              _selectedIndex = 0;
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please wait, loading user data...'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } 
      // Handle home button (index 0)
      else if (index == 0) {
        setState(() {
          _selectedIndex = 0;
        });
      }
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: isSelected
          ? BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            )
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? filledIcon : outlinedIcon,
            color: isSelected ? Colors.white : Colors.grey,
            size: 22,
          ),
          if (isSelected) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    ).animate().scale(duration: const Duration(milliseconds: 200)),
  );
}

  Widget _buildPremiumFAB() {
    return ScaleTransition(
      scale: _fabAnimation,
      child: FloatingActionButton(
        onPressed: () => setState(() => _selectedIndex = 2),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.restaurant_menu,
            color: Colors.white,
            size: 30,
          ),
        ).animate().shimmer(duration: 2000.ms).then().shake(),
      ),
    );
  }
}

class PremiumHomeScreen extends StatefulWidget {
  const PremiumHomeScreen({super.key});

  @override
  State<PremiumHomeScreen> createState() => _PremiumHomeScreenState();
}

class _PremiumHomeScreenState extends State<PremiumHomeScreen> with TickerProviderStateMixin {
  late AnimationController _greetingController;
  late AnimationController _waveController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _greetingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _greetingController,
      curve: Curves.easeOutQuad,
    ));
    
    _greetingController.forward();
  }

  @override
  void dispose() {
    _greetingController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Premium Header
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _greetingController,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                getGreeting(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              AnimatedBuilder(
                                animation: _waveController,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(0, -_waveController.value * 5),
                                    child: const Text(
                                      '👋',
                                      style: TextStyle(fontSize: 24),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Welcome back,',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            user?.displayName?.split(' ').first ?? 'User',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..shader = AppColors.primaryGradient.createShader(
                                  const Rect.fromLTWH(0, 0, 200, 50),
                                ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Premium Weather Card
                      _buildPremiumWeatherCard(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Premium BMI Card
              const AnimatedCharacterBMICard().animate().fadeIn(
                delay: 200.ms,
                duration: const Duration(milliseconds: 400),
              ).slideY(),

              const SizedBox(height: 32),

              // Quick Actions Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'View All',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ).animate().fadeIn(delay: 350.ms),
                ],
              ),

              const SizedBox(height: 20),

              // Premium Action Cards Grid - Updated with Teal Theme
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  PremiumActionCard(
                    icon: Icons.fitness_center,
                    title: 'Calculate BMI',
                    subtitle: 'Track your progress',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00897B), Color(0xFF4DB6AC)], // Teal gradient
                    ),
                    index: 0,
                    onTap: () => Navigator.pushNamed(context, '/bmi-calculator'),
                  ),
                  PremiumActionCard(
                    icon: Icons.history,
                    title: 'View History',
                    subtitle: 'Check your records',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4DB6AC), Color(0xFF00897B)], // Reverse teal
                    ),
                    index: 1,
                    onTap: () => Navigator.pushNamed(context, '/bmi-history'),
                  ),
                  PremiumActionCard(
                    icon: Icons.restaurant,
                    title: 'Food Tips',
                    subtitle: 'Personalized diet',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00897B), Color(0xFF4DB6AC)],
                    ),
                    index: 2,
                    onTap: () => Navigator.pushNamed(context, '/food-recommendations'),
                  ),
                  
                  PremiumActionCard(
  icon: Icons.local_fire_department,
  title: 'BMR Calc',
  subtitle: 'Metabolic rate',
  gradient: const LinearGradient(
    colors: [Color(0xFF00897B), Color(0xFF4DB6AC)],
  ),
  index: 3,
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const BMRCalculatorScreen()),
  ),
),
 
                ],
              ),

              const SizedBox(height: 32),

              // 🌊 WATER TRACKER WIDGET - ADDED HERE
              const WaterTrackerWidget().animate().fadeIn(
                delay: 400.ms,
                duration: const Duration(milliseconds: 600),
              ).slideY(),

              const SizedBox(height: 32),

              // Health Insights Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Health Insights',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ).animate().fadeIn(delay: 500.ms),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Live',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ).animate().scale(delay: 550.ms),
                ],
              ),

              const SizedBox(height: 20),

              // Premium Chart Widget
              const PremiumChartWidget().animate().fadeIn(
                delay: 600.ms,
                duration: const Duration(milliseconds: 400),
              ),

              const SizedBox(height: 32),

              // Daily Health Tip
              _buildPremiumHealthTip().animate().fadeIn(
                delay: 650.ms,
                duration: const Duration(milliseconds: 400),
              ).scale(),

              const SizedBox(height: 32),

              // Recent Activity
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ).animate().fadeIn(delay: 700.ms),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/bmi-history'),
                    child: Text(
                      'See All',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ).animate().fadeIn(delay: 750.ms),
                ],
              ),

              const SizedBox(height: 20),

              // Activity List
              ActivityTile(
                icon: Icons.fitness_center,
                title: 'BMI Calculated',
                subtitle: 'Your BMI is 24.5 - Normal',
                time: '2 hours ago',
                color: AppColors.success,
                index: 0,
              ),
              ActivityTile(
                icon: Icons.restaurant,
                title: 'Meal Plan Generated',
                subtitle: 'High protein diet recommended',
                time: 'Yesterday',
                color: AppColors.primaryLight,
                index: 1,
              ),
              ActivityTile(
                icon: Icons.trending_up,
                title: 'Weight Updated',
                subtitle: 'You\'ve lost 1.2 kg this week',
                time: '2 days ago',
                color: AppColors.accent,
                index: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumWeatherCard() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.withValues(alpha: 0.1),
                  Colors.amber.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.wb_sunny, color: Colors.orange, size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '31°C',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Sunny',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
// Add this method inside _PremiumHomeScreenState
Future<void> _logout(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            toggleView: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegisterScreen(
                    toggleView: () {
                      // This can be empty
                    },
                  ),
                ),
              );
            },
          ),
        ),
        (route) => false,
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Add this method inside _PremiumHomeScreenState
Widget _buildLogoutButton() {
  return Container(
    margin: const EdgeInsets.only(top: 20, bottom: 10),
    child: CustomButton(
      text: "Log Out",
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _logout(context);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Logout'),
              ),
            ],
          ),
        );
      },
      color: Colors.red,
    ),
  );
}
  Widget _buildPremiumHealthTip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.8),
            AppColors.primaryLight.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Health Tip',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1500),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(20 * (1 - value), 0),
                        child: const Text(
                          'Stay hydrated! Drink at least 8 glasses of water daily for optimal health and better metabolism.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
        ],
      ),
    );
  }
}