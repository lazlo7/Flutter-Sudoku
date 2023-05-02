class FieldCoords {
  final int row;
  final int col;
  const FieldCoords(this.row, this.col);

  @override
  bool operator ==(Object other) {
    if (other is FieldCoords) {
      return row == other.row && col == other.col;
    }
    return false;
  }

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() {
    return 'FieldCoords{x: $row, y: $col}';
  }
}