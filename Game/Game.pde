ArrayList<PVector> cylinders;
ArrayList<Float> scoreLog;
Cylinder cylinder;
Mover mover;
Mode mode;
enum Mode {
   NORMAL,
  PUT
}
// P3D canvas over which all 3d stuff is drawn.
//PGraphics canvas;

PGraphics bottomBar;

PGraphics topView;
PVector oldLocation;

PGraphics score;
float  scoreTotal;
float lastScore;
long frameID;

PGraphics barChart;

HScrollbar hScrollbar;

void settings() {
  size(1024, 768, P3D);
}
void setup() {
  mode = Mode.NORMAL;
  noStroke();
  perspective(fov,((float) width)/height,0.1,1000);
  mover = new Mover();
  cylinders = new ArrayList();
  scoreLog = new ArrayList();
  cylinder =  new Cylinder(16,cylinderH,cylinderR);
  bottomBar = createGraphics(width,height/5,P2D);
  topView = createGraphics((int)(bottomBar.height*0.9),(int)(bottomBar.height*0.9),P2D);
  topView.beginDraw();
  topView.background(6,101,130);
  topView.endDraw();
  score = createGraphics((int)(bottomBar.height*0.8),(int)(bottomBar.height*0.95),P2D);
  scoreTotal = 0;
  lastScore = 0;
  barChart = createGraphics((int)(bottomBar.width*0.7),(int)(bottomBar.height*0.75),P2D);
  frameID = 0;
  hScrollbar = new HScrollbar(bottomBar.width/3.5,height-height/30,bottomBar.width/6,bottomBar.height/10);
}
void draw() {
  perspective(fov,((float) width)/height,0.1,1000);

  background(200);
  fill(255);
  switch(mode){
    case NORMAL:
         frameID++;
          beginCamera();
          camera(0, 90, -90, 0, 0, 0, 0, -1, 0);
          directionalLight(50, 100, 125, 0, -1, 0);
          ambientLight(102, 102, 102);

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
          endCamera();
          break;
   case PUT:
         beginCamera();
         camera(0, viewheight, 0, 0, 0, 0, 0, 0, -1);
         directionalLight(50, 100, 125, 0, -1, 0);
          ambientLight(102, 102, 102);
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
         endCamera();
         break;
  }
  ortho();
  camera();
  noLights();
  if(frameID % logPeriod == 0) {
    pushLogs();
  }
  drawBottomBar();
  //drawBarChart();
  image(bottomBar,0,height-(bottomBar.height));
  //image(barChart,width-barChart.width,barChart.height);
  hScrollbar.update();
  hScrollbar.display();

}

void drawBottomBar() {
  drawTopView();
  drawScore();
  drawBarChart();
  bottomBar.beginDraw();
  bottomBar.background(230,226,175);
  bottomBar.image(topView,bottomBar.height*0.95-topView.height,bottomBar.height*0.95-topView.height);
  bottomBar.image(score,2*(bottomBar.height*0.95-topView.height)+topView.width,bottomBar.height*0.975-score.height);
  bottomBar.image(barChart,bottomBar.width/3.5,bottomBar.height*0.05);
  bottomBar.endDraw();
}

void drawScore() {
  score.beginDraw();
  score.background(255);
  score.fill(230,226,175);
  score.noStroke();
  score.rect(score.width-score.width*0.975,score.height-score.height*0.975,score.width*0.95,score.height*0.95);
  score.fill(0);
  String scoreString = "Total Score : \n"
              + scoreTotal +
              "\n\nVelocity : \n"
              + mover.getCurrentSpeed() +
              "\n\nLast Score : \n"
              + lastScore;
  score.text(scoreString,score.width/10,score.height/7);
  
  //score.text("hello", 15,15);
  score.endDraw();
}

void updateScore(float speed) {
   scoreTotal += speed;
   scoreTotal = Math.round((scoreTotal*1000.0)/1000.0);
   scoreTotal = max(0,scoreTotal);
   lastScore = speed;
}

void pushLogs() {
   scoreLog.add(scoreTotal);
}

void drawTopView() {
  topView.beginDraw();
    //topView.background(6,101,130);
    topView.noStroke();
    PVector p = mover.getLocation();
    if(oldLocation != null) {
     topView.fill(6,97,126);
     topView.ellipse((boxWidth/2+oldLocation.x)/boxWidth*topView.width,(boxHeight/2-oldLocation.y)/boxHeight*topView.height,sphereR/boxWidth*topView.width*2,sphereR/boxWidth*topView.width*2);
    }
    topView.fill(9, 153, 199);
    topView.ellipse((boxWidth/2+p.x)/boxWidth*topView.width,(boxHeight/2-p.y)/boxHeight*topView.height,sphereR/boxWidth*topView.width*2,sphereR/boxWidth*topView.width*2);
    topView.fill(255,0,0);
    for(PVector vec : cylinders){
       topView.ellipse((boxWidth/2+vec.x)/boxWidth*topView.width,(boxHeight/2-vec.z)/boxHeight*topView.height,cylinderR/boxWidth*topView.width*2,cylinderR/boxWidth*topView.width*2);
    }
    topView.endDraw();
    oldLocation = p;
}

void drawBarChart() {
  barChart.beginDraw();
  barChart.background(239, 236, 202);
  float bw = 9f;
  float bh = 9f;
  float pad = 1.5f;
  int count = (int)(barChart.width/bw);
  color topc = color(30,30,180);
  color botc = color(255,0,0);//color(80,100,180);
  barChart.noStroke();
  float maxS = 1;
  for(int i = max(scoreLog.size()-count,0); i < scoreLog.size(); i++) {
    maxS = max(maxS,abs(scoreLog.get(i)));
  }
  int start = max(scoreLog.size()-count,0);
  for(int i = start; i < scoreLog.size(); i++) {
    int h = (int)(scoreLog.get(i)/(maxS*bh) * barChart.height);
    for(int j = 0; j < h; j++) {
      barChart.fill(lerpColor(botc,topc,(float)j/h));
      barChart.rect((i-start)*bw,barChart.height-j*bw,bw-pad,bh-pad,0,0,0,0);
    }
  }
  barChart.endDraw();
}

void mouseDragged()
{
  if(!hScrollbar.isLocked()){
  posX -= (mouseY - pmouseY)*speed;
  posZ -= (mouseX - pmouseX)*speed;
  }
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