enum SudokuDifficulty {
  extremelyEasy(name: "Очень легкий", minClues: 50, maxClues: 55),
  easy(name: "Легкий", minClues: 36, maxClues: 49),
  medium(name: "Средний", minClues: 32, maxClues: 35),
  hard(name: "Сложный", minClues: 28, maxClues: 31),
  expert(name: "Эксперт", minClues: 22, maxClues: 27);

  const SudokuDifficulty(
      {required this.name, required this.minClues, required this.maxClues});

  final String name;
  final int minClues;
  final int maxClues;
}
