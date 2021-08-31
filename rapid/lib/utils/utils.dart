class Utils {
  String numberSeperator(String str, int n) {
    var result = new StringBuffer();

    for (int i = 0; i < str.length; i++) {
      if (str.length % 3 == 0) {
        if ((i != 0) && (i % n == 0)) {
          result.write('.${str[i]}');
        } else {
          result.write(str[i]);
        }
      } else if (str.length % 3 == 1) {
        if ((i != 0) && (i % n == 1)) {
          result.write('.${str[i]}');
        } else {
          result.write(str[i]);
        }
      } else {
        if ((i != 0) && (i % n == 2)) {
          result.write('.${str[i]}');
        } else {
          result.write(str[i]);
        }
      }
    }
    return result.toString();
  }
}
