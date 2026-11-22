struct ScrollLayout {
    let rows: Int
    let headerHeight: Int
    let footerHeight: Int
    
    var availableListRows: Int {
        return rows - headerHeight - footerHeight
    }
}
