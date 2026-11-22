public enum PickerDividerStyle {
    case single     // ────────────
    case double     // ════════════
    case dashed     // - - - - - - -
    case none       // (no line)
    case custom(String)   // any custom string

    func makeLine(width: Int) -> String {
        switch self {
        case .single:
            return String(repeating: "─", count: width)
        case .double:
            return String(repeating: "=", count: width)
        case .dashed:
            return Array(repeating: "- ", count: max(1, width / 2)).joined()
        case .none:
            return ""
        case .custom(let token):
            guard !token.isEmpty else {
                return ""
            }
            
            return Array(repeating: token, count: max(1, width / token.count)).joined()
        }
    }
}
