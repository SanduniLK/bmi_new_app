import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/bmi_record.dart';
import '../utils/constants.dart';
import '../widgets/bmi_gauge.dart';

class BMIHistoryScreen extends StatefulWidget {
  const BMIHistoryScreen({super.key});

  @override
  State<BMIHistoryScreen> createState() => _BMIHistoryScreenState();
}

class _BMIHistoryScreenState extends State<BMIHistoryScreen> {
  late FirestoreService _firestoreService;
  String _selectedTimeRange = 'Month';

  @override
  void initState() {
    super.initState();
    _firestoreService = Provider.of<FirestoreService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('BMI History')
            .animate()
            .fadeIn(duration: 500.ms)
            .slideX(begin: -0.2, end: 0),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list, color: AppColors.primary),
            onSelected: (value) {
              setState(() {
                _selectedTimeRange = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Week',
                child: Text('Last Week'),
              ),
              const PopupMenuItem(
                value: 'Month',
                child: Text('Last Month'),
              ),
              const PopupMenuItem(
                value: 'Year',
                child: Text('Last Year'),
              ),
              const PopupMenuItem(
                value: 'All',
                child: Text('All Time'),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<BMIRecord>>(
        stream: _firestoreService.getBMIHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading history',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          final records = snapshot.data ?? [];
          
          if (records.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      Icons.history,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No BMI Records Yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Calculate your BMI to see history',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/bmi-calculator');
                    },
                    icon: const Icon(Icons.calculate),
                    label: const Text('Calculate BMI'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStatsCard(records),
                const SizedBox(height: 24),
                _buildBMIGauge(records.last),
                const SizedBox(height: 24),
                _buildChart(records),
                const SizedBox(height: 24),
                _buildHistoryList(records),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCard(List<BMIRecord> records) {
    double latestBMI = records.last.bmi;
    double firstBMI = records.first.bmi;
    double change = latestBMI - firstBMI;
    double average = records.map((r) => r.bmi).reduce((a, b) => a + b) / records.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Current',
                latestBMI.toStringAsFixed(1),
                Icons.trending_up,
              ),
              _buildStatItem(
                'Average',
                average.toStringAsFixed(1),
                Icons.analytics,
              ),
              _buildStatItem(
                'Change',
                '${change.toStringAsFixed(1)}${change > 0 ? '↑' : '↓'}',
                change > 0 ? Icons.arrow_upward : Icons.arrow_downward,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildBMIGauge(BMIRecord latest) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      _getBMIColor(latest.bmi).withValues(alpha: 0.2),
                      _getBMIColor(latest.bmi).withValues(alpha: 0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getBMIIcon(latest.bmi),
                  color: _getBMIColor(latest.bmi),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your BMI',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${latest.bmi.toStringAsFixed(1)} kg/m²',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      latest.category,
                      style: TextStyle(
                        color: _getBMIColor(latest.bmi),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BMIGauge(bmi: latest.bmi),
        ],
      ),
    );
  }

  Widget _buildChart(List<BMIRecord> records) {
    // Filter records based on selected time range
    var filteredRecords = _filterRecordsByTimeRange(records);
    
    if (filteredRecords.isEmpty) return const SizedBox();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade200,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
                reservedSize: 30,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < filteredRecords.length) {
                    return Text(
                      DateFormat('MM/dd').format(filteredRecords[index].date),
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 30,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: filteredRecords.asMap().entries.map((entry) {
                return FlSpot(
                  entry.key.toDouble(),
                  entry.value.bmi,
                );
              }).toList(),
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: _getBMIColor(spot.y),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
          minY: _getMinBMI(filteredRecords) - 1,
          maxY: _getMaxBMI(filteredRecords) + 1,
        ),
      ),
    );
  }

  Widget _buildHistoryList(List<BMIRecord> records) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length > 10 ? 10 : records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        final color = _getBMIColor(record.bmi);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.2),
                    color.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  record.bmi.toStringAsFixed(1),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            title: Text(
              record.category,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${record.weight} kg • ${record.height} cm',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                DateFormat('MMM dd').format(record.date),
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return const Color(0xFF42A5F5); // Blue
    if (bmi < 25) return const Color(0xFF66BB6A); // Green
    if (bmi < 30) return const Color(0xFFFFA726); // Orange
    return const Color(0xFFEF5350); // Red
  }

  IconData _getBMIIcon(double bmi) {
    if (bmi < 18.5) return Icons.sentiment_dissatisfied;
    if (bmi < 25) return Icons.sentiment_satisfied;
    if (bmi < 30) return Icons.sentiment_neutral;
    return Icons.sentiment_very_dissatisfied;
  }

  List<BMIRecord> _filterRecordsByTimeRange(List<BMIRecord> records) {
    DateTime now = DateTime.now();
    DateTime cutoff;
    
    switch (_selectedTimeRange) {
      case 'Week':
        cutoff = now.subtract(const Duration(days: 7));
        break;
      case 'Month':
        cutoff = now.subtract(const Duration(days: 30));
        break;
      case 'Year':
        cutoff = now.subtract(const Duration(days: 365));
        break;
      default:
        return records;
    }
    
    return records.where((record) => record.date.isAfter(cutoff)).toList();
  }

  double _getMinBMI(List<BMIRecord> records) {
    return records.map((r) => r.bmi).reduce((a, b) => a < b ? a : b);
  }

  double _getMaxBMI(List<BMIRecord> records) {
    return records.map((r) => r.bmi).reduce((a, b) => a > b ? a : b);
  }
}