part of Flock;

class Graph {
  final fontSrc = ['/packages/Flock/fonts/font.png',
                   '/packages/Flock/fonts/font.json'];

  BaseNode outputNode;
  List<BaseNode> nodes = [];
  Map<Connector, Connection> connections = {};
  
  final webgl.RenderingContext gl;
  final sdfText;
  
  Graph(gl) 
    : this.gl = gl,
      sdfText = new DistanceField(gl) {
    sdfText.loadUrl(fontSrc[0], fontSrc[1]);
  }
  
  BaseNode addNode(String type, {x:0.0, y:0.0}) {
    BaseNode newNode = new BaseNode.NamedType(this, type, x, y);

    if (newNode != null)
      nodes.add(newNode);
    
    return newNode;
  }
  
  void draw(Matrix4 projection, [bool picking = false]) {
    for (var node in nodes) {
      node.draw(projection, picking);
    }
    
    if (!picking) {
      for (var line in connections.values) {
        line.draw(projection, picking);
      }
    }
  }
  
  void connect(Connector outCon, Connector inCon) {
    disconnect(inCon);    // Inputs should never have more than one connection.
    
    var newConnection = new Connection(gl, outCon, inCon);
    connections[inCon] = newConnection;
    outCon.connections.add(newConnection);
    inCon.connections.add(newConnection);
    
    sortNodes();
  }
  
  void disconnect(Connector inCon) {
    for (var connection in inCon.connections) {
      connection.conFrom.connections.remove(connection);
    }
    connections.remove(inCon);
    inCon.connections.clear();
    
    sortNodes();
  }
  
  bool sortNodes([BaseNode testFrom, BaseNode testTo]) {
    // To solve the graph, we need to compute the value of each connection in
    // order so that each node's outputs are computed after all its inputs.
    // This is what topological sorting is for.
    var sorted   = [];
    var unmarked = nodes.toSet();
    var tempMark = new Set<BaseNode>();
    
    bool visit(BaseNode n) {
      if (tempMark.contains(n))
        return false;
      if (unmarked.contains(n)) {
        tempMark.add(n);
        if (n == testFrom)
          if (!visit(testTo)) return false;
        for (var m in n.outputConnections) {
          if (!visit(m.conTo.node)) return false;          
        }
        unmarked.remove(n);
        tempMark.remove(n);
        sorted.add(n);
      }
      return true;
    }
    
    while (unmarked.isNotEmpty)
      if (!visit(unmarked.first)) return false;
    
    sorted = sorted.reversed.toList(growable:false);
    return true;
  }
}
