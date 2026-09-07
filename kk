import "package:flutter/material.dart";
import "../models/umuntu.dart";
import "../models/inguzanyo.dart";
import "../models/amateka.dart";

class AppProvider extends ChangeNotifier {
  // ============================
  // ACCOUNTS (Login/Register)
  // ============================
  final Map<String, String> _accounts = {
    "0788222333": "123456",
  };
  String _currentPhone = "";

  // ============================
  // ITSINDA SETTINGS (from Wizard)
  // ============================
  String _groupName = "Itsinda Ryacu";
  double _umusanzuFatizo = 2000;
  double _ingobokaFatizo = 200;
  double _amandeFatizo = 500;
  double _ijanisha = 5.0;
  String _umutango = "Buri Kwezi";

  // ============================
  // LISTS (Abanyamuryango + Inguzanyo + Amateka)
  // ============================
  final List<Umuntu> _abantu = [];
  final List<Inguzanyo> _inguzanyo = [];
  final List<Amateka> _amateka = [];

  // ============================
  // GETTERS - ITSINDA
  // ============================
  String get groupName => _groupName;
  double get umusanzuFatizo => _umusanzuFatizo;
  double get ingobokaFatizo => _ingobokaFatizo;
  double get amandeFatizo => _amandeFatizo;
  double get ijanisha => _ijanisha;
  String get umutango => _umutango;
  String get currentPhone => _currentPhone;

  // ============================
  // GETTERS - LISTS
  // ============================
  List<Umuntu> get abantu => _abantu;
  List<Inguzanyo> get inguzanyo => _inguzanyo;
  List<Amateka> get amateka => _amateka;

  // ============================
  // GETTERS - FINANCIAL
  // ============================
  double get cashInBox {
    double total = 0;
    for (var m in _abantu) {
      total += m.umusanzu;
    }
    return total;
  }

  double get imisanzuYose {
    double total = 0;
    for (var m in _abantu) {
      total += m.umusanzu + m.ingoboka;
    }
    return total;
  }

  double get igikorwamari {
    return imisanzuYose + inyunguZagabanijwe - inguzanyoZisigaye;
  }

  double get inguzanyoZisigaye {
    double total = 0;
    for (var i in _inguzanyo) {
      if (!i.yarishyuye) {
        total += i.inguzanyoAmafaranga;
      }
    }
    return total;
  }

  double get inyunguZagabanijwe {
    double total = 0;
    for (var i in _inguzanyo) {
      if (i.yarishyuye) {
        total += (i.inguzanyoAmafaranga * (_ijanisha / 100));
      }
    }
    return total;
  }

  double get ibihano {
    double total = 0;
    for (var m in _abantu) {
      if (m.ideniKUmusanzuUtatanzwe > 0) {
        total += _amandeFatizo;
      }
    }
    return total;
  }

  int get inguzanyoZatanzwe => _inguzanyo.length;
  int get abarengeje {
    int count = 0;
    for (var i in _inguzanyo) {
      if (!i.yarishyuye) count++;
    }
    return count;
  }

  // ============================
  // LOGIN
  // ============================
  String login(String phone, String password) {
    if (phone.isEmpty) return "Andika phone number";
    if (password.isEmpty) return "Andika ijambo banga";
    if (!_accounts.containsKey(phone)) return "Nta account ifunguye! Iyandikishe";
    if (_accounts[phone] != password) return "Ijambo banga si ryo!";
    _currentPhone = phone;
    notifyListeners();
    return "Success";
  }

  // ============================
  // REGISTER
  // ============================
  String register(String phone, String password) {
    if (phone.isEmpty) return "Andika phone number";
    if (password.isEmpty) return "Andika ijambo banga";
    if (_accounts.containsKey(phone)) return "Account ifunguye! Injira";
    _accounts[phone] = password;
    _currentPhone = phone;
    notifyListeners();
    return "Success";
  }

  // ============================
  // UPDATE SETTINGS (from Wizard)
  // ============================
  void updateSettings({
    required String groupName,
    required int memberCount,
    required double umusanzu,
    required double ingoboka,
    required double amande,
    required double ijanisha,
    required String umutango,
  }) {
    _groupName = groupName;
    _umusanzuFatizo = umusanzu;
    _ingobokaFatizo = ingoboka;
    _amandeFatizo = amande;
    _ijanisha = ijanisha;
    _umutango = umutango;
    
    // Kora abanyamuryango bingana na memberCount
    _abantu.clear();
    for (int i = 0; i < memberCount; i++) {
      _abantu.add(Umuntu(
        id: "M${i + 1}",
        izina: "Umunyamuryango ${i + 1}",
        phone: "",
        umusanzu: 0,
        ingoboka: 0,
        amande: 0,
        ideniKUmusanzuUtatanzwe: 0,
        igiteranyo: 0,
        itariki: DateTime.now().toString().substring(0, 10),
      ));
    }
    notifyListeners();
  }

  // ============================
  // ADD UMUNTU
  // ============================
  void addUmuntu(String izina, String phone) {
    _abantu.add(Umuntu(
      id: DateTime.now().toString(),
      izina: izina,
      phone: phone,
      umusanzu: 0,
      ingoboka: 0,
      amande: 0,
      ideniKUmusanzuUtatanzwe: 0,
      igiteranyo: 0,
      itariki: DateTime.now().toString().substring(0, 10),
    ));
    _addAmateka(izina, "Umusanzu", 0, "Yongeweho mu itsinda");
    notifyListeners();
  }

  // ============================
  // ADD UMUSANZU
  // ============================
  void addUmusanzu(String memberId, double amount) {
    final index = _abantu.indexWhere((m) => m.id == memberId);
    if (index != -1) {
      _abantu[index].umusanzu += amount;
      // Niba afite ideni, rigabanuke
      if (_abantu[index].ideniKUmusanzuUtatanzwe > 0) {
        _abantu[index].ideniKUmusanzuUtatanzwe -= amount;
        if (_abantu[index].ideniKUmusanzuUtatanzwe < 0) {
          _abantu[index].ideniKUmusanzuUtatanzwe = 0;
        }
      }
      _abantu[index].igiteranyo = _abantu[index].umusanzu + _abantu[index].ingoboka;
      _addAmateka(_abantu[index].izina, "Umusanzu", amount, "Yatanze umusanzu");
      notifyListeners();
    }
  }

  // ============================
  // ADD IBIHANO (Niba utatanze)
  // ============================
  void sibaUmusanzu(String memberId) {
    final index = _abantu.indexWhere((m) => m.id == memberId);
    if (index != -1) {
      _abantu[index].ideniKUmusanzuUtatanzwe += _umusanzuFatizo;
      _abantu[index].amande += _amandeFatizo;
      _addAmateka(_abantu[index].izina, "Amande", _amandeFatizo, "Yasibye umusanzu");
      notifyListeners();
    }
  }

  // ============================
  // ADD INGUZANYO
  // ============================
  void addInguzanyo(String izina, double amafaranga, String impamvu) {
    _inguzanyo.add(Inguzanyo(
      id: DateTime.now().toString(),
      izina: izina,
      inguzanyoAmafaranga: amafaranga,
      impamvu: impamvu,
      umwishingizi: "",
      akagari: "",
      umudugudu: "",
      itariki: DateTime.now().toString().substring(0, 10),
      itarikiNtarengwa: DateTime.now().toString().substring(0, 10),
    ));
    _addAmateka(izina, "Inguzanyo", amafaranga, impamvu);
    notifyListeners();
  }

  // ============================
  // KWISHYURA INGUZANYO
  // ============================
  void kwishyuraInguzanyo(String id, double amount) {
    final index = _inguzanyo.indexWhere((i) => i.id == id);
    if (index != -1) {
      _inguzanyo[index].inguzanyoAmafaranga -= amount;
      _addAmateka(_inguzanyo[index].izina, "Kwishyura", amount, "Yishyuye inguzanyo");
      
      if (_inguzanyo[index].inguzanyoAmafaranga <= 0) {
        _inguzanyo[index].yarishyuye = true;
        // INYUNGU ZIGABANYWA BURI MUNTU
        _gabanyaInyungu();
      }
      notifyListeners();
    }
  }

  // ============================
  // GABANYA INYUNGU KURI BURI MUNTU
  // ============================
  void _gabanyaInyungu() {
    double totalInyungu = inyunguZagabanijwe;
    if (_abantu.isNotEmpty && totalInyungu > 0) {
      double umugabane = totalInyungu / _abantu.length;
      for (var m in _abantu) {
        m.igiteranyo += umugabane;
      }
      _addAmateka("Itsinda ryose", "Dividend", totalInyungu, "Inyungu zagabanijwe");
    }
  }

  // ============================
  // ADD AMATEKA (History)
  // ============================
  void _addAmateka(String izina, String ubwoko, double amafaranga, String ibisobanuro) {
    _amateka.add(Amateka(
      id: DateTime.now().toString(),
      izina: izina,
      ubwoko: ubwoko,
      amafaranga: amafaranga,
      ibisobanuro: ibisobanuro,
      itariki: DateTime.now().toString(),
      icon: _getIconForUbwoko(ubwoko),
    ));
  }

  IconData _getIconForUbwoko(String ubwoko) {
    switch (ubwoko) {
      case "Umusanzu":
        return Icons.savings;
      case "Inguzanyo":
        return Icons.account_balance_wallet;
      case "Amande":
        return Icons.gavel;
      case "Kwishyura":
        return Icons.check_circle;
      case "Dividend":
        return Icons.card_giftcard;
      default:
        return Icons.info;
    }
  }
}
