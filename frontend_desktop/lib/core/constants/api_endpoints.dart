class ApiEndpoints {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Auth
  static const String login = '$baseUrl/auth/login';
  static const String logout = '$baseUrl/auth/logout';
  static const String me = '$baseUrl/auth/me';

  // Secrétariat
  static const String secretaryDashboard = '$baseUrl/secretary/dashboard';
  static const String secretaryCustomers = '$baseUrl/secretary/customers';
  static const String secretaryProducts = '$baseUrl/secretary/products';
  static const String secretaryOrders = '$baseUrl/secretary/orders';
  static const String secretaryInquiries = '$baseUrl/secretary/inquiries';
  static String secretaryReceipt(int orderId) =>
      '$baseUrl/secretary/orders/$orderId/receipt';
  static String secretaryOrderPayment(int orderId) =>
      '$baseUrl/secretary/orders/$orderId/payments';

  // Comptabilité
  static const String accountingDashboard = '$baseUrl/accounting/dashboard';
  static const String accountingCashFlows = '$baseUrl/accounting/cash-flows';
  static const String accountingExpenses = '$baseUrl/accounting/expenses';
  static const String accountingPayments = '$baseUrl/accounting/payments';
  static const String accountingReceivables = '$baseUrl/accounting/receivables';
  static const String dailyRegisterCurrent =
      '$baseUrl/accounting/daily-register/current';
  static const String dailyRegisterOpen =
      '$baseUrl/accounting/daily-register/open';
  static const String dailyRegisterClose =
      '$baseUrl/accounting/daily-register/close';

  // Administration
  static const String adminDashboard = '$baseUrl/admin/dashboard';
  static const String adminCompany = '$baseUrl/admin/company';
  static const String adminFiscalYears = '$baseUrl/admin/fiscal-years';
  static const String adminUsers = '$baseUrl/admin/users';
  static const String adminCatalog = '$baseUrl/admin/catalog';
  static const String adminCatalogCategories =
      '$baseUrl/admin/catalog/categories';
  static const String adminCatalogProducts = '$baseUrl/admin/catalog/products';
}
