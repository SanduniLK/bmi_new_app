import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../../utils/constants.dart';
import '../../widgets/flowing_water_background.dart';

class WaterTrackingPage extends StatefulWidget {
  const WaterTrackingPage({super.key});

  @override
  State<WaterTrackingPage> createState() => _WaterTrackingPageState();
}

class _WaterTrackingPageState extends State<WaterTrackingPage> with TickerProviderStateMixin {
  int _currentGlasses = 0;
  final int _targetGlasses = 8;
  int _currentDay = 0;
  double _waterTemperature = 22.5;
  bool _isReminderEnabled = true;
  
  late AnimationController _waveController;
  late AnimationController _dropController;
  late AnimationController _flowController;
  late AnimationController _pulseController;
  late AnimationController _temperatureController;
  late Animation<double> _waveAnimation;
  late Animation<double> _pulseAnimation;
  
  List<bool> _glassHistory = List.generate(30, (index) => false);
  List<double> _dailyIntake = List.generate(7, (index) => Random().nextInt(8).toDouble());

  @override
  void initState() {
    super.initState();
    _loadWaterIntake();
    _setupAnimations();
  }

  void _setupAnimations() {
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _dropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _flowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _temperatureController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    
    _waveAnimation = Tween<double>(begin: 0, end: 0.2).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );
    
    _pulseAnimation = Tween<double>(begin: 1, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadWaterIntake() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _currentGlasses = prefs.getInt('water_intake') ?? 0;
        final history = prefs.getStringList('water_history') ?? [];
        for (int i = 0; i < history.length; i++) {
          if (i < _glassHistory.length) {
            _glassHistory[i] = history[i] == 'true';
          }
        }
      });
    }
  }

  Future<void> _saveWaterIntake() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('water_intake', _currentGlasses);
    await prefs.setStringList(
      'water_history', 
      _glassHistory.map((e) => e.toString()).toList()
    );
  }

  void _addWater() {
    if (_currentGlasses < _targetGlasses) {
      setState(() {
        _currentGlasses++;
        _glassHistory[_currentDay] = true;
      });
      _saveWaterIntake();
      _dropController.forward(from: 0.0);
    }
  }

  void _addLargeWater() {
    if (_currentGlasses + 2 <= _targetGlasses) {
      setState(() {
        _currentGlasses += 2;
        _glassHistory[_currentDay] = true;
      });
      _saveWaterIntake();
      _dropController.forward(from: 0.0);
    }
  }

  void _resetWater() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Water Intake'),
        content: const Text('Are you sure you want to reset today\'s water intake?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _currentGlasses = 0;
                _glassHistory[_currentDay] = false;
              });
              _saveWaterIntake();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _nextDay() {
    if (_currentDay < 29) {
      setState(() {
        _currentDay++;
        _currentGlasses = 0;
      });
    }
  }

  void _previousDay() {
    if (_currentDay > 0) {
      setState(() {
        _currentDay--;
        _currentGlasses = 0;
      });
    }
  }

  double get _progress => _currentGlasses / _targetGlasses;

  int _calculateWeeklyAverage() {
    double total = 0;
    int days = 0;
    for (int i = max(0, _currentDay - 6); i <= _currentDay; i++) {
      if (_glassHistory[i]) total += _targetGlasses;
      days++;
    }
    return days > 0 ? (total / days).round() : 0;
  }

  int _calculateStreak() {
    int streak = 0;
    for (int i = _currentDay; i >= 0; i--) {
      if (_glassHistory[i]) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  @override
  void dispose() {
    _waveController.dispose();
    _dropController.dispose();
    _flowController.dispose();
    _pulseController.dispose();
    _temperatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Premium Flowing Water Background (kept as is)
          FlowingWaterBackground(
            flowController: _flowController,
            progress: _progress,
          ),
          
          // Main Content - Clean, readable text
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Premium Header with Back Button and Temperature
                          _buildPremiumHeader(),
                          
                          const SizedBox(height: 20),

                          // Main Water Glass with 3D Effect
                          Center(
                            child: _buildMainWaterGlass3D(),
                          ),

                          const SizedBox(height: 20),

                          // Premium Stats Cards
                          _buildPremiumStats(),

                          const SizedBox(height: 20),

                          // Quick Add Buttons
                          _buildQuickAddButtons(),

                          const SizedBox(height: 20),

                          // Daily Glasses Grid
                          _buildDailyGlasses(),

                          const SizedBox(height: 20),

                          // Day Navigation with Progress
                          _buildDayNavigation(),

                          const SizedBox(height: 20),

                          // Weekly Chart
                          _buildWeeklyChart(),

                          const SizedBox(height: 20),

                          // Achievement Badges
                          _buildAchievementBadges(),

                          const SizedBox(height: 16),

                          // Reminder Toggle
                          _buildReminderToggle(),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back Button with Glow
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.3),
                    Colors.white.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),

        // Title with better readability
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'WATER tracking',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ),

        // Temperature with Animation
        AnimatedBuilder(
          animation: _temperatureController,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.thermostat,
                    color: Colors.orange.shade200,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_waterTemperature.toStringAsFixed(1)}°C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ).animate().shake(
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
            );
          },
        ),
      ],
    );
  }

 Widget _buildMainWaterGlass3D() {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(seconds: 1),
    curve: Curves.elasticOut,
    builder: (context, scale, child) {
      return Transform.scale(
        scale: scale,
        child: Container(
          width: 220,
          height: 320,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.white.withValues(alpha: 0.4),
                Colors.white.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(60),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(58),
            child: Stack(
              children: [
                // Animated water fill - FILLS FROM BOTTOM TO TOP
                AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        height: 320 * _progress,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.primaryLight,
                              AppColors.primary,
                              AppColors.primaryDark,
                            ],
                            stops: const [0.0, 0.6, 1.0],
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Shine effect
                            Positioned(
                              top: 10,
                              right: 20,
                              child: Container(
                                width: 30,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withValues(alpha: 0.3),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            
                            
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                // Floating bubbles - now positioned relative to water level
                ...List.generate(8, (index) {
                  final randomX = Random().nextDouble() * 180;
                  final waterHeight = 320 * _progress;
                  final bubbleY = 20 + (index * 20).toDouble();
                  
                  // Only show bubbles if they're within the water
                  if (bubbleY > 320 - waterHeight) {
                    return Positioned(
                      left: randomX,
                      bottom: bubbleY,
                      child: AnimatedBuilder(
                        animation: _waveController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, -_waveController.value * 10),
                            child: Container(
                              width: 3 + (index % 3).toDouble(),
                              height: 3 + (index % 3).toDouble(),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),

                // Center percentage - shows always
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(_progress * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 8,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_currentGlasses of $_targetGlasses',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  Widget _buildPremiumStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Today',
            '$_currentGlasses/$_targetGlasses',
            Icons.water_drop,
            AppColors.primaryLight,
          ),
          _buildStatItem(
            'Weekly',
            '${_calculateWeeklyAverage()}',
            Icons.show_chart,
            Colors.green,
          ),
          _buildStatItem(
            'Streak',
            '${_calculateStreak()}d',
            Icons.local_fire_department,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAddButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickAddButton(
            'Small',
            '250ml',
            Icons.water_drop,
            _addWater,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickAddButton(
            'Large',
            '500ml',
            Icons.local_drink,
            _addLargeWater,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAddButton(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyGlasses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Progress',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_targetGlasses, (index) {
            final isFilled = index < _currentGlasses;
            return GestureDetector(
              onTap: _addWater,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.elasticOut,
                width: 35,
                height: 50,
                decoration: BoxDecoration(
                  gradient: isFilled
                      ? LinearGradient(
                          colors: [
                            AppColors.primaryLight,
                            AppColors.primary,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : null,
                  color: isFilled ? null : Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: isFilled
                    ? const Icon(Icons.water_drop, color: Colors.white, size: 20)
                    : Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDayNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _previousDay,
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chevron_left, color: Colors.white, size: 20),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white70, size: 14),
              const SizedBox(width: 6),
              Text(
                'Day ${_currentDay + 1}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _nextDay,
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chevron_right, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 120,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              final dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
              final height = (_dailyIntake[index] / 8) * 80;
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      height: height,
                      width: 16,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryLight,
                            AppColors.primary,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dayNames[index],
                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementBadges() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Achievements',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildAchievementBadge(
                '7-Day Streak',
                _calculateStreak() >= 7,
                Icons.local_fire_department,
                Colors.orange,
              ),
              _buildAchievementBadge(
                'Perfect Week',
                _dailyIntake.every((d) => d == 8),
                Icons.emoji_events,
                Colors.amber,
              ),
              _buildAchievementBadge(
                'Hydration Master',
                _calculateWeeklyAverage() >= 7,
                Icons.water_drop,
                AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementBadge(String title, bool achieved, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: achieved ? color.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: achieved ? color : Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: achieved ? color : Colors.grey, size: 14),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              color: achieved ? Colors.white : Colors.grey,
              fontSize: 12,
              fontWeight: achieved ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Reminders',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          Switch(
            value: _isReminderEnabled,
            onChanged: (value) {
              setState(() {
                _isReminderEnabled = value;
              });
            },
            activeColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            thumbIcon: WidgetStateProperty.all(
              const Icon(Icons.check, size: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final Color color;
  final double waveOffset;

  _WavePainter({required this.color, required this.waveOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Start from left edge
    path.moveTo(0, 0);
    
    // Create waves across the full width
    for (double x = 0; x <= size.width; x += 15) {
      path.lineTo(
        x,
        15 + // height of wave
        (8) * sin((x / 50 + waveOffset) * 2 * pi), // wave amplitude
      );
    }
    
    // Complete the path to fill the area
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}