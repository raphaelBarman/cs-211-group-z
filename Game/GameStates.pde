public interface State{
  public void on_update(float dt, PApplet pa);
  public void on_draw(PGraphics pg, PApplet pa);
  public void on_begin(PGraphics pg,PApplet pa);
  public void on_end(PApplet pa);
  public void on_pause(PApplet pa);
  public void on_resume(PApplet pa);
}

public class GameState implements State {
  
  private ArrayList<PVector> cylinders;
  Cylinder cylinder;
  Mover mover;
  
  public GameState() {
    mover = new Mover();
    cylinder =  new Cylinder(16,cylinderH,cylinderR);
  }
  
  public void on_update(float dt, PApplet pa){
    mover.physics(cylinders);
    mover.update(posX,posZ);
  }
  
  public void on_draw(PGraphics pg, PApplet pa)
  {
    pg.background(200);
    pg.fill(255);
    frameID++;
    pg.beginCamera();
    pg.camera(0, 90, -90, 0, 0, 0, 0, -1, 0);
    pg.directionalLight(50, 100, 125, 0, -1, 0);
    pg.ambientLight(102, 102, 102);

    posX = Math.min(PI/3.,Math.max(posX,-PI/3));
    posZ = Math.min(PI/3.,Math.max(posZ,-PI/3));
    //ip.rawRotation();
    //PVector rot = ip.get3DRotation();
    //println(rot);
    //posX = rot.x;
    //posZ = rot.y;
    pg.pushMatrix();
    pg.rotateX(posX);
    pg.rotateZ(posZ);
    pg.box(boxWidth,1,boxHeight);
    /*for(PVector vec : cylinders) {
        pg.pushMatrix();
        pg.translate(vec.x,6/2,vec.z);
        cylinder.display(pg);
        pg.popMatrix();
    }*/
    
    
    mover.display(pg);
    pg.popMatrix();
    pg.endCamera();
  }
  
  public void on_begin(PGraphics pg,PApplet pa)
  {
    pg.perspective(fov,((float) width)/height,0.1,1000);
  }
  
  public void on_end(PApplet pa)
  {
  }
  
  public void on_pause(PApplet pa)
  {
  }
  
  public void on_resume(PApplet pa)
  {
  }
}

public class MenuState implements State {
  public void on_update(float dt, PApplet pa){
    
  }
  
  public void on_draw(PGraphics pg, PApplet pa)
  {
    
  }
  
  public void on_begin(PGraphics pg,PApplet pa)
  {
    
  }
  
  public void on_end(PApplet pa)
  {
    
  }
  
  public void on_pause(PApplet pa)
  {
    
  }
  
  public void on_resume(PApplet pa)
  {
    
  }
}