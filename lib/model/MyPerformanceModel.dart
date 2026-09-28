// نموذج تقييم الموظف الذاتي - GET /kpi/my/performance

double _toDouble(dynamic v) => v == null ? 0.0 : (v as num).toDouble();

class MyPerformanceModel {
  final bool enabled;
  final String? message;
  final int year;
  final int month;
  final String? templateName;
  final PerformanceSummary? summary;
  final List<CriterionAverage> criteria;
  final List<DailyEvaluation> days;
  final List<TrendPoint> trend;

  /// عتبات التقييم (excellent / good / average) كما في إعدادات النظام
  final Map<String, double> thresholds;

  MyPerformanceModel({
    required this.enabled,
    this.message,
    required this.year,
    required this.month,
    this.templateName,
    this.summary,
    required this.criteria,
    required this.days,
    required this.trend,
    required this.thresholds,
  });

  factory MyPerformanceModel.fromJson(Map<String, dynamic> json) {
    final t = json['thresholds'] ?? {};
    return MyPerformanceModel(
      thresholds: {
        'excellent': t['excellent'] != null ? _toDouble(t['excellent']) : 95,
        'good': t['good'] != null ? _toDouble(t['good']) : 80,
        'average': t['average'] != null ? _toDouble(t['average']) : 60,
      },
      enabled: json['enabled'] ?? false,
      message: json['message'],
      year: json['year'] ?? DateTime.now().year,
      month: json['month'] ?? DateTime.now().month,
      templateName: json['template_name'],
      summary: json['summary'] != null
          ? PerformanceSummary.fromJson(json['summary'])
          : null,
      criteria: ((json['criteria'] ?? []) as List)
          .map((e) => CriterionAverage.fromJson(e))
          .toList(),
      days: ((json['days'] ?? []) as List)
          .map((e) => DailyEvaluation.fromJson(e))
          .toList(),
      trend: ((json['trend'] ?? []) as List)
          .map((e) => TrendPoint.fromJson(e))
          .toList(),
    );
  }
}

class PerformanceSummary {
  final double monthlyPercentage;
  final String? performanceGrade;
  final int evaluatedDays;
  final int totalAttendedDays;
  final double totalScore;
  final double maxPossibleScore;
  final String? managerComment;
  final bool isFinalized;

  PerformanceSummary({
    required this.monthlyPercentage,
    this.performanceGrade,
    required this.evaluatedDays,
    required this.totalAttendedDays,
    required this.totalScore,
    required this.maxPossibleScore,
    this.managerComment,
    required this.isFinalized,
  });

  factory PerformanceSummary.fromJson(Map<String, dynamic> json) {
    return PerformanceSummary(
      monthlyPercentage: _toDouble(json['monthly_percentage']),
      performanceGrade: json['performance_grade'],
      evaluatedDays: json['evaluated_days'] ?? 0,
      totalAttendedDays: json['total_attended_days'] ?? 0,
      totalScore: _toDouble(json['total_score']),
      maxPossibleScore: _toDouble(json['max_possible_score']),
      managerComment: json['manager_comment'],
      isFinalized: json['is_finalized'] ?? false,
    );
  }
}

class CriterionAverage {
  final String name;
  final double avgPercentage;
  final int daysEvaluated;

  CriterionAverage({
    required this.name,
    required this.avgPercentage,
    required this.daysEvaluated,
  });

  factory CriterionAverage.fromJson(Map<String, dynamic> json) {
    return CriterionAverage(
      name: json['name'] ?? '',
      avgPercentage: _toDouble(json['avg_percentage']),
      daysEvaluated: json['days_evaluated'] ?? 0,
    );
  }
}

class DailyEvaluation {
  final String date;
  final double totalScore;
  final double maxPossibleScore;
  final double dailyPercentage;
  final String? notes;
  final List<CriterionScore> scores;

  DailyEvaluation({
    required this.date,
    required this.totalScore,
    required this.maxPossibleScore,
    required this.dailyPercentage,
    this.notes,
    required this.scores,
  });

  factory DailyEvaluation.fromJson(Map<String, dynamic> json) {
    return DailyEvaluation(
      date: json['date'] ?? '',
      totalScore: _toDouble(json['total_score']),
      maxPossibleScore: _toDouble(json['max_possible_score']),
      dailyPercentage: _toDouble(json['daily_percentage']),
      notes: json['notes'],
      scores: ((json['scores'] ?? []) as List)
          .map((e) => CriterionScore.fromJson(e))
          .toList(),
    );
  }
}

class CriterionScore {
  final String criterionName;
  final double score;
  final double maxScore;
  final String? notes;

  CriterionScore({
    required this.criterionName,
    required this.score,
    required this.maxScore,
    this.notes,
  });

  factory CriterionScore.fromJson(Map<String, dynamic> json) {
    return CriterionScore(
      criterionName: json['criterion_name'] ?? '',
      score: _toDouble(json['score']),
      maxScore: _toDouble(json['max_score']),
      notes: json['notes'],
    );
  }
}

class TrendPoint {
  final int year;
  final int month;
  final double percentage;
  final String? grade;

  TrendPoint({
    required this.year,
    required this.month,
    required this.percentage,
    this.grade,
  });

  factory TrendPoint.fromJson(Map<String, dynamic> json) {
    return TrendPoint(
      year: json['year'] ?? 0,
      month: json['month'] ?? 0,
      percentage: _toDouble(json['percentage']),
      grade: json['grade'],
    );
  }
}
