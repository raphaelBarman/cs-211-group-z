class Cylinder {
  private float cylinderHeight;
  private float radius;
  private int resolution;
  PShape top = new PShape();
  PShape bottom = new PShape();
  PShape side = new PShape();

  
  
  public Cylinder(float height,float radius, int resolution){
    this.cylinderHeight = height;
    this.radius = radius;
    this.resolution = resolution;
  }
  
  public Cylinder(float height,float radius){
    this.cylinderHeight = height;
    this.radius = radius;
    this.resolution = 40;
  }
  
  void constructShape(){
    float angle;
    float [] x = new float[resolution +1];
    float [] y = new float[resolution +1];
    
    for(int i = 0; i < x.length; i++) {
        angle = (TWO_PI / resolution) * i;
        x[i] = sin(angle) * radius;
        y[i] = cos(angle) * radius;
    }
    
    top = createShape();
    top.beginShape(TRIANGLE_FAN);
    top.vertex(0,cylinderHeight,0);
    
    bottom = createShape();
    bottom.beginShape(TRIANGLE_FAN);
    bottom.vertex(0,0,0);
    
    side = createShape();
    side.beginShape(QUAD_STRIP);


    for(int i =0; i < x.length; i++) {
       bottom.vertex(x[i],0, y[i]);
       top.vertex(x[i],cylinderHeight,y[i]);
       side.vertex(x[i], 0, y[i]);
       side.vertex(x[i], cylinderHeight, y[i] );
    }
  
   
    top.endShape();
    bottom.endShape();
    side.endShape();

  }
  
  void display() {

    shape(top);
    shape(bottom);
    shape(side);
  }
  
  
}