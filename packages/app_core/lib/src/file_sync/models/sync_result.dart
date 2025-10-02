/// Result of a file sync operation
class SyncResult {
  /// Creates a [SyncResult] instance.
  SyncResult({
    required this.totalFiles,
    required this.syncedFiles,
    required this.failedFiles,
    required this.errors,
  });

  /// Total number of files processed
  int totalFiles;

  /// Number of successfully synced files
  int syncedFiles;

  /// Number of files that failed to sync
  int failedFiles;

  /// List of error messages for failed files
  List<String> errors;

  /// Whether the sync was successful (no failures)
  bool get isSuccess => failedFiles == 0;

  /// Success percentage
  double get successRate {
    if (totalFiles == 0) return 0;
    return (syncedFiles / totalFiles) * 100;
  }

  @override
  String toString() {
    return 'SyncResult(total: $totalFiles, synced: $syncedFiles, '
        'failed: $failedFiles, success rate: ${successRate.toStringAsFixed(1)}%)';
  }
}