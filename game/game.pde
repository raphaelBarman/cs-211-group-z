float speed = 0.01;
float posX = 0;
float posZ = 0;
float boxWidth = 50;
float boxHeight = 50;
ArrayList<PVector> cylinders;
Cylinder cylinder;
Mover mover;
Mode mode;
enum Mode {
  NORMAL,
  PUT
}

void settings() {
  size(1024, 768, P3D);
}
void setup() {
  mode = Mode.NORMAL;
  noStroke();
  perspective(PI/4,((float) width)/height,0.1,1000);
  mover = new Mover();
  cylinders = new ArrayList();
  cylinder =  new Cylinder(16,5,3);
  cylinders.add(new PVector(5,5));
  
}
void draw() {
  switch(mode){
    case NORMAL:
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
                    //for(PVector vec : cylinders){
            //pushMatrix();
            //translate(vec.x,0,vec.y);
           cylinder.display();
            //popMatrix();
          //}
          mover.checkEdges(boxWidth,boxHeight);
          mover.update(posX,posZ);
          mover.display();
          popMatrix();
          break;
   case PUT:
         camera(0, 75, 0, 0, 0, 0, 0, 0, 1);
         directionalLight(50, 100, 125, 0, -1, 0);
          ambientLight(102, 102, 102);
          background(200);
          posX = Math.min(PI/3.,Math.max(posX,-PI/3));
          posZ = Math.min(PI/3.,Math.max(posZ,-PI/3));
          pushMatrix();
           for(PVector vec : cylinders){
            pushMatrix();
            translate(vec.x,0,vec.y);
            cylinder.display();
            popMatrix();
          }
          box(boxWidth,1,boxHeight);
          mover.display();
          popMatrix();
         break;
  }

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

void keyPressed(){
  if(key == CODED){
    if(keyCode == SHIFT){
      mode = Mode.PUT;
    }
  }
}

void keyReleased(){
  if(key == CODED){
    if(keyCode == SHIFT){
      mode = Mode.NORMAL;
    }
  }
}