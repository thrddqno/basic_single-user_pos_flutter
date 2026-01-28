class BillsHelper {
  static List<int> predictChange(double amount) {
    Set<int> suggestions = {};

    int first = ((amount / 5).ceil() * 5).toInt();
    suggestions.add(first);

    int second = _findNextMultiple(first, [10, 20, 50]);
    suggestions.add(second);

    while (suggestions.length < 4) {
      int last = suggestions.last;

      int next = _findSmallestJump(last, [100, 200, 500, 1000]);
      suggestions.add(next);
    }

    return suggestions.toList()..sort();
  }

  static int _findSmallestJump(int current, List<int> multiples) {
    int? smallest;
    for (int m in multiples) {
      int candidate = ((current / m).floor() + 1) * m;
      if (smallest == null || candidate < smallest) {
        smallest = candidate;
      }
    }
    return smallest ?? (current + 100);
  }

  static int _findNextMultiple(int current, List<int> multiples) {
    for (int m in multiples) {
      int candidate = ((current / m).floor() + 1) * m;
      if (candidate > current) return candidate;
    }
    return current + 100;
  }
}
