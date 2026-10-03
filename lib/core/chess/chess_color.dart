enum ChessColor {
  white,
  black;

  ChessColor get opponent => this == ChessColor.white ? ChessColor.black : ChessColor.white;
}
