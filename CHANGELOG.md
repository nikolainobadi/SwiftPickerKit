# Changelog

All notable changes to SwiftPickerKit will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.6.0] - 2025-11-20

### Added
- `showSelectedItemText` parameter to `CommandLineSelection` methods to control whether selected item text is displayed in the header

### Changed
- Moved required protocol methods to convenience extensions for `CommandLineInput`, `CommandLinePermission`, `CommandLineSelection`, and `CommandLineTreeNavigation` for cleaner protocol definitions

### Fixed
- Empty folder identification during tree navigation now correctly displays metadata