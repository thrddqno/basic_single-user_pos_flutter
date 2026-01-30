class BillsHelper {
  static List<int> predictChange(double amount) {
    int base = (amount / 10).floor() * 10 + 10;

    Set<int> suggestions = {base};

    List<int> denominations = [20, 50, 100, 200, 500, 1000];

    for (int bill in denominations) {
      if (suggestions.length >= 4) break;

      int nextMultiple = (amount / bill).ceil() * bill;

      if (nextMultiple > suggestions.last) {
        suggestions.add(nextMultiple);
      }
    }

    while (suggestions.length < 4) {
      suggestions.add(suggestions.last + 1000);
    }

    return suggestions.toList()..sort();
  }
}
