public interface State {
    public void on_update(float dt, PApplet pa);
    public void on_draw(PGraphics pg, PApplet pa);
    public void on_begin(PGraphics pg,PApplet pa);
    public void on_end(PApplet pa);
    public void on_pause(PApplet pa);
    public void on_resume(PApplet pa);
    public void on_mouseWheel(MouseEvent event);
    public void on_mouseDragged(MouseEvent event);
    public void on_mouseClicked(MouseEvent event);
    public void on_keyPressed(KeyEvent event);
    public void on_keyReleased(KeyEvent event);
}

private enum Mode {
    NORMAL,
    PUT
}

private enum GameMode {
    TANGIBLE,
    LEGACY
}

public class GameState implements State
{
    private GameMode gmode;
    private Floor fl = new Floor(boxWidth,1,boxHeight,loadImage("textures/checkboard.jpg"));
    private Mode mode = Mode.NORMAL;
    private ArrayList<PVector> cylinders = new ArrayList();
    private PShape bush = loadShape("lowpolybush.obj");
    private Mover mover;
    private float posX = 0;
    private float posZ = 0;
    private color back_col = color(200,222,240);

    public GameState(GameMode mode)
    {
        gmode = mode;
        mover = new Mover();
    }

    public void on_update(float dt, PApplet pa)
    {
        if(gmode == GameMode.TANGIBLE) {
            //ip.rawRotation();
            PVector rot = ip.get3DRotation();
            posX = rot.x;
            posZ = rot.y;
        }
        switch(mode) {
        case NORMAL:
            mover.physics(cylinders);
            mover.update(posX,posZ);
            break;
        default:
            break;
        }
    }

    public void draw_scene(PGraphics pg, PApplet pa)
    {

        pg.pushMatrix();
        pg.translate(0,-0.5,0);
        fl.display(pg);
        pg.popMatrix();
        
        mover.display(pg);
        for(PVector vec : cylinders) {
            pg.pushMatrix();
            pg.translate(vec.x,0,vec.z);
            //cylinder.display(pg);
            pg.shape(bush);
            pg.popMatrix();
        }
    }

    public void normal_draw(PGraphics pg, PApplet pa)
    {
        pg.background(back_col);
        frameID++;
        pg.beginCamera();
        pg.camera(0, 90, -90, -2*posZ, 0, -2*posX, 0, -1, 0);
        posX = Math.min(PI/3.,Math.max(posX,-PI/3));
        posZ = Math.min(PI/3.,Math.max(posZ,-PI/3));
        pg.pushMatrix();
        pg.rotateX(posX);
        pg.rotateZ(posZ);
        draw_scene(pg,pa);
        pg.popMatrix();
        pg.endCamera();
    }

    public void put_draw(PGraphics pg, PApplet pa)
    {
        pg.background(back_col);
        pg.beginCamera();
        pg.camera(0, viewheight, 0, 0, 0, 0, 0, 0, -1);
        posX = Math.min(PI/3.,Math.max(posX,-PI/3));
        posZ = Math.min(PI/3.,Math.max(posZ,-PI/3));
        draw_scene(pg,pa);
        pg.endCamera();
    }

    public void on_draw(PGraphics pg, PApplet pa)
    {

        pg.perspective(fov,((float) width)/height,1,1000);
        //pg.lights();
        pg.directionalLight(253, 220, 200, -1, -1, 1);
        pg.ambientLight(102, 102, 102);
        switch(mode) {
        case NORMAL:
            normal_draw(pg,pa);
            break;
        case PUT:
            put_draw(pg,pa);
            break;
        default:
            break;
        }
        if(ip.last_img != null) {
              pg.resetMatrix();
              pg.noLights();
              pg.ortho();
              pg.translate(-width/2+20,-height/2+20);
              pg.scale(0.5);
              pg.image(ip.last_img,0,0);
        }
    }

    public void on_begin(PGraphics pg,PApplet pa)
    {
        pg.perspective(fov,((float) width)/height,1,1000); //<>//
        if(gmode == GameMode.TANGIBLE) {
            ip.initCam(144,pa);
        }
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

    public void on_mouseWheel(MouseEvent event)
    {
        speed *= Math.pow(2,-event.getCount());
    }

    public void on_mouseDragged(MouseEvent event)
    {
        if(gmode == GameMode.LEGACY && mode == Mode.NORMAL) {
            posX -= (mouseY - pmouseY)*speed;
            posZ -= (mouseX - pmouseX)*speed;
        }
    }

    public void on_mouseClicked(MouseEvent event)
    {
        if(mode == Mode.PUT) {
            float x = 2.f*mouseX/width -1;
            float y = 2.f*mouseY/height -1;
            float ratio = 1.f*width/height;
            float whh = viewheight*tan(fov/2);
            float whw = whh*ratio;

            float px = x*whw;
            float py = -y*whh;
            if(abs(px) <= boxWidth/2.f-cylinderR && abs(py) <= boxHeight/2.f-cylinderR) {
                cylinders.add(new PVector(px,0,py));
            }
        }
    }

    public void on_keyPressed(KeyEvent event)
    {
        if(key == CODED) {
            if(keyCode == SHIFT) {
                mode = Mode.PUT;
            }
        }
    }
    public void on_keyReleased(KeyEvent event)
    {
        if(key == CODED) {
            if(keyCode == SHIFT) {
                mode = Mode.NORMAL;
            }
        }
    }
}

enum MenuChoice{
  LEGACY(PI),
  TANGIBLE(0),
  CALIBRATE(-PI/2);
  public float angle;
  MenuChoice(float a) {
    angle = a;
  }
  MenuChoice next(){
    switch(this) {
      case LEGACY : return TANGIBLE;
      case TANGIBLE : return CALIBRATE;
      case CALIBRATE : return LEGACY;
      default : return LEGACY;
    }
  }
  MenuChoice previous(){
    switch(this) {
      case LEGACY : return CALIBRATE;
      case TANGIBLE : return LEGACY;
      case CALIBRATE : return TANGIBLE;
      default : return LEGACY;
    }
  }
}

public class MenuState implements State
{
    private GameMode gmode = GameMode.LEGACY;
    private PShape background = loadShape("Opening.obj");
    MenuChoice choice = MenuChoice.LEGACY;
    private float currentAngle = choice.angle;
    //private ArrayList<Float> angles = new ArrayList();
    
    public void on_update(float dt, PApplet pa)
    {
      currentAngle = currentAngle*0.9+choice.angle*0.1;
    }

    public void on_draw(PGraphics pg, PApplet pa)
    {
      pg.background(color(200,222,240));
      pg.perspective(-fov,((float) width)/height,1,1000);
       pg.directionalLight(253, 220, 200, -1, -1, 1);
        pg.ambientLight(102, 102, 102);
      pg.camera(0,0, 0, cos(currentAngle), 0, sin(currentAngle), 0, 1, 0);
      pg.shape(background);
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
      println("Resume Menu");
    }

    public void on_mouseWheel(MouseEvent event) {}
    public void on_mouseDragged(MouseEvent event) {}
    public void on_mouseClicked(MouseEvent event) {}
    public void on_keyPressed(KeyEvent event) {
      switch(key){
        case CODED: switch(keyCode) {
          case LEFT: choice = choice.previous(); break;
          case RIGHT: choice = choice.next(); break;
        } break;
        case RETURN: 
        case ENTER: switch(choice) {
          case LEGACY: push_state(new GameState(GameMode.LEGACY)); break;
          case TANGIBLE: push_state(new GameState(GameMode.TANGIBLE)); break;
          case CALIBRATE:  push_state(new ChooseCamState()); break;
          default: break;
        }
        case ESC: break;
        default: break;
      }
    }
    public void on_keyReleased(KeyEvent event) {}
}



public class ChooseCamState implements State
{
    private class Cam{
      int index;
      String name;
      Cam(int i, String s) {index = i; name = s;}
    };

    private ArrayList<Cam> cameras = new ArrayList();
    
    public void on_update(float dt, PApplet pa)
    {

    }

    public void on_draw(PGraphics pg, PApplet pa)
    {
      pg.background(200);
      float sizeh = height/32;
      pg.textSize(sizeh);
      pg.text("Choose Cam...",sizeh,sizeh*2);
      int i = 0;
      for(Cam c : cameras) {
        pg.text(c.name,sizeh*5,sizeh*(i+1));
        i++;
      }
    }

    public void on_begin(PGraphics pg,PApplet pa)
    {
      String[] cams = Capture.list();
      int i = 0;
      for(String cam : cams) {
        //println(cam);
        if(cam.contains("640x480") && cam.contains("fps=30")){
          cameras.add(new Cam(i,cam));
        }
        i++;
      }
      println(cameras.size());
      if(cameras.size() == 1 || true) {
        used_cam = cameras.get(0).name;
        
        push_state(new CalibrateState());
      }
    }

    public void on_end(PApplet pa)
    {

    }

    public void on_pause(PApplet pa)
    {

    }

    public void on_resume(PApplet pa)
    {
      println("Resume camera choose");
      pop_state();
    }

    public void on_mouseWheel(MouseEvent event) {}
    public void on_mouseDragged(MouseEvent event) {}
    public void on_mouseClicked(MouseEvent event) {}
    public void on_keyPressed(KeyEvent event) {
    }
    public void on_keyReleased(KeyEvent event) {}
}

public class CalibrateState implements State
{
    private Capture cam;
    private PGraphics g2d;
    
    public void on_update(float dt, PApplet pa)
    {

    }

    public void on_draw(PGraphics pg, PApplet pa)
    { //<>//
      if(cam.available()) {
        cam.read();
      }
      //pg.background(color(0,0,0,0));
      //g2d.background(200);
      pg.textSize(height/32);
      //g2d.text("Calibrating... Present board in square.",width/32,height/32*2);
      pg.camera();
      pg.ortho();
      int square_size = 160;
      PImage src = cam.get();
      if(src != null && src.width > 0 && src.height > 0) {
        //println("src " + src.width + " " + src.height);
        color mc = ip.mean_color(src,
        src.width/2-square_size/2,
        src.height/2-square_size/2,
        square_size,square_size);
        
        int hue = (int)hue(mc);
        ip.baseHue = hue;
        PImage filtered = ip.primaryFilter(src);
        pg.image(filtered,width/2-filtered.width/2,height/2-filtered.height/2);
        
        pg.stroke(255,0,0);
        pg.noFill();
        pg.rect(pg.width/2-square_size/2,
        pg.height/2-square_size/2,
        square_size,square_size);
        
        pg.fill(mc);
        pg.noStroke();
        pg.rect(25*pg.width/32,14*pg.height/32,square_size,square_size);
      }
      //image(g2d,0,0);
    }

    public void on_begin(PGraphics pg,PApplet pa)
    {
      g2d = createGraphics(width,height,P2D);
      if(g2d == null) {println("CACA");}
      cam = new Capture(pa, used_cam);
      cam.start();
    }

    public void on_end(PApplet pa)
    {
      cam.stop();
    }

    public void on_pause(PApplet pa)
    {

    }

    public void on_resume(PApplet pa)
    {

    }

    public void on_mouseWheel(MouseEvent event) {}
    public void on_mouseDragged(MouseEvent event) {}
    public void on_mouseClicked(MouseEvent event) {}
    public void on_keyPressed(KeyEvent event) {
      println("Key");
      if(key == RETURN || key == ENTER) {
          pop_state();
          println("state play");
      }
    }
    public void on_keyReleased(KeyEvent event) {}
}