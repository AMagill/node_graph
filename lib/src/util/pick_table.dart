library pick_table;

import 'package:vector_math/vector_math.dart';

class PickTarget {
  final Object obj;
  final String str;
  PickTarget(this.obj, this.str);
  String toString() => obj.toString() + " " + str;
}

class PickTable {
  static final PickTable _singleton = new PickTable._internal();
  
  final table = new Map<int, PickTarget>();
  int _seed = 1;
  
  factory PickTable() {
    return _singleton;
  }
  
  PickTable._internal();
  
  Vector3 add(Object obj, String str) {
    _seed = _lfsr(_seed);
    table[_seed] = new PickTarget(obj, str);
    return new Vector3(((_seed>>16)&0xFF)/255.0, 
                       ((_seed>> 8)&0xFF)/255.0,
                       ((_seed    )&0xFF)/255.0);
  }
  
  PickTarget lookup(List<int> c) {
    var seedVal = (c[0]<<16) + (c[1]<<8) + c[2];
    return table[seedVal];
  }
  
  int _lfsr(int n) {
    if ((n & 1) != 0)
      n = (n >> 1) ^ 0x8566AB;  // Maximum-length 24-bit LFSR
    else
      n = (n >> 1);
    return n;
  }
}