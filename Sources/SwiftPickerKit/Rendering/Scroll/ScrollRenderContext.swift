struct ScrollRenderContext {
    let startIndex: Int

    /// Exclusive.
    let endIndex: Int

    /// Terminal row where list content begins.
    let listStartRow: Int

    let visibleRowCount: Int
}
