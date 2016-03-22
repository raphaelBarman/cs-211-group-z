class Mover {
  final float GRAVITYCONSTANT = 9.81;
  final float TIMECONSTANT = 1f/24;
  PVector location;
  PVector velocity;
  
  Mover() {
    location = new PVector(0,3.5,0);
    velocity = new PVector(0,0,0);
  }
  
  void update(float angleX, float angleZ) {
    PVector gravityForce = new PVector(0,0,0);
    gravityForce.x = sin(angleZ) * (-1) * GRAVITYCONSTANT;
    gravityForce.z = sin(angleX) * GRAVITYCONSTANT;
    float normalForce = 1;
    float mu = 2.5;
    float frictionMagnitude = normalForce * mu;
    PVector friction = velocity.get();
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);
    velocity.add(PVector.mult(gravityForce,TIMECONSTANT));
    velocity.add(PVector.mult(friction,TIMECONSTANT));
    location.add(PVector.mult(velocity,TIMECONSTANT));
  }
  
  void checkEdges(float boxWidth, float boxHeight) {
    if (location.x > boxWidth/2f) {
      location.x = boxWidth/2f;
      velocity.x = velocity.x * (-1);
    }
    else if (location.x < -boxWidth/2f) {
      location.x = -boxWidth/2f;
      velocity.x = velocity.x * (-1);
    }
    if (location.z > boxHeight/2f) {
      location.z = boxHeight/2f;
      velocity.z = velocity.z * (-1);
    }
    else if (location.z < -boxHeight/2f) {
      location.z = -boxHeight/2f;
      velocity.z = velocity.z * (-1);
    }
  }
  
  void display() {
    noStroke();
    lights();
    translate(location.x,location.y,location.z);
    sphere(2);
  }
}