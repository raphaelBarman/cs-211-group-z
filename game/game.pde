float speed = 0.01;
float posX = 0;
float posZ = 0;
float boxWidth = 50;
float boxHeight = 50;
Mover mover;

void settings() {
  size(1024, 768, P3D);
}
void setup() {
  noStroke();
  perspective(PI/4,((float) height)/width,0.1,1000);
  mover = new Mover();
}
void draw() {
  camera(0, 40, 90, 0, 0, 0, 0, -1, 0);
  directionalLight(50, 100, 125, 0, -1, 0);
  ambientLight(102, 102, 102);
  background(200);
  posX = Math.min(PI/3.,Math.max(posX,-PI/3));
  posZ = Math.min(PI/3.,Math.max(posZ,-PI/3));
  pushMatrix();
  rotateX(posX);
  rotateZ(posZ);
  box(boxWidth,1,boxHeight);
  mover.checkEdges(boxWidth,boxHeight);
  mover.update(posX,posZ);
  mover.display();
  popMatrix();
}

void mouseDragged()
{
  posX += (mouseY - pmouseY)*speed;
  posZ += (mouseX - pmouseX)*speed;
}

void mouseWheel(MouseEvent event)
{
    speed *= Math.pow(2,-event.getCount());
}