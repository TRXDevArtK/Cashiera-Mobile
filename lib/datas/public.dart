//public accessed data
//need login first

class LoginData{
  static bool status = false;
  static int start = 0;
  static int end = 0;
}

class DbData{
  static String name = "";
  static int id = 0;
  static String hostname = "";
  static String username = "";
  static String password = "";
  static String serviceUrl = "https://cashier112233.000webhostapp.com/asd21khkajsd910923ij1lkjsadjasd";
}

class UserData{
  static int id = 0;
  static String username = "";
  static String fullName = "";
  static String callName = "";
  static String email = "";
  static String phone = "";
  static int idStore = 0;
}

class StoreData{
  static String name = "Cashiera";
  static String location = "";
  static int config = 0;
  static String color = "#0000FF";
  static String logo = "";
  static String printLogo = "";
  static String printMsg = "Terima Kasih";
  static int mode = 0;
  static String latestData = "";
  static String timeZone = "UTC";
  static String imageUrl = "";
}

class CartData{
  static int countCart = 0;
}