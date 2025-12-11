# Changelog

All notable changes to SwiftPickerKit will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.9.0] - 2025-12-11

### Added
- Directory browsing API (`browseDirectories`) with configurable file/folder selection via `FileSystemNode.SelectionType`
- Inline documentation for core tree navigation types and protocols

### Changed
- Removed `newScreen` parameter from `treeNavigation` methods (alternate screen buffer now always used)
- `MockSwiftPicker` is now `open` instead of `final` to allow subclassing in testing scenarios

## [0.8.1] - 2025-12-09

### Added
- Scroll support for second column in two-column tree navigation layouts

### Fixed
- Scrolling issue where long lists in tree navigation weren't being displayed properly

## [0.8.0] - 2025-12-08

### Added
- Child selection support in `MockSwiftPicker` for testing tree navigation with nested items
- `selectedChildIndex` parameter to `MockTreeSelectionOutcome` for granular test control
- New `.child(parentIndex:childIndex:)` factory method for configuring nested tree selections in tests

## [0.7.0] - 2025-12-04

### Added
- Dual-column tree navigation with parent item display when navigating into folders
- Additional convenience methods for `CommandLineSelection` protocol
- Comprehensive inline documentation for core types and protocols
- `showPromptText` parameter to tree navigation for controlling prompt visibility

### Changed
- **BREAKING**: Tree navigation now requires `TreeNavigationRoot<Item>` wrapper instead of `[Item]` array
- **BREAKING**: Removed `allowSelectingFolders` parameter from tree navigation API (use `TreeNodePickerItem.isSelectable` instead)
- **BREAKING**: Removed `startInsideFirstRoot` parameter from tree navigation API (root-start logic now handled internally)
- **BREAKING**: `showSelectedItemText` moved from default parameter to required protocol parameter
- Improved tree navigation rendering for left/right arrow indicators
- Enhanced empty folder identification to display metadata correctly

### Fixed
- Tree navigation bug when navigating parent node items
- Column navigation issues in two-column layouts
- Right arrow navigation incorrectly enabled for empty tree items
- Left/right arrow rendering in tree navigation headers

## [0.6.0] - 2025-11-20

### Added
- `showSelectedItemText` parameter to `CommandLineSelection` methods to control whether selected item text is displayed in the header

### Changed
- Moved required protocol methods to convenience extensions for `CommandLineInput`, `CommandLinePermission`, `CommandLineSelection`, and `CommandLineTreeNavigation` for cleaner protocol definitions

### Fixed
- Empty folder identification during tree navigation now correctly displays metadata