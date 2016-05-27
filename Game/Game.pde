Stack<State> state_stack;

ImageProcessing ip;
PGraphics mainFrame;
long frameID;

void settings()
{
    size(1024, 768, P2D);
}

void setup()
{
    mainFrame = createGraphics(width,height,P3D);
    noStroke();
    state_stack = new Stack<State>();
    push_state(new GameState());
    frameID = 0;
    
    ip = new ImageProcessing();
    //ip.initCam(144,this);
    //thread("parralel");
}

void push_state(State s) {
  
  if(!state_stack.empty()) {
    State os = state_stack.peek();
    os.on_pause(this);
  }
  s.on_begin(mainFrame,this);
  state_stack.push(s);
}

void pop_state() {
  if(!state_stack.empty()) {
    State s = state_stack.pop();
    s.on_end(this);
  }
  if(!state_stack.empty()) {
    State s = state_stack.peek();
    s.on_resume(this);
  }
}

void replace_state(State s) {
  pop_state();
  push_state(s);
}

void draw()
{
    if(state_stack.empty())
      return;
      
      
    State s = state_stack.peek();
    
    s.on_update(0.017,this);
    mainFrame.beginDraw();
    s.on_draw(mainFrame,this);
    mainFrame.endDraw();
    
    
    image(mainFrame,0,0);
    /*if(ip.last_img != null)
     image(ip.last_img,0,0);*/
} //<>//

void mouseDragged(MouseEvent event)
{
    posX -= (mouseY - pmouseY)*speed;
    posZ -= (mouseX - pmouseX)*speed;
}

void mouseWheel(MouseEvent event)
{
    speed *= Math.pow(2,-event.getCount());
}

void keyPressed()
{
}

void mouseClicked()
{
    /*if(mode == Mode.PUT) {
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
    }*/
}

void keyReleased()
{
    /*if(key == CODED) {
        if(keyCode == SHIFT) {
            mode = Mode.NORMAL;
        }
    }*/
}