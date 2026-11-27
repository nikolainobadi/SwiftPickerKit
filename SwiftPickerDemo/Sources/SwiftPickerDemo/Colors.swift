import ArgumentParser
import SwiftPickerKit

extension SwiftPickerDemo {
    /// Demonstrates per-item styles and custom themes.
    ///
    /// List items conform to `SegmentedPickerItem` to draw each row in several colors, tree nodes use
    /// `StyledPickerItem` through `TreeNode.displayStyle`, and `PickerTheme` recolors the picker's chrome. Run with `NO_COLOR=1` to see colors dropped while underline and dim remain.
    ///
    /// Usage:
    ///     swift run SwiftPickerDemo colors [--theme] [--tree]
    ///
    /// Examples:
    ///     swift run SwiftPickerDemo colors
    ///     swift run SwiftPickerDemo colors --theme
    ///     swift run SwiftPickerDemo colors --tree
    ///     NO_COLOR=1 swift run SwiftPickerDemo colors
    struct Colors: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "colors",
            abstract: "Test styled items and custom themes"
        )

        @Flag(name: [.customShort("t"), .long], help: "Use a custom magenta theme instead of the standard one")
        var theme = false

        @Flag(name: .long, help: "Show styled nodes in tree navigation")
        var tree = false

        func run() throws {
            let picker = SwiftPicker(interruptBehavior: .finishAsCancelled, assumeYes: false, permissionSubmitMode: .requireEnter, theme: theme ? Self.magentaTheme : .standard)

            if tree {
                runTreeDemo(picker: picker)
            } else {
                runListDemo(picker: picker)
            }
        }
    }
}

// MARK: - Private Methods
private extension SwiftPickerDemo.Colors {
    static let magentaTheme = PickerTheme(
        marker: .brightMagenta,
        inactiveText: .white,
        detailText: .brightBlack,
        divider: .magenta,
        activePointer: .brightMagenta,
        inactivePointer: .magenta,
        emptyHint: .yellow,
        columnHeader: .magenta,
        breadcrumb: .brightMagenta,
        selectedHeader: .brightMagenta,
        scrollArrow: .brightMagenta,
        placeholder: .brightBlack,
        subtitle: .brightBlack,
        metadataDetail: .brightBlack
    )

    func runListDemo(picker: SwiftPicker) {
        let jobs = [
            BuildJob(name: "build-macos", status: .passed, note: "12 of 12 cases"),
            BuildJob(name: "build-linux", status: .failed, note: "3 of 13 cases · not fixed"),
            BuildJob(name: "lint", status: .warning, note: "2 warnings"),
            BuildJob(name: "docs", status: .skipped, note: "no changes"),
            BuildJob(name: "release-notes", status: .pending, note: "not started")
        ]
        let layout: PickerLayout<BuildJob> = .singleColumn

        guard let job = picker.singleSelection(prompt: "Pick a CI job to inspect.", items: jobs, layout: layout, newScreen: true) else {
            print("\nNo selection made")
            return
        }

        print("\nYou selected: \(job.name) (\(job.status.rawValue))")
    }

    func runTreeDemo(picker: SwiftPicker) {
        let leaf: (String, PickerTextStyle?) -> TreeNode<String> = { name, style in
            TreeNode(name: name, value: name, hasChildren: false, isSelectable: true, metadata: nil, displayStyle: style, loadChildren: { [] })
        }
        let sources = TreeNode(name: "Sources", value: "Sources", hasChildren: true, isSelectable: false, metadata: TreeNodeMetadata(subtitle: "3 files", detailLines: [], icon: nil), displayStyle: .heading, loadChildren: {
            [leaf("App.swift", nil), leaf("Broken.swift", .failure), leaf("Legacy.swift", .muted)]
        })
        let root = TreeNavigationRoot(displayName: "Project", children: [sources, leaf("README.md", .success)])

        guard let node = picker.treeNavigation(prompt: "Browse styled nodes.", root: root, showPromptText: true, showSelectedItemText: true) else {
            print("\nNo selection made")
            return
        }

        print("\nYou selected: \(node.displayName)")
    }
}

// MARK: - Dependencies
private struct BuildJob: SegmentedPickerItem {
    enum Status: String {
        case passed, failed, warning, skipped, pending
    }

    let name: String
    let status: Status
    let note: String

    var displayName: String { displaySegments.map(\.text).joined() }

    var displaySegments: [PickerTextSegment] {
        return [
            PickerTextSegment(text: name.padding(toLength: 16, withPad: " ", startingAt: 0), style: nil),
            PickerTextSegment(text: status.rawValue.padding(toLength: 10, withPad: " ", startingAt: 0), style: statusStyle),
            PickerTextSegment(text: note, style: .muted)
        ]
    }

    private var statusStyle: PickerTextStyle? {
        switch status {
        case .passed:
            return .success
        case .failed:
            return .failure
        case .warning:
            return .warning
        case .skipped:
            return .muted
        case .pending:
            return nil
        }
    }
}
