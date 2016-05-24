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