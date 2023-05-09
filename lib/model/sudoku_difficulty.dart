enum SudokuDifficulty {
  easy(name: "Легкий", minClues: 36, maxClues: 55),
  medium(name: "Средний", minClues: 26, maxClues: 35),
  hard(name: "Сложный", minClues: 20, maxClues: 25),
  expert(name: "Эксперт", minClues: 17, maxClues: 19);

  const SudokuDifficulty({required this.name, required this.minClues, required this.maxClues});

  final String name;
  final int minClues;
  final int maxClues;
}
