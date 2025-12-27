import 'dart:io';

import 'package:yaml/yaml.dart';

/// Checks that all package versions match the unified version in root
/// pubspec.yaml.
///
/// This includes:
/// - Each package's own version
/// - Dependencies on other ecosystem packages (packages in packages/)
///
/// Exit codes:
///   0 - All versions match
///   1 - Version mismatch found or error occurred
void main() {
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
///
/// Returns true if valid, false if there's a mismatch.
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
