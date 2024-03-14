import 'package:flutter/material.dart';

class GridScreen extends StatefulWidget {
  const GridScreen({Key? key}) : super(key: key);

  @override
  State<GridScreen> createState() => _GridScreenState();
}

class _GridScreenState extends State<GridScreen> {
  final TextEditingController mController = TextEditingController();
  final TextEditingController nController = TextEditingController();
  final TextEditingController alphabetsController = TextEditingController();
  final TextEditingController textController = TextEditingController();
  late List<List<String>> grid;
  int m = 0, n = 0;
  List<List<int>> highlightedCells = [];

  @override
  void initState() {
    super.initState();
    grid = [];
  }

  void createGrid() {
    String alphabets =
        alphabetsController.text.toUpperCase().replaceAll(' ', '');
    m = int.tryParse(mController.text) ?? 0;
    n = int.tryParse(nController.text) ?? 0;

    if (alphabets.length == m * n) {
      grid = List.generate(
        m,
        (i) => List.generate(n, (j) => alphabets[i * n + j]),
      );
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Ensure that the number of alphabets matches m * n.')),
      );
    }
  }

  List<List<int>> searchInGrid(String word) {
    highlightedCells.clear();
    for (int i = 0; i < m; i++) {
      for (int j = 0; j < n; j++) {
        for (var dir in directions) {
          final found = searchDirection(word, i, j, dir[0], dir[1]);
          if (found) {
            return highlightedCells;
          }
        }
      }
    }
    return [];
  }

  final List<List<int>> directions = [
    [0, 1], // right
    [1, 0], // down
    [-1, 1], // diagonal right up
  ];

  bool searchDirection(String word, int startX, int startY, int dx, int dy) {
    int x = startX;
    int y = startY;
    List<List<int>> tempHighlightedCells = [];

    for (int i = 0; i < word.length; i++) {
      if (x < 0 || x >= m || y < 0 || y >= n || grid[x][y] != word[i]) {
        return false;
      }
      tempHighlightedCells.add([x, y]);
      x += dx;
      y += dy;
    }

    if (tempHighlightedCells.isNotEmpty) {
      highlightedCells = tempHighlightedCells;
    } else {
      return false;
    }
    return true;
  }

  Widget displayGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: n,
        childAspectRatio: 1.0,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: m * n,
      itemBuilder: (context, index) {
        int row = index ~/ n;
        int col = index % n;
        bool isHighlighted =
            highlightedCells.any((cell) => cell[0] == row && cell[1] == col);
        return GridTile(
          child: Container(
            decoration: BoxDecoration(
              color: isHighlighted
                  ? const Color.fromARGB(255, 206, 161, 214)
                  : null,
              border: Border.all(color: Colors.purple.shade800),
            ),
            child: Center(
              child: Text(
                grid[row][col],
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Search Grid'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: mController,
                decoration: const InputDecoration(labelText: 'Enter m (rows)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: nController,
                decoration:
                    const InputDecoration(labelText: 'Enter n (columns)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: alphabetsController,
                decoration:
                    const InputDecoration(labelText: 'Enter Alphabets (m*n)'),
              ),
              ElevatedButton(
                onPressed: () {
                  createGrid();
                },
                child: const Text('Create Grid'),
              ),
              ElevatedButton(
                onPressed: () {
                  textController.text = '';
                  alphabetsController.text = '';
                },
                child: const Text('Reset'),
              ),
              if (grid.isNotEmpty)
                TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                        labelText: 'Enter Text to Search')),
              if (grid.isNotEmpty)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      var data =
                          searchInGrid(textController.text.toUpperCase());
                      if (data.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Not Present in east,south and south-east')),
                        );
                      }
                    });
                  },
                  child: const Text('Search Text'),
                ),
              if (grid.isNotEmpty) displayGrid(),
            ],
          ),
        ),
      ),
    );
  }
}
