import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/chart_models.dart';

/// Widget for selecting different chart types with smooth animations
class ChartTypeSelector extends StatelessWidget {
  final ChartType selectedType;
  final Function(ChartType) onTypeChanged;
  final bool enabled;

  const ChartTypeSelector({
    Key? key,
    required this.selectedType,
    required this.onTypeChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getChartTypesLabel(localizations),
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ChartType.values.map((type) {
                final isSelected = selectedType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildChartTypeChip(
                    context,
                    type,
                    isSelected,
                    localizations,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartTypeChip(
    BuildContext context,
    ChartType type,
    bool isSelected,
    AppLocalizations localizations,
  ) {
    final theme = Theme.of(context);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: FilterChip(
        selected: isSelected,
        onSelected: enabled ? (selected) {
          if (selected) onTypeChanged(type);
        } : null,
        avatar: AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: Icon(
            _getIconForType(type),
            key: ValueKey('${type}_${isSelected}'),
            size: 18,
            color: isSelected 
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.primary,
          ),
        ),
        label: Text(
          _getLabelForType(type, localizations),
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        selectedColor: theme.colorScheme.primary,
        side: BorderSide(
          color: isSelected 
              ? theme.colorScheme.primary 
              : theme.colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
        elevation: isSelected ? 2 : 0,
        shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  IconData _getIconForType(ChartType type) {
    switch (type) {
      case ChartType.line:
        return Icons.timeline;
      case ChartType.bar:
        return Icons.bar_chart;
      case ChartType.pie:
        return Icons.pie_chart;
      case ChartType.heatmap:
        return Icons.calendar_view_month;
    }
  }

  String _getLabelForType(ChartType type, AppLocalizations localizations) {
    switch (type) {
      case ChartType.line:
        return 'Line';  // TODO: Add to localization
      case ChartType.bar:
        return 'Bar';   // TODO: Add to localization
      case ChartType.pie:
        return 'Pie';   // TODO: Add to localization
      case ChartType.heatmap:
        return 'Heat';  // TODO: Add to localization
    }
  }

  String _getChartTypesLabel(AppLocalizations localizations) {
    return 'Chart Type'; // TODO: Add to localization
  }
}

/// Widget for selecting time periods
class TimePeriodSelector extends StatelessWidget {
  final TimePeriod selectedPeriod;
  final Function(TimePeriod) onPeriodChanged;
  final bool enabled;

  const TimePeriodSelector({
    Key? key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SegmentedButton<TimePeriod>(
        segments: _buildSegments(localizations),
        selected: {selectedPeriod},
        onSelectionChanged: enabled ? (Set<TimePeriod> newSelection) {
          onPeriodChanged(newSelection.first);
        } : null,
        style: SegmentedButton.styleFrom(
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          selectedForegroundColor: theme.colorScheme.onPrimary,
          selectedBackgroundColor: theme.colorScheme.primary,
          side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  List<ButtonSegment<TimePeriod>> _buildSegments(AppLocalizations localizations) {
    return [
      ButtonSegment<TimePeriod>(
        value: TimePeriod.week,
        label: Text(_getLabelForPeriod(TimePeriod.week, localizations)),
        tooltip: 'Last 7 days',
      ),
      ButtonSegment<TimePeriod>(
        value: TimePeriod.month,
        label: Text(_getLabelForPeriod(TimePeriod.month, localizations)),
        tooltip: 'Last month',
      ),
      ButtonSegment<TimePeriod>(
        value: TimePeriod.quarter,
        label: Text(_getLabelForPeriod(TimePeriod.quarter, localizations)),
        tooltip: 'Last 3 months',
      ),
      ButtonSegment<TimePeriod>(
        value: TimePeriod.year,
        label: Text(_getLabelForPeriod(TimePeriod.year, localizations)),
        tooltip: 'Last year',
      ),
    ];
  }

  String _getLabelForPeriod(TimePeriod period, AppLocalizations localizations) {
    switch (period) {
      case TimePeriod.week:
        return 'Week';     // TODO: Add to localization
      case TimePeriod.month:
        return 'Month';    // TODO: Add to localization
      case TimePeriod.quarter:
        return 'Quarter';  // TODO: Add to localization
      case TimePeriod.year:
        return 'Year';     // TODO: Add to localization
      case TimePeriod.last30Days:
        return '30 Days';  // TODO: Add to localization
      case TimePeriod.last90Days:
        return '90 Days';  // TODO: Add to localization
    }
  }
}

/// Combined selector widget for both chart type and time period
class ChartControlPanel extends StatelessWidget {
  final ChartType selectedChartType;
  final TimePeriod selectedTimePeriod;
  final Function(ChartType) onChartTypeChanged;
  final Function(TimePeriod) onTimePeriodChanged;
  final bool enabled;

  const ChartControlPanel({
    Key? key,
    required this.selectedChartType,
    required this.selectedTimePeriod,
    required this.onChartTypeChanged,
    required this.onTimePeriodChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Column(
        children: [
          TimePeriodSelector(
            selectedPeriod: selectedTimePeriod,
            onPeriodChanged: onTimePeriodChanged,
            enabled: enabled,
          ),
          const Divider(height: 1),
          ChartTypeSelector(
            selectedType: selectedChartType,
            onTypeChanged: onChartTypeChanged,
            enabled: enabled,
          ),
        ],
      ),
    );
  }
}