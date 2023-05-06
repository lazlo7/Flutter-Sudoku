enum SudokuDifficulty {
  easy(name: "Легкий", clues: 45),
  medium(name: "Средний", clues: 35),
  hard(name: "Сложный", clues: 25),
  expert(name: "Эксперт", clues: 18);

  const SudokuDifficulty({required this.name, required this.clues});

  final String name;
  final int clues;
}
