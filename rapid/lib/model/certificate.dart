class Certificate {
  String firstName;
  String lastName;
  String userID;
  String testID;
  String created;
  String result;
  String expiringDate;
  String testMethod;

  Certificate({
    required this.firstName,
    required this.lastName,
    required this.userID,
    required this.testID,
    required this.created,
    required this.result,
    required this.expiringDate,
    this.testMethod = 'COV Ag-6012, Antigen Rapid Test',
  });
}
