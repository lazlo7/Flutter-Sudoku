enum SudokuDifficulty {
  extremelyEasy(
      name: "Очень легкий", minClues: 50, maxClues: 55, hintsReward: 0),
  easy(name: "Легкий", minClues: 36, maxClues: 49, hintsReward: 1),
  medium(name: "Средний", minClues: 32, maxClues: 35, hintsReward: 2),
  hard(name: "Сложный", minClues: 28, maxClues: 31, hintsReward: 3),
  expert(name: "Эксперт", minClues: 22, maxClues: 27, hintsReward: 5);

  const SudokuDifficulty(
      {required this.name,
      required this.minClues,
      required this.maxClues,
      required this.hintsReward});

  final String name;
  final int minClues;
  final int maxClues;
  final int hintsReward;
}
