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
    private Cylinder cylinder = new Cylinder(16,cylinderH,cylinderR);;
    private PShape bush = loadShape("objs/lowpolybush.obj");
    private Mover mover;
    private float posX = 0;
    private float posZ = 0;

    public GameState(GameMode mode)
    {
        gmode = mode;
        mover = new Mover();
        cylinder =  new Cylinder(16,cylinderH,cylinderR);
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
        //pg.box(boxWidth,1,boxHeight);
        fl.display(pg);
        pg.popMatrix();
        for(PVector vec : cylinders) {
            pg.pushMatrix();
            pg.translate(vec.x,0,vec.z);
            //cylinder.display(pg);
            pg.shape(bush);
            pg.popMatrix();
        }
        mover.display(pg);
    }

    public void normal_draw(PGraphics pg, PApplet pa)
    {
        pg.background(200);
        pg.fill(255);
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
        pg.background(200);
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
            image(ip.last_img,0,0);
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

public class MenuState implements State
{
    public void on_update(float dt, PApplet pa)
    {

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

    public void on_mouseWheel(MouseEvent event) {}
    public void on_mouseDragged(MouseEvent event) {}
    public void on_mouseClicked(MouseEvent event) {}
    public void on_keyPressed(KeyEvent event) {}
    public void on_keyReleased(KeyEvent event) {}
}