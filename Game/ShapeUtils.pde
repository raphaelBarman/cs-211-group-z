class Cylinder
{
    private PShape side;
    private PShape top;
    private PShape bottom;
    private final float r;
    private final float h;
    private final float count;
    Cylinder(int count, float h, float r)
    {
        this.r = r;
        this.h = h;
        this.count = count;
        updateShape();
    }

    void updateShape()
    {
        float angle = 2*PI/count;
        //fill(255,0,0);
        side = createShape();
        side.beginShape(TRIANGLE_STRIP);
        top = createShape();
        bottom = createShape();
        top.beginShape(TRIANGLE_FAN);
        bottom.beginShape(TRIANGLE_FAN);
        top.vertex(0,h/2,0);
        bottom.vertex(0,-h/2,0);
        for (int i = 0; i < count + 1; i++) {
            float x = cos(i * angle) * r;
            float y = sin(i * angle) * r;
            side.vertex( x, h/2, y);
            side.vertex( x, -h/2,y);
            top.vertex( x, h/2, y);
            bottom.vertex( x, -h/2,y);
        }
        bottom.endShape();
        top.endShape();
        side.endShape();
        bottom.setFill(color(255,0,0));
        top.setFill(color(255,0,0));
        side.setFill(color(255,0,0));
    }



    void display(PGraphics disp)
    {
        disp.noStroke();
        //lights();/<>//
        disp.shape(top);
        disp.shape(side);
        disp.shape(bottom);
    }

};

class Floor
{
    private PShape fl;
    private float sx,sy,sz;
    Floor(float x, float y, float z, PImage tex)
    {
        sx=x;
        sy=y;
        sz=z;
        fl = createShape();


        fl.beginShape(QUADS);
        fl.texture(tex);

        // Given one texture and six faces, we can easily set up the uv coordinates
        // such that four of the faces tile "perfectly" along either u or v, but the other
        // two faces cannot be so aligned.  This code tiles "along" u, "around" the X/Z faces
        // and fudges the Y faces - the Y faces are arbitrarily aligned such that a
        // rotation along the X axis will put the "top" of either texture at the "top"
        // of the screen, but is not otherwised aligned with the X/Z faces. (This
        // just affects what type of symmetry is required if you need seamless
        // tiling all the way around the cube)

        // +Z "front" face
        fl.vertex(-1, -1,  1, 0, 0);
        fl.vertex( 1, -1,  1, 1, 0);
        fl.vertex( 1,  1,  1, 1, 1);
        fl.vertex(-1,  1,  1, 0, 1);

        // -Z "back" face
        fl.vertex( 1, -1, -1, 0, 0);
        fl.vertex(-1, -1, -1, 1, 0);
        fl.vertex(-1,  1, -1, 1, 1);
        fl.vertex( 1,  1, -1, 0, 1);

        // +Y "bottom" face
        float dim = 1500;
        fl.normal(0,1,0);
        fl.vertex(-1,  1,  1, 0, 0);
        fl.vertex( 1,  1,  1, dim, 0);
        fl.vertex( 1,  1, -1, dim,dim);
        fl.vertex(-1,  1, -1, 0, dim);

        // -Y "top" face
        fl.normal(0,-1,0);
        fl.vertex(-1, -1, -1, 0, 0);
        fl.vertex( 1, -1, -1, dim, 0);
        fl.vertex( 1, -1,  1, dim, dim);
        fl.vertex(-1, -1,  1, 0, dim);

        // +X "right" face
        fl.vertex( 1, -1,  1, 0, 0);
        fl.vertex( 1, -1, -1, 1, 0);
        fl.vertex( 1,  1, -1, 1, 1);
        fl.vertex( 1,  1,  1, 0, 1);

        // -X "left" face
        fl.vertex(-1, -1, -1, 0, 0);
        fl.vertex(-1, -1,  1, 1, 0);
        fl.vertex(-1,  1,  1, 1, 1);
        fl.vertex(-1,  1, -1, 0, 1);

        fl.endShape();
    }
    void display(PGraphics pg)
    {
        pg.pushMatrix();
        pg.scale(sx/2,sy/2,sz/2);
        pg.shape(fl);
        pg.popMatrix();
    }
}

static class ShapeUtils
{
    static boolean collideWith(PVector p1, PVector p2, float r1, float r2)
    {
        return p1.dist(p2) < r1+r2;
    }
    static PVector cylinderBounce(PVector v, PVector p1, PVector p2)
    {
        PVector n = PVector.sub(p1,p2).normalize();
        return PVector.add(v,PVector.mult(n,-2.f*PVector.dot(v,n)));
    }
    static PVector extractFromCylinder(PVector p1, PVector p2, float r1, float r2)
    {
        return PVector.sub(p1,p2).normalize().mult(r1+r2).add(p2);
    }
}