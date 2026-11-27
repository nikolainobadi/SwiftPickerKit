/// A plain header line under the selected item, tagged with what it shows so the header can
/// style it from the theme.
struct PickerDetailLine: Equatable {
    enum Kind: Equatable {
        /// `TreeNodeMetadata.subtitle`.
        case subtitle

        /// One of `TreeNodeMetadata.detailLines`.
        case metadataDetail

        /// The message shown after entering an empty folder.
        case emptyFolderMessage
    }

    let text: String
    let kind: Kind
}
