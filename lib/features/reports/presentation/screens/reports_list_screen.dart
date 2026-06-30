import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cyclerisk/core/l10n/localize_api_error.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:cyclerisk/core/providers/auth_provider.dart';
import 'package:cyclerisk/core/services/api_exception.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/features/reports/data/models/obstacle_report.dart';
import 'package:cyclerisk/features/reports/data/services/reports_api_service.dart';
import 'package:cyclerisk/features/reports/presentation/utils/obstacle_category_label.dart';

class ReportsListScreen extends StatefulWidget {
  const ReportsListScreen({super.key});

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
  final ReportsApiService _reportsApiService = ReportsApiService();
  List<ObstacleReport> _reports = const [];
  bool _loading = true;
  String? _errorMessage;
  bool _loadInFlight = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (_loadInFlight) {
      return;
    }
    _loadInFlight = true;

    final l10n = appL10n(context);
    final auth = context.read<AuthProvider>();
    await auth.ensureInitialized();
    if (!mounted) {
      _loadInFlight = false;
      return;
    }

    final token = auth.accessToken;
    if (token == null || token.isEmpty) {
      setState(() {
        _loading = false;
        _errorMessage = l10n.pleaseSignInAgain;
      });
      _loadInFlight = false;
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final reports = await _reportsApiService.getReports(accessToken: token);
      if (!mounted) return;
      setState(() => _reports = reports);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = localizeApiError(l10n, e));
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = l10n.couldNotLoadReports);
    } finally {
      _loadInFlight = false;
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = appL10n(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.obstacleReports),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : _reports.isEmpty
          ? Center(child: Text(l10n.noReportsYet))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _reports.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final report = _reports[index];
                  return Card(
                    child: ListTile(
                      title: Text(
                        ObstacleCategoryLabel.category(l10n, report.category),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        [
                          report.description,
                          ObstacleCategoryLabel.severity(l10n, report.severity),
                          report.status ?? '',
                          '${report.lat.toStringAsFixed(4)}, ${report.lng.toStringAsFixed(4)}',
                        ].where((part) => part.isNotEmpty).join(' · '),
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
    );
  }
}
