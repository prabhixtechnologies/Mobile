class CachedVariant {
  CachedVariant({
    required this.id,
    required this.productName,
    required this.variantName,
    required this.sku,
    this.barcode,
    this.availableQty = 0,
    this.retailPrice = 0,
    this.stockStatus = 'OK',
  });

  final String id;
  final String productName;
  final String variantName;
  final String sku;
  final String? barcode;
  final int availableQty;
  final double retailPrice;
  final String stockStatus;

  factory CachedVariant.fromJson(Map<String, dynamic> json) {
    return CachedVariant(
      id: '${json['id']}',
      productName: '${json['productName'] ?? ''}',
      variantName: '${json['variantName'] ?? ''}',
      sku: '${json['sku'] ?? ''}',
      barcode: json['barcode']?.toString(),
      availableQty: _int(json['availableQty']),
      retailPrice: _double(json['retailPrice']),
      stockStatus: '${json['stockStatus'] ?? 'OK'}',
    );
  }

  String get label => '$productName $variantName'.trim();
}

class CachedSale {
  CachedSale({
    required this.id,
    required this.invoiceNumber,
    this.total = 0,
    this.status,
  });

  final String id;
  final String invoiceNumber;
  final double total;
  final String? status;

  factory CachedSale.fromJson(Map<String, dynamic> json) {
    return CachedSale(
      id: '${json['id']}',
      invoiceNumber: '${json['invoiceNumber'] ?? json['id']}',
      total: _double(json['total']),
      status: json['status']?.toString(),
    );
  }
}

class CachedRepair {
  CachedRepair({
    required this.id,
    required this.jobNumber,
    this.status,
    this.problem,
    this.total = 0,
    this.outstanding = 0,
  });

  final String id;
  final String jobNumber;
  final String? status;
  final String? problem;
  final double total;
  final double outstanding;

  factory CachedRepair.fromJson(Map<String, dynamic> json) {
    return CachedRepair(
      id: '${json['id']}',
      jobNumber: '${json['jobNumber'] ?? json['id']}',
      status: json['status']?.toString(),
      problem: json['problem']?.toString(),
      total: _double(json['total']),
      outstanding: _double(json['outstanding']),
    );
  }
}

class CachedCustomer {
  CachedCustomer({
    required this.id,
    required this.name,
    this.phone,
    this.outstandingAmount = 0,
  });

  final String id;
  final String name;
  final String? phone;
  final double outstandingAmount;

  factory CachedCustomer.fromJson(Map<String, dynamic> json) {
    return CachedCustomer(
      id: '${json['id']}',
      name: '${json['name'] ?? ''}',
      phone: json['phone']?.toString(),
      outstandingAmount: _double(json['outstandingAmount']),
    );
  }
}

class CachedDevice {
  CachedDevice({
    required this.id,
    required this.name,
    this.brandName,
    this.modelCode,
  });

  final String id;
  final String name;
  final String? brandName;
  final String? modelCode;

  factory CachedDevice.fromJson(Map<String, dynamic> json) {
    return CachedDevice(
      id: '${json['id']}',
      name: '${json['name'] ?? ''}',
      brandName: json['brandName']?.toString(),
      modelCode: json['modelCode']?.toString(),
    );
  }
}

class CachedDashboard {
  CachedDashboard({
    this.todaySales = 0,
    this.todayTransactions = 0,
    this.pendingRepairs = 0,
    this.lowStockCount = 0,
  });

  final double todaySales;
  final int todayTransactions;
  final int pendingRepairs;
  final int lowStockCount;

  factory CachedDashboard.fromJson(Map<String, dynamic> json) {
    final sales = json['sales'] is Map
        ? Map<String, dynamic>.from(json['sales'] as Map)
        : json;
    final repairs = json['repairs'] is Map
        ? Map<String, dynamic>.from(json['repairs'] as Map)
        : <String, dynamic>{};
    final inventory = json['inventory'] is Map
        ? Map<String, dynamic>.from(json['inventory'] as Map)
        : <String, dynamic>{};
    return CachedDashboard(
      todaySales: _double(sales['todaySales'] ?? json['todaySales']),
      todayTransactions: _int(sales['todayTransactions'] ?? json['todayTransactions']),
      pendingRepairs: _int(repairs['pending'] ?? json['pendingRepairs']),
      lowStockCount: _int(inventory['lowStockCount'] ?? json['lowStockCount']),
    );
  }
}

int _int(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}

double _double(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? 0;
}
