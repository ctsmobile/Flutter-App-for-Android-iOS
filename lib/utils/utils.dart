class Utils {
  static double? width;
  static double? height;
  static String? email;
  static String? otp;
}

String getStringBeforeWord(String originalString, String specificWord) {
  List<String> parts = originalString.split(specificWord);
  if (parts.length > 1) {
    // If the specific word is found, return the substring before it
    return parts.first;
  } else {
    // If the specific word is not found, return the original string
    return originalString;
  }
}
