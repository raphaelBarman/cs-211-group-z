import java.util.List;
class Mover
{
    final float GRAVITYCONSTANT = 9.81;
    final float TIMECONSTANT = 1f/24;
    PVector location;
    PVector velocity;
    PShape shadow;

    Mover()
    {
        location = new PVector(0,sphereR,0);
        velocity = new PVector(0,0,0);
        shadow = createShape();
        shadow.beginShape();
        shadow.texture(loadImage("textures/rndshadow.png"));
        shadow.normal(0,1,0);
        float dim = 32;
        float d = sphereR*1.2;
        shadow.vertex(-d, 0,  d, 0, 0);
        shadow.vertex( d,  0,  d, dim, 0);
        shadow.vertex( d,  0, -d, dim,dim);
        shadow.vertex(-d,  0, -d, 0, dim);
        shadow.endShape();
    }

    void update(float angleX, float angleZ)
    {
        PVector gravityForce = new PVector(0,0,0);
        gravityForce.x = sin(angleZ) * (-1) * GRAVITYCONSTANT;
        gravityForce.z = sin(angleX) * GRAVITYCONSTANT;
        float normalForce = 1;

        float frictionMagnitude = normalForce * mu;
        PVector friction = velocity.get();
        friction.mult(-1);
        friction.normalize();
        friction.mult(frictionMagnitude);
        velocity.add(PVector.mult(gravityForce,TIMECONSTANT));
        velocity.add(PVector.mult(friction,TIMECONSTANT));
        location.add(PVector.mult(velocity,TIMECONSTANT));
    }

    void checkEdges()
    {
        if (location.x > boxWidth/2f) {
            //updateScore(- getCurrentSpeed());
            location.x = boxWidth/2f;
            velocity.x = velocity.x * (-1);
        } else if (location.x < -boxWidth/2f) {
            //updateScore(- getCurrentSpeed());
            location.x = -boxWidth/2f;
            velocity.x = velocity.x * (-1);
        }
        if (location.z > boxHeight/2f) {
            //updateScore(- getCurrentSpeed());
            location.z = boxHeight/2f;
            velocity.z = velocity.z * (-1);
        } else if (location.z < -boxHeight/2f) {
            //updateScore(- getCurrentSpeed());
            location.z = -boxHeight/2f;
            velocity.z = velocity.z * (-1);
        }
    }

    void physics(List<PVector> cylinders)
    {
        checkEdges();
        for(PVector p : cylinders) {
            PVector flatLocation = new PVector(location.x,0,location.z);
            if(ShapeUtils.collideWith(flatLocation,p,cylinderR,sphereR)) {
                //updateScore(getCurrentSpeed());
                flatLocation = ShapeUtils.extractFromCylinder(flatLocation,p,sphereR,cylinderR);
                location = new PVector(flatLocation.x,location.y,flatLocation.z);
                velocity = ShapeUtils.cylinderBounce(velocity,flatLocation,p);
            }
        }
    }

    PVector getLocation()
    {
        return new PVector(location.x,location.z);
    }
    float getCurrentSpeed()
    {
        return (velocity.mag() > 1) ? Math.round(velocity.mag()*1000.0)/1000.0 : 0.0;
    }

    void display(PGraphics disp)
    {
        disp.pushMatrix();
        disp.noStroke();
        
        disp.translate(location.x,0.01,location.z);
        disp.shape(shadow);
        disp.translate(0,location.y,0);
        disp.sphere(sphereR);
        disp.popMatrix();
    }
}