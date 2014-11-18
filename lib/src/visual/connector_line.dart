part of Flock;

class ConnectorLine extends Bezier {
  static final _tan = new Vector2(0.5, 0.0);
  
  Vector2 get fromPt => _points[0];
  set fromPt(Vector2 value) {
    var width = (_points[2].x - _points[0].x).abs();
    _points[0] = value;
    _points[1] = _points[0] + (_tan * width);
    _points[3] = _points[2] - (_tan * width);
    _generateBuffer();
  }
  
  Vector2 get toPt => _points[2];
  set toPt(Vector2 value) {
    var width = (_points[2].x - _points[0].x).abs();
    _points[2] = value;
    _points[1] = _points[0] + (_tan * width);
    _points[3] = _points[2] - (_tan * width);
    _generateBuffer();
  }

  ConnectorLine(webgl.RenderingContext gl) : super(gl) {
    _points = new Vector2List(4);
  }
}