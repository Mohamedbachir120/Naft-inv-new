class BienImmo {
  final String AST_CB;
  final String? AST_LIB;
  final String? AST_MODELE;
  final String? AST_SERIAL_NEMBER;
  final String? AST_MARQUE;
  final String? EMP_ID_AMU;
  final String? EMP_FULLNAME_AMU;
  final String? AST_TV_MATRICULE;
  final String? AST_TV_CODE;

  BienImmo(
      {required this.AST_CB,
      this.AST_LIB,
      this.AST_MODELE,
      this.AST_SERIAL_NEMBER,
      this.AST_MARQUE,
      this.EMP_ID_AMU,
      this.EMP_FULLNAME_AMU,
      this.AST_TV_CODE,
      this.AST_TV_MATRICULE});

  BienImmo copyWith(
      {String? AST_CB,
      String? AST_LIB,
      String? AST_MODELE,
      String? AST_SERIAL_NEMBER,
      String? AST_MARQUE,
      String? EMP_ID_AMU,
      String? EMP_FULLNAME_AMU,
      String? AST_TV_MATRICULE,
      String? AST_TV_CODE}) {
    return BienImmo(
        AST_CB: AST_CB ?? this.AST_CB,
        AST_LIB: AST_LIB ?? this.AST_LIB,
        AST_MODELE: AST_MODELE ?? this.AST_MODELE,
        AST_SERIAL_NEMBER: AST_SERIAL_NEMBER ?? this.AST_SERIAL_NEMBER,
        AST_MARQUE: AST_MARQUE ?? this.AST_MARQUE,
        EMP_ID_AMU: EMP_ID_AMU ?? this.EMP_ID_AMU,
        EMP_FULLNAME_AMU: EMP_FULLNAME_AMU ?? this.EMP_FULLNAME_AMU,
        AST_TV_CODE: AST_TV_CODE ?? this.AST_TV_CODE,
        AST_TV_MATRICULE: AST_TV_MATRICULE ?? this.AST_TV_MATRICULE);
  }
}
