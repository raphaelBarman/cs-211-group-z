class Cylinder
{
  private PShape side;
  private PShape top;
  private PShape bottom;
  private final float r;
  private final float h;
  private final float count;
  Cylinder(int count, float h, float r) {
    this.r = r;
    this.h = h;
    this.count = count;
    updateShape();
  }
  
  void updateShape()
  {
    float angle = 2*PI/count;
    side = createShape();
    side.beginShape(TRIANGLE_STRIP);
    top = createShape();
    bottom = createShape();
    top.beginShape(TRIANGLE_FAN);
    bottom.beginShape(TRIANGLE_FAN);
    top.vertex(0,h/2,0);
    bottom.vertex(0,-h/2,0);
    for (int i = 0; i < count + 1; i++) {
        float x = cos(i * angle) * r;
        float y = sin(i * angle) * r;
        side.vertex( x, h/2, y);
        side.vertex( x, -h/2,y);
        top.vertex( x, h/2, y);
        bottom.vertex( x, -h/2,y); 
    }
    bottom.endShape();
    top.endShape();
    side.endShape();
  }
  
  
  
  void display()
  {
    noStroke();
    lights();
    shape(side); //<>//
    shape(top);
    shape(bottom);
  }
  
};