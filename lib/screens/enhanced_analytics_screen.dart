import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../services/enhanced_mood_storage.dart';
import '../features/analytics/models/chart_models.dart';
import '../features/analytics/controllers/chart_controller.dart';
import '../features/analytics/widgets/chart_selectors.dart';
import '../features/analytics/widgets/mood_bar_chart.dart';
import '../features/analytics/widgets/mood_pie_chart.dart';
import '../features/analytics/widgets/mood_line_chart.dart';
import '../features/analytics/widgets/mood_heatmap_chart.dart';

class EnhancedAnalyticsScreen extends StatefulWidget {
  const EnhancedAnalyticsScreen({super.key});

  @override
  State<EnhancedAnalyticsScreen> createState() => _EnhancedAnalyticsScreenState();
}

class _EnhancedAnalyticsScreenState extends State<EnhancedAnalyticsScreen>
    with TickerProviderStateMixin {
  final EnhancedMoodStorage _storage = EnhancedMoodStorage();
  late ChartController _chartController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _chartController = ChartController(_storage);
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      await _chartController.loadData();
      // Debug: print data info
      print('Chart Controller - All entries: ${_chartController.filteredEntries.length}');
      print('Chart Controller - Has data: ${_chartController.hasData}');
      print('Chart Controller - Error: ${_chartController.error}');
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chartTheme = ChartTheme.fromTheme(theme);

    return ChangeNotifierProvider.value(
      value: _chartController,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.statistics),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(Icons.analytics),
                text: 'Charts',
              ),
              Tab(
                icon: Icon(Icons.calendar_view_month),
                text: 'Calendar',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildChartsTab(chartTheme),
            _buildCalendarTab(chartTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsTab(ChartTheme chartTheme) {
    return SafeArea(
      child: Consumer<ChartController>(
        builder: (context, controller, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Chart controls
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ChartControlPanel(
                    selectedChartType: controller.chartType,
                    selectedTimePeriod: controller.timePeriod,
                    onChartTypeChanged: controller.updateChartType,
                    onTimePeriodChanged: controller.updateTimePeriod,
                  ),
                ),
                
                // Statistics summary
                if (controller.statistics != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: _buildStatisticsCard(controller.statistics!, chartTheme),
                  ),
                
                // Main chart area
                Container(
                  height: 400, // Fixed height for chart area
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: chartTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(chartTheme.borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _buildChart(controller, chartTheme),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendarTab(ChartTheme chartTheme) {
    return SafeArea(
      child: Consumer<ChartController>(
        builder: (context, controller, child) {
          final chartData = controller.getChartData();
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: MoodHeatmapChart(
                data: chartData,
                chartTheme: chartTheme,
                onDayTap: (date, mood) => _showDayDetails(context, date, mood),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatisticsCard(MoodStatistics stats, ChartTheme chartTheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: chartTheme.backgroundColor,
        borderRadius: BorderRadius.circular(chartTheme.borderRadius),
        border: Border.all(
          color: chartTheme.colors.first.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Average Mood',
                  stats.average.toStringAsFixed(1),
                  Icons.mood,
                  chartTheme.colors.first,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Total Entries',
                  stats.totalEntries.toString(),
                  Icons.event_note,
                  chartTheme.colors[1 % chartTheme.colors.length],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Current Streak',
                  '${stats.streakDays} days',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Trend',
                  stats.trend > 0 ? '↗ Rising' : stats.trend < 0 ? '↘ Falling' : '→ Stable',
                  stats.trend > 0 ? Icons.trending_up : stats.trend < 0 ? Icons.trending_down : Icons.trending_flat,
                  stats.trend > 0 ? Colors.green : stats.trend < 0 ? Colors.red : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildChart(ChartController controller, ChartTheme chartTheme) {
    final chartData = controller.getChartData();
    
    if (chartData.isEmpty) {
      return _buildEmptyState();
    }

    switch (controller.chartType) {
      case ChartType.bar:
        return MoodBarChart(
          data: chartData,
          chartTheme: chartTheme,
        );
      
      case ChartType.pie:
        final emotionData = controller.getEmotionBreakdown();
        return MoodPieChart(
          emotionData: emotionData,
          chartTheme: chartTheme,
          onEmotionTap: (emotion) => _showEmotionDetails(context, emotion, controller),
        );
      
      case ChartType.line:
        return MoodLineChart(
          data: chartData,
          chartTheme: chartTheme,
        );
      
      case ChartType.heatmap:
        return MoodHeatmapChart(
          data: chartData,
          chartTheme: chartTheme,
          onDayTap: (date, mood) => _showDayDetails(context, date, mood),
        );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No mood data available',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start logging your moods to see analytics\nGo to the Home tab to record your first mood!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              // Navigate back - user can go to home tab manually
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.mood),
            label: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  void _showDayDetails(BuildContext context, DateTime date, double? mood) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mood for ${date.day}/${date.month}/${date.year}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (mood != null) ...[
              Text('Mood Rating: ${mood.toStringAsFixed(1)}/10'),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: mood / 10,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  mood > 7 ? Colors.green : mood > 4 ? Colors.orange : Colors.red,
                ),
              ),
            ] else
              const Text('No mood recorded for this day'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEmotionDetails(BuildContext context, String emotion, ChartController controller) {
    final emotionData = controller.getEmotionBreakdown();
    final count = emotionData[emotion] ?? 0;
    final total = emotionData.values.fold(0, (sum, c) => sum + c);
    final percentage = total > 0 ? (count / total) * 100 : 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$emotion Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Occurrences: $count'),
            const SizedBox(height: 8),
            Text('Percentage: ${percentage.toStringAsFixed(1)}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}