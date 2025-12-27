// ignore_for_file: unintended_html_in_doc_comment, document_ignores

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:yaml/yaml.dart';

/// Dars workspace management tool.
///
/// Usage:
///   dart run tool/dars_tool.dart <command>
///
/// Commands:
///   check-versions       Check version consistency across packages
///   generate-changelog   Generate consolidated CHANGELOG.md
void main(List<String> arguments) async {
  final runner = CommandRunner<void>(
    'dars_tool',
    'Dars workspace management tool.',
  )
    ..addCommand(CheckVersionsCommand())
    ..addCommand(GenerateChangelogCommand());

  try {
    await runner.run(arguments);
  } on UsageException catch (e) {
    stderr.writeln(e);
    exit(64);
  }
}

// =============================================================================
// Check Versions Command
// =============================================================================

/// Checks that all package versions match the unified version in root
/// pubspec.yaml.
class CheckVersionsCommand extends Command<void> {
  @override
  String get name => 'check-versions';

  @override
  String get description => 'Check that all package versions match the unified version.';

  @override
  void run() {
    final rootPubspec = File('pubspec.yaml');
    if (!rootPubspec.existsSync()) {
      stderr.writeln('❌ Error: Root pubspec.yaml not found.');
      stderr.writeln('   Please run this script from the repository root.');
      exit(1);
    }

    final rootContent = loadYaml(rootPubspec.readAsStringSync()) as YamlMap;
    final unifiedVersion = rootContent['version'] as String?;

    if (unifiedVersion == null) {
      stderr.writeln('❌ Error: No version field found in root pubspec.yaml.');
      exit(1);
    }

    stdout.writeln('📋 Unified version: $unifiedVersion');
    stdout.writeln();

    final packagesDir = Directory('packages');
    if (!packagesDir.existsSync()) {
      stderr.writeln('❌ Error: packages directory not found.');
      exit(1);
    }

    // Collect all ecosystem package names
    final ecosystemPackages = <String>{};
    final packageDirs = packagesDir.listSync().whereType<Directory>().toList();

    for (final packageDir in packageDirs) {
      final pubspecFile = File('${packageDir.path}/pubspec.yaml');
      if (!pubspecFile.existsSync()) continue;

      final content = loadYaml(pubspecFile.readAsStringSync()) as YamlMap;
      final name = content['name'] as String?;
      if (name != null) {
        ecosystemPackages.add(name);
      }
    }

    var hasError = false;

    stdout.writeln('📦 Package versions:');
    for (final packageDir in packageDirs) {
      final pubspecFile = File('${packageDir.path}/pubspec.yaml');
      if (!pubspecFile.existsSync()) continue;

      final packageContent = loadYaml(pubspecFile.readAsStringSync()) as YamlMap;
      final packageName = packageContent['name'] as String?;
      final packageVersion = packageContent['version'] as String?;

      if (packageName == null) {
        stderr.writeln('⚠️  Warning: No name field in ${pubspecFile.path}');
        continue;
      }

      if (packageVersion == null) {
        stderr.writeln('   ❌ $packageName: No version field found');
        hasError = true;
        continue;
      }

      if (packageVersion == unifiedVersion) {
        stdout.writeln('   ✅ $packageName: $packageVersion');
      } else {
        stderr.writeln(
          '   ❌ $packageName: $packageVersion (expected: $unifiedVersion)',
        );
        hasError = true;
      }
    }

    stdout.writeln();
    stdout.writeln('🔗 Ecosystem dependencies:');

    for (final packageDir in packageDirs) {
      final pubspecFile = File('${packageDir.path}/pubspec.yaml');
      if (!pubspecFile.existsSync()) continue;

      final packageContent = loadYaml(pubspecFile.readAsStringSync()) as YamlMap;
      final packageName = packageContent['name'] as String? ?? 'unknown';

      // Check dependencies
      final dependencies = packageContent['dependencies'] as YamlMap?;
      if (dependencies != null) {
        for (final dep in dependencies.keys) {
          if (ecosystemPackages.contains(dep)) {
            final depVersion = dependencies[dep];
            if (!_checkDependencyVersion(
              packageName,
              dep as String,
              depVersion,
              unifiedVersion,
            )) {
              hasError = true;
            }
          }
        }
      }

      // Check dev_dependencies
      final devDependencies = packageContent['dev_dependencies'] as YamlMap?;
      if (devDependencies != null) {
        for (final dep in devDependencies.keys) {
          if (ecosystemPackages.contains(dep)) {
            final depVersion = devDependencies[dep];
            if (!_checkDependencyVersion(
              packageName,
              dep as String,
              depVersion,
              unifiedVersion,
              isDev: true,
            )) {
              hasError = true;
            }
          }
        }
      }
    }

    stdout.writeln();
    if (hasError) {
      stderr.writeln(
        '❌ Version check failed. Please update package versions to match.',
      );
      exit(1);
    } else {
      stdout.writeln('✅ All package versions match the unified version.');
      exit(0);
    }
  }

  /// Checks if a dependency version matches the unified version.
  bool _checkDependencyVersion(
    String packageName,
    String dependencyName,
    Object? version,
    String unifiedVersion, {
    bool isDev = false,
  }) {
    final depType = isDev ? 'dev_dependencies' : 'dependencies';

    // Workspace resolution (null or empty) - require explicit version
    if (version == null) {
      stderr.writeln(
        '   ❌ $packageName ($depType) -> $dependencyName: '
        'no version specified (expected: $unifiedVersion)',
      );
      return false;
    }

    // Path or git dependencies - show info but don't fail
    if (version is YamlMap) {
      if (version.containsKey('path')) {
        stdout.writeln(
          '   ℹ️  $packageName -> $dependencyName: path dependency',
        );
        return true;
      }
      if (version.containsKey('git')) {
        stdout.writeln(
          '   ℹ️  $packageName -> $dependencyName: git dependency',
        );
        return true;
      }
    }

    // Version string
    if (version is String) {
      if (version == unifiedVersion) {
        stdout.writeln('   ✅ $packageName -> $dependencyName: $version');
        return true;
      } else {
        stderr.writeln(
          '   ❌ $packageName ($depType) -> $dependencyName: '
          '$version (expected: $unifiedVersion)',
        );
        return false;
      }
    }

    // Unknown format
    stderr.writeln(
      '   ⚠️  $packageName -> $dependencyName: unknown format ($version)',
    );
    return true;
  }
}

// =============================================================================
// Generate Changelog Command
// =============================================================================

/// Generates a consolidated CHANGELOG.md from package CHANGELOGs.
class GenerateChangelogCommand extends Command<void> {
  @override
  String get name => 'generate-changelog';

  @override
  String get description => 'Generate consolidated CHANGELOG.md from package CHANGELOGs.';

  @override
  void run() {
    final packagesDir = Directory('packages');
    if (!packagesDir.existsSync()) {
      stderr.writeln('❌ Error: packages directory not found.');
      stderr.writeln('   Please run this script from the repository root.');
      exit(1);
    }

    stdout.writeln('📖 Reading package CHANGELOGs...');
    stdout.writeln();

    // Map<version, Map<packageName, content>>
    final versionMap = <String, Map<String, String>>{};

    final packageDirs = packagesDir.listSync().whereType<Directory>().toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    for (final packageDir in packageDirs) {
      final changelogFile = File('${packageDir.path}/CHANGELOG.md');
      if (!changelogFile.existsSync()) {
        stdout.writeln('   ⏭️  ${packageDir.path}: No CHANGELOG.md found');
        continue;
      }

      final packageName = packageDir.path.split('/').last;
      stdout.writeln('   📦 $packageName');

      final content = changelogFile.readAsStringSync();
      final sections = _parseChangelog(content);

      for (final entry in sections.entries) {
        final version = entry.key;
        final sectionContent = entry.value;

        versionMap.putIfAbsent(version, () => {});
        versionMap[version]![packageName] = sectionContent;
      }
    }

    if (versionMap.isEmpty) {
      stderr.writeln('❌ Error: No changelog entries found.');
      exit(1);
    }

    stdout.writeln();
    stdout.writeln('📝 Generating consolidated CHANGELOG...');

    // Sort versions in descending order (newest first)
    final sortedVersions = versionMap.keys.toList()..sort((a, b) => _compareVersions(b, a));

    final buffer = StringBuffer();

    for (final version in sortedVersions) {
      buffer.writeln('## $version');
      buffer.writeln();

      final packages = versionMap[version]!;
      // Sort packages alphabetically
      final sortedPackages = packages.keys.toList()..sort();

      for (final packageName in sortedPackages) {
        buffer.writeln('### $packageName');
        buffer.writeln();
        // Increase header levels by 1 (e.g., ### -> ####)
        final content = _increaseHeaderLevels(packages[packageName]!.trim());
        buffer.writeln(content);
        buffer.writeln();
      }
    }

    final outputFile = File('CHANGELOG.md');
    // Remove trailing newline
    final output = buffer.toString().trimRight();
    outputFile.writeAsStringSync('$output\n');

    stdout.writeln('✅ Generated CHANGELOG.md with ${sortedVersions.length} '
        'version(s)');
    stdout.writeln();
    stdout.writeln('   Versions: ${sortedVersions.join(', ')}');
  }

  /// Increases markdown header levels by 1 (e.g., ### -> ####).
  String _increaseHeaderLevels(String content) {
    final lines = content.split('\n');
    final result = <String>[];

    for (final line in lines) {
      if (line.startsWith('#')) {
        result.add('#$line');
      } else {
        result.add(line);
      }
    }

    return result.join('\n');
  }

  /// Parses a CHANGELOG.md file and returns a map of version -> content.
  Map<String, String> _parseChangelog(String content) {
    final result = <String, String>{};
    final lines = content.split('\n');

    String? currentVersion;
    final currentContent = StringBuffer();

    for (final line in lines) {
      // Match version headers like "## 0.2.0" or "## 1.0.0"
      final versionMatch = RegExp(r'^## (\d+\.\d+\.\d+.*)$').firstMatch(line);

      if (versionMatch != null) {
        // Save previous section if exists
        if (currentVersion != null) {
          result[currentVersion] = currentContent.toString();
          currentContent.clear();
        }
        currentVersion = versionMatch.group(1);
      } else if (currentVersion != null) {
        currentContent.writeln(line);
      }
    }

    // Save last section
    if (currentVersion != null) {
      result[currentVersion] = currentContent.toString();
    }

    return result;
  }

  /// Compares two semantic versions.
  int _compareVersions(String a, String b) {
    // Remove any suffixes like -beta, -rc, etc. for basic comparison
    final aClean = a.split('-').first;
    final bClean = b.split('-').first;

    final aParts = aClean.split('.').map(int.tryParse).toList();
    final bParts = bClean.split('.').map(int.tryParse).toList();

    for (var i = 0; i < 3; i++) {
      final aPart = i < aParts.length ? (aParts[i] ?? 0) : 0;
      final bPart = i < bParts.length ? (bParts[i] ?? 0) : 0;

      if (aPart != bPart) {
        return aPart.compareTo(bPart);
      }
    }

    // If base versions are equal, compare suffixes
    // Versions without suffix are considered newer
    final aHasSuffix = a.contains('-');
    final bHasSuffix = b.contains('-');

    if (aHasSuffix && !bHasSuffix) return -1;
    if (!aHasSuffix && bHasSuffix) return 1;
    if (aHasSuffix && bHasSuffix) return a.compareTo(b);

    return 0;
  }
}
