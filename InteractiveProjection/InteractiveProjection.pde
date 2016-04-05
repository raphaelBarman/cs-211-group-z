float depth = 2000;
float rz = 0;
float ry = 0;
float rry = 0;
float rrz = 0;
void settings() {
size(500, 500, P3D);
}
void setup() {
noStroke();
}
void draw() {
camera(width/2, height/2, depth, 250, 250, 0, 0, 1, 0);
directionalLight(50, 100, 125, -1, 1, -1);
ambientLight(102, 102, 102);
background(200);
translate(width/2, height/2, 0);
float ratio = 0.9f;
// Using moving mean filter for smooth result
rrz = ratio*rrz + (1-ratio)*rz;
rry = ratio*rry + (1-ratio)*ry;
rotateX(rrz);
rotateY(rry);
box(500);
}

void keyPressed() {
if (key == CODED) {
if (keyCode == UP) {
rz -= 10*PI/180;
}
else if (keyCode == DOWN) {
rz += 10*PI/180;
}
if (keyCode == LEFT) {
ry -= 10*PI/180;
}
else if (keyCode == RIGHT) {
ry += 10*PI/180;
}
}
}