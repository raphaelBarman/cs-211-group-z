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
  perspective(fov,((float) width)/height,0.1,1000);
  mover = new Mover();
  cylinders = new ArrayList();
  cylinder =  new Cylinder(16,cylinderH,cylinderR);
}
void draw() {
  switch(mode){
    case NORMAL:
          camera(0, 70, -70, 0, 0, 0, 0, -1, 0);
          directionalLight(50, 100, 125, 0, -1, 0);
          ambientLight(102, 102, 102);
          background(200);
          posX = Math.min(PI/3.,Math.max(posX,-PI/3));
          posZ = Math.min(PI/3.,Math.max(posZ,-PI/3));
          pushMatrix();
          rotateX(posX);
          rotateZ(posZ);
          box(boxWidth,1,boxHeight);
          for(PVector vec : cylinders){
            pushMatrix();
            translate(vec.x,6/2,vec.z);
           cylinder.display();
            popMatrix();
          }
          mover.physics(cylinders);
          mover.update(posX,posZ);
          mover.display();
          popMatrix();
          break;
   case PUT:
         camera(0, viewheight, 0, 0, 0, 0, 0, 0, -1);
         directionalLight(50, 100, 125, 0, -1, 0);
          ambientLight(102, 102, 102);
          background(200);
          posX = Math.min(PI/3.,Math.max(posX,-PI/3));
          posZ = Math.min(PI/3.,Math.max(posZ,-PI/3));
          pushMatrix();
           for(PVector vec : cylinders){
            pushMatrix();
            translate(vec.x,0,vec.z);
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
  posX -= (mouseY - pmouseY)*speed;
  posZ -= (mouseX - pmouseX)*speed;
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

void mouseClicked(){
  if(mode == Mode.PUT){
    float x = 2.f*mouseX/width -1;
    float y = 2.f*mouseY/height -1;
    float ratio = 1.f*width/height;
    float whh = viewheight*tan(fov/2);
    float whw = whh*ratio;
    
    float px = x*whw;
    float py = -y*whh;
    if(abs(px) <= boxWidth/2.f-cylinderR && abs(py) <= boxHeight/2.f-cylinderR){
      cylinders.add(new PVector(px,0,py));
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