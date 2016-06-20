import java.util.*;
import processing.video.*;

public final class ImageProcessing implements Runnable
{
    private PImage front = null;
    private PImage back = null;
    public PImage last_img = null;
    private PVector angularSpeed = new PVector(0,0,0);
    private PVector angularPosition = new PVector(0,0,0);
    private PVector lastRot = new PVector(0,0,0);
    private int minVotes = 80;
    public int baseHue = 113;
    public int hueRadius = 26;
    private int lastupdate = 0;
    private TwoDThreeD _2D3D = new TwoDThreeD(width,height);
    private Movie cam;
    private Thread camThread;

    /*void settings() {
    }

    void setup() {
    }

    void draw() {
    }*/

    public void initCam(int number, PApplet app)
    {
      cam = new Movie(app,"testvideo.mp4");
      println("duration = " + cam.duration());
      //cam.start();
      cam.loop();
      /*camThread = new Thread(this);
      camThread.start();*/
    }

    public PVector get3DRotation()
    {
        /*if(cam.available()) {
          cam.read();
        }
        PImage tmp = cam.get();
         last_img = tmp.copy();*/ 
        rawRotation();
        
        println("pipi");
        
        int time = millis();
        float delta_t = float(time-lastupdate)/1000;
        lastupdate = time;
        //println("time = ", delta_t);
        float k = 80;
        PVector delta = PVector.sub(lastRot,angularPosition);
        delta.mult(k*delta_t);

        angularSpeed.add(delta);
        angularSpeed.mult(delta_t);
        angularPosition.add(angularSpeed);
        return angularPosition;
    }

    public void rawRotation()
    {
        //if(cam.available()) {
            cam.read();
        //}

        println("caca");

        PImage base_img = cam.get();
        base_img.loadPixels();
        println("base width = " + base_img.width);
        //last_img = tmp.copy();
        PImage result = fullFilterImage(base_img);

        final QuadGraph qg = new QuadGraph();
        final List<PVector> lines = hough(result, 6);
        getIntersections(lines);
        qg.build(lines, base_img.width, base_img.height);
        List<int[]> quads = qg.findCycles();
        quads.sort(new Comparator<int[]>() { //Sort quad by area
            public int compare(int[] q1, int[] q2) {
                return Float.compare(
                           qg.quadArea(lines.get(q1[0]), lines.get(q1[1]), lines.get(q1[2]), lines.get(q1[3])),
                           qg.quadArea(lines.get(q2[0]), lines.get(q2[1]), lines.get(q2[2]), lines.get(q2[3])));
            }
        }
                  );


        for (int[] quad : quads) {
            PVector l1 = lines.get(quad[0]);
            PVector l2 = lines.get(quad[1]);
            PVector l3 = lines.get(quad[2]);
            PVector l4 = lines.get(quad[3]);

            PVector c12 = intersection(l1, l2);
            PVector c23 = intersection(l2, l3);
            PVector c34 = intersection(l3, l4);
            PVector c41 = intersection(l4, l1);
            if (qg.isConvex(c12, c23, c34, c41) && qg.validArea(c12, c23, c34, c41, base_img.width*base_img.height, 2000) && qg.nonFlatQuad(c12, c23, c34, c41)) {
                PVector[] parray = {c12,c23,c34,c41};
                List<PVector> final_quad = qg.sortCorners(Arrays.asList(parray));
                lastRot = _2D3D.get3DRotations(final_quad);
            }
        }
    }

    public void run()
    {
        while(true) {
            rawRotation();
            try {
            Thread.sleep(10);
            } catch(Exception e) {
            }
        }
    }

    private ArrayList<PVector> hough(PImage edgeImg, int nLines)
    {
        float discretizationStepsPhi = 0.012f;
        float discretizationStepsR = 1.25f;
        // dimensions of the accumulator
        int phiDim = (int) (Math.PI / discretizationStepsPhi);
        int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);
        // our accumulator (with a 1 pix margin around)
        int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];
        // Fill the accumulator: on edge points (ie, white pixels of the edge
        // image), store all possible (r, phi) pairs describing lines going
        // through the point.

        // pre-compute the sin and cos values
        float[] tabSin = new float[phiDim];
        float[] tabCos = new float[phiDim];
        float ang = 0;
        float inverseR = 1.f / discretizationStepsR;
        for (int phi = 0; phi < phiDim; phi++) {
            float phiFloat = phi*discretizationStepsPhi;
            // we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop
            tabSin[phi] = (float) (Math.sin(phiFloat));
            tabCos[phi] = (float) (Math.cos(phiFloat));
        }

        for (int y = 0; y < edgeImg.height; y++) {
            for (int x = 0; x < edgeImg.width; x++) {
                // Are we on an edge?
                if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
                    // ...determine here all the lines (r, phi) passing through
                    // pixel (x,y), convert (r,phi) to coordinates in the
                    // accumulator, and increment accordingly the accumulator.
                    for (int phi = 0; phi < phiDim; phi++) {
                        //float phiFloat = phi*discretizationStepsPhi;
                        //float rFloat = x*cos(phiFloat)+ y*sin(phiFloat);
                        float rFloat = x*tabCos[phi] + y*tabSin[phi];
                        int r = (int) (rFloat/discretizationStepsR);
                        r += (rDim - 1) / 2;
                        accumulator[(phi+1) * (rDim+2) + r+1] += 1;
                    }
                }
            }
        }

        /*PImage houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);
        for (int i = 0; i < accumulator.length; i++) {
            houghImg.pixels[i] = color(min(255, accumulator[i]));
        }

        //Resize the acc to see something
        houghImg.resize(height, height);
        houghImg.updatePixels();*/

        ArrayList<Integer> bestCandidates = new ArrayList<Integer>();
        // size of the region we search for a local maximum
        int neighbourhood = 30;
        // only search around lines with more that this amount of votes
        // (to be adapted to your image)
        //int minVotes = 200;
        for (int accR = 0; accR < rDim; accR++) {
            for (int accPhi = 0; accPhi < phiDim; accPhi++) {
                // compute current index in the accumulator
                int idx = (accPhi + 1) * (rDim + 2) + accR + 1;
                if (accumulator[idx] > minVotes) {
                    boolean bestCandidate=true;
                    // iterate over the neighbourhood
                    for (int dPhi=-neighbourhood/2; dPhi < neighbourhood/2+1; dPhi++) {
                        // check we are not outside the image
                        if ( accPhi+dPhi < 0 || accPhi+dPhi >= phiDim) continue;
                        for (int dR=-neighbourhood/2; dR < neighbourhood/2 +1; dR++) {
                            // check we are not outside the image
                            if (accR+dR < 0 || accR+dR >= rDim) continue;
                            int neighbourIdx = (accPhi + dPhi + 1) * (rDim + 2) + accR + dR + 1;
                            if (accumulator[idx] < accumulator[neighbourIdx]) {
                                // the current idx is not a local maximum!
                                bestCandidate=false;
                                break;
                            }
                        }
                        if (!bestCandidate) break;
                    }
                    if (bestCandidate) {
                        // the current idx *is* a local maximum
                        bestCandidates.add(idx);
                    }
                }
            }
        }

        Collections.sort(bestCandidates, new HoughComparator(accumulator));
        ArrayList<PVector> selection = new ArrayList();
        for (int i = 0; i < bestCandidates.size() && i < nLines; i++) {
            int idx = bestCandidates.get(i);
            int accPhi = (int) (idx / (rDim + 2)) - 1;
            int accR = idx - (accPhi + 1) * (rDim + 2) - 1;
            float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
            float phi = accPhi * discretizationStepsPhi;
            selection.add(new PVector(r, phi));
        }
        return selection;
    }

    PVector intersection(PVector line1, PVector line2)
    {
        float d = cos(line2.y)*sin(line1.y)-cos(line1.y)*sin(line2.y);
        float x = (line2.x*sin(line1.y)-line1.x*sin(line2.y))/d;
        float y = (-line2.x*cos(line1.y)+line1.x*cos(line2.y))/d;
        return new PVector(x, y);
    }

    ArrayList<PVector> getIntersections(List<PVector> lines)
    {
        ArrayList<PVector> intersections = new ArrayList<PVector>();
        for (int i = 0; i < lines.size() - 1; i++) {
            PVector line1 = lines.get(i);
            for (int j = i + 1; j < lines.size(); j++) {
                PVector line2 = lines.get(j);
                float d = cos(line2.y)*sin(line1.y)-cos(line1.y)*sin(line2.y);
                float x = (line2.x*sin(line1.y)-line1.x*sin(line2.y))/d;
                float y = (-line2.x*cos(line1.y)+line1.x*cos(line2.y))/d;
                intersections.add(new PVector(x, y));
            }
        }
        return intersections;
    }

    private void assertFrontBack(int w,int h)
    {
        if(front == null || back == null
           || front.width != w || back.width != w
           || front.height != h || back.height != h) {
            back = createImage(w,h,RGB);
            front = createImage(w,h,RGB);
        }
    }

    public PImage fullFilterImage(PImage base)
    {
        return fullFilterImage(base,true);
    }

    public PImage primaryFilter(PImage base) {
      return inplace_filterHueAndBrightness(base, baseHue-hueRadius, baseHue+hueRadius,45,255,34,256);
    }

    /**
    *  @brief filter all image using front and back buffer and inplace tranform to avoid creating to much images
    */
    public PImage fullFilterImage(PImage base, boolean copy)
    {
        PImage front = copy ? base.copy() : base;
        assertFrontBack(base.width,base.height);

        last_img = front;

        front = primaryFilter(front);
        front = inplace_gaussianBlur(front,8,back);
        front = inplace_threshold(front,244);
        back = inplace_sobel(front,back);
        //last_img = back.copy();
        //image(last_img,0,0);
        //delay(22);
        return back;
    }

    public color convolution(int x, int y, float[][] matrix, PImage img)
    {
        float rtotal = 0.0;
        float gtotal = 0.0;
        float btotal = 0.0;
        int xoffset = matrix.length / 2;
        int yoffset = matrix[0].length / 2;
        for (int i = 0; i < matrix.length; i++) {
            for (int j= 0; j < matrix[0].length; j++) {
                // What pixel are we testing
                int xloc = x+i-xoffset;
                int yloc = y+j-yoffset;
                int loc = xloc + img.width*yloc;
                // Make sure we haven't walked off our image, we could do better here
                loc = constrain(loc,0,img.pixels.length-1);
                // Calculate the convolution
                rtotal += (red(img.pixels[loc]) * matrix[i][j]);
                gtotal += (green(img.pixels[loc]) * matrix[i][j]);
                btotal += (blue(img.pixels[loc]) * matrix[i][j]);
            }
        }
        // Make sure RGB is within range
        rtotal = constrain(rtotal, 0, 255);
        gtotal = constrain(gtotal, 0, 255);
        btotal = constrain(btotal, 0, 255);
        // Return the resulting color
        return color(rtotal, gtotal, btotal);
    }

    public float intConv(int x, int y, float[][] matrix, PImage img)
    {
        float sum = 0;
        int xoffset = matrix.length / 2;
        int yoffset = matrix[0].length / 2;
        for (int i = 0; i < matrix.length; i++) {
            for (int j= 0; j < matrix[0].length; j++) {
                // What pixel are we testing
                int xloc = x+i-xoffset;
                int yloc = y+j-yoffset;
                int loc = xloc + img.width*yloc;
                // Make sure we haven't walked off our image, we could do better here
                loc = constrain(loc,0,img.pixels.length-1);
                // Calculate the convolution
                sum += (brightness(img.pixels[loc]) * matrix[i][j]);
            }
        }
        return sum;
    }

    public PImage inplace_sobel(PImage img, PImage result)
    {
        float[][] hKernel = { { 0, 1, 0 },
            { 0, 0, 0 },
            { 0, -1, 0 }
        };
        float[][] vKernel = { { 0, 0, 0 },
            { 1, 0, -1 },
            { 0, 0, 0 }
        };
        //PImage result = createImage(img.width, img.height, ALPHA);
        // clear the image
        for (int i = 0; i < img.width * img.height; i++) {
            result.pixels[i] = color(0);
        }
        float max=0;
        float[] buffer = new float[img.width * img.height];

        for(int x = 0; x < img.width; x++) {
            for(int y = 0; y < img.height; y++) {
                float h = intConv(x,y,hKernel,img);
                float v = intConv(x,y,vKernel,img);
                float b = sqrt(h*h+v*v);
                buffer[x+y*img.width] = b;
                max = max(max,b);
            }
        }

        for (int y = 2; y < img.height - 2; y++) { // Skip top and bottom edges
            for (int x = 2; x < img.width - 2; x++) { // Skip left and right
                if (buffer[y * img.width + x] > (int)(max * 0.3f)) { // 30% of the max
                    result.pixels[y * img.width + x] = color(255);
                } else {
                    result.pixels[y * img.width + x] = color(0);
                }
            }
        }
        return result;
    }

    public PImage inplace_convolve(PImage src, float [][] ker, PImage result)
    {
        //PImage result = createImage(src.width,src.height,RGB);
        for(int x = 0; x < src.width; x++) {
            for(int y = 0; y < src.height; y++) {
                result.pixels[x+y*src.width] = convolution(x,y,ker,src);
            }
        }
        return result;
    }

    public PImage inplace_filterHueAndBrightness(PImage image, int minHue, int maxHue, int minBright, int maxBright,int minSat, int maxSat)
    {
        //PImage result = createImage(image.width, image.height, RGB); // create a new, initially transparent, ’result’ image
        for(int i = 0; i < image.width * image.height; i++) {
            color c = image.pixels[i];
            float hue = hue(c);
            float brightness = brightness(c);
            float sat = saturation(c);
            if(minHue <= hue && maxHue >= hue && brightness < maxBright && brightness > minBright && sat > minSat && sat < maxSat) {
                image.pixels[i] = color(255);
            } else {
                image.pixels[i] = color(0);
            }
        }
        //image.updatePixels();
        return image;
    }

    public PImage inplace_threshold(PImage image, int tres)
    {
        //PImage result = createImage(image.width, image.height, RGB); // create a new, initially transparent, ’result’ image
        for(int i = 0; i < image.width * image.height; i++) {
            color c = image.pixels[i];
            if(brightness(c) < tres) {
                image.pixels[i] = color(0);
            } else {
                image.pixels[i] = color(255);
            }
        }
        return image;
    }
    
    public color mean_color(PImage img, int l,int t, int w, int h) {
      //println(l + " " + t + " " + w + " " + h);
      if(img == null) { //<>//
        return color(0,0,0);
      }
      float rtotal = 0.0;
      float gtotal = 0.0;
      float btotal = 0.0;
      for(int i = l; i < l+w; i++) {
        for(int j = t; j < t+h; j++) {
                int loc = i + img.width*j;
                rtotal += (red(img.pixels[loc]));
                gtotal += (green(img.pixels[loc]));
                btotal += (blue(img.pixels[loc]));
        }
      }
      float total = w*h;
      rtotal /= total;
      gtotal /= total;
      btotal /= total;
      rtotal = constrain(rtotal, 0, 255);
        gtotal = constrain(gtotal, 0, 255);
        btotal = constrain(btotal, 0, 255);
      return color(rtotal,gtotal,btotal);
    }

    public PImage inplace_gaussianBlur(PImage img, int kernelSize, PImage result)
    {
        //PImage result = createImage(img.width,img.height,RGB);
        float [][]hKer = new float[kernelSize][1];
        float [][]vKer = new float[1][kernelSize];
        int median = kernelSize/2;
        float a = 1.f/sqrt(kernelSize*2*PI);
        float c = 2*kernelSize;
        for(int i = 0; i < kernelSize/2; i++) {
            float x = i;
            float v = a*exp(-(x*x)/c);
            hKer[median+i][0] =v;
            vKer[0][median+i] = v;
            hKer[median-i][0] =v;
            vKer[0][median-i] = v;
        }
        //Normalise kernel
        float sum= 0;
        for(float []line : hKer) {
            for(float el : line) {
                sum += el;
            }
        }
        for(int i = 0; i < kernelSize; i++) {
            hKer[i][0] /= sum;
            vKer[0][i] /= sum;
        }

        result = inplace_convolve(img,hKer,result);
        result = inplace_convolve(result,vKer,img);
        return result;
    }
};