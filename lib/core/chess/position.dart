class Position {
  final int file; // 0-7 (a-h)
  final int rank; // 0-7 (1-8)

  const Position(this.file, this.rank)
      : assert(file >= 0 && file <= 7, 'File must be between 0 and 7'),
        assert(rank >= 0 && rank <= 7, 'Rank must be between 0 and 7');

  factory Position.fromAlgebraic(String algebraic) {
    if (algebraic.length != 2) {
      throw const FormatException('Invalid algebraic notation');
    }
    final fileStr = algebraic[0].toLowerCase();
    final rankStr = algebraic[1];

    final file = fileStr.codeUnitAt(0) - 'a'.codeUnitAt(0);
    final rank = int.parse(rankStr) - 1;

    if (file < 0 || file > 7 || rank < 0 || rank > 7) {
      throw const FormatException('Coordinates out of bounds');
    }

    return Position(file, rank);
  }

  String get algebraic {
    final fileStr = String.fromCharCode('a'.codeUnitAt(0) + file);
    final rankStr = (rank + 1).toString();
    return '$fileStr$rankStr';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position &&
          runtimeType == other.runtimeType &&
          file == other.file &&
          rank == other.rank;

  @override
  int get hashCode => file.hashCode ^ rank.hashCode;
  
  @override
  String toString() => algebraic;
}
