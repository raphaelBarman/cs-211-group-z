import processing.video.*;
import java.util.*;
Capture cam;

int minVotes = 80;
int baseHue = 117;
int hueRadius = 28;

PImage base_img;
PImage result; // create a new, initially transparent, ’result’ image

void settings()
{
    size(1650, 450);
}
void setup()
{
    //String[] cameras = Capture.list();
    //if (cameras.length == 0) {
    //   println("There are no cameras available for capture.");
    //   exit();
    //} else {
    //   println("Available cameras:");
    //   for (int i = 0; i < cameras.length; i++) {
    //       println("index: "+ i+ " = " + cameras[i]);
    //   }
    //   cam = new Capture(this, cameras[3]);
    //   cam.start();
    //}

    base_img = loadImage("board1.jpg");
    base_img.resize(600,450);
    println("width : " + base_img.width + " height: " + base_img.height);
    noLoop(); // no interactive behaviour: draw() will be called only once.
    result = filterHueAndBrightness(base_img, 87, 140,24,244,46,256);
    //result = filterHueAndBrightness(base_img,baseHue-hueRadius,baseHue+hueRadius,31,143);
    result = gaussianBlur(result,4);
    result = threshold(result,244);
    result = sobel(result);
}


void draw()
{
    //if (cam.available() == true) {
    //    cam.read();
    //}
    //base_img = cam.get();
    // result = filterHueAndBrightness(base_img, 87, 140, 30,250,50,256);
    //result = gaussianBlur(result,12);
    //result = threshold(result,180);
    //result = sobel(result);
//    image(result,0,0);
    image(base_img, 0, 0);
    image(result,600+height,0);
    final QuadGraph qg = new QuadGraph();
    final List<PVector> lines = hough(result,6);
    getIntersections(lines);
    qg.build(lines,base_img.width,base_img.height);
    List<int[]> quads = qg.findCycles();
    quads.sort(new Comparator<int[]>() {
        public int compare(int[] q1, int[] q2) {
            return Float.compare(
                       qg.quadArea(lines.get(q1[0]),lines.get(q1[1]),lines.get(q1[2]),lines.get(q1[3])),
                       qg.quadArea(lines.get(q2[0]),lines.get(q2[1]),lines.get(q2[2]),lines.get(q2[3])));
        }
    });
    for (int[] quad : quads) {
        PVector l1 = lines.get(quad[0]);
        PVector l2 = lines.get(quad[1]);
        PVector l3 = lines.get(quad[2]);
        PVector l4 = lines.get(quad[3]);
        // (intersection() is a simplified version of the
        // intersections() method you wrote last week, that simply
        // return the coordinates of the intersection between 2 lines)
        PVector c12 = intersection(l1, l2);
        PVector c23 = intersection(l2, l3);
        PVector c34 = intersection(l3, l4);
        PVector c41 = intersection(l4, l1);
        if(qg.isConvex(c12,c23,c34,c41) && qg.validArea(c12,c23,c34,c41,base_img.width*base_img.height,5000) && qg.nonFlatQuad(c12,c23,c34,c41)) {
            // Choose a random, semi-transparent colour
            Random random = new Random();
            fill(color(min(255, random.nextInt(300)),
                       min(255, random.nextInt(300)),
                       min(255, random.nextInt(300)), 50));
            noStroke();
            fill(255, 128, 0);
            ellipse(c12.x,c12.y,10,10);
            ellipse(c23.x,c23.y,10,10);
            ellipse(c34.x,c34.y,10,10);
            ellipse(c41.x,c41.y,10,10);
            stroke(255, 128, 0);
            line(c12.x,c12.y,c23.x,c23.y);
            line(c23.x,c23.y,c34.x,c34.y);
            line(c34.x,c34.y,c41.x,c41.y);
            line(c41.x,c41.y,c12.x,c12.y);
            return;
            //quad(c12.x,c12.y,c23.x,c23.y,c34.x,c34.y,c41.x,c41.y);
        }
    }
    //getIntersections(hough(result,4));
}

color convolution(int x, int y, float[][] matrix, PImage img)
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

float intConv(int x, int y, float[][] matrix, PImage img)
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

PImage sobel(PImage img)
{
    float[][] hKernel = { { 0, 1, 0 },
        { 0, 0, 0 },
        { 0, -1, 0 }
    };
    float[][] vKernel = { { 0, 0, 0 },
        { 1, 0, -1 },
        { 0, 0, 0 }
    };
    PImage result = createImage(img.width, img.height, ALPHA);
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

PImage convolve(PImage src, float [][] ker)
{
    PImage result = createImage(src.width,src.height,RGB);
    for(int x = 0; x < src.width; x++) {
        for(int y = 0; y < src.height; y++) {
            result.pixels[x+y*src.width] = convolution(x,y,ker,src);
        }
    }
    return result;
}

PImage filterHueAndBrightness(PImage image, int minHue, int maxHue, int minBright, int maxBright,int minSat, int maxSat)
{
    PImage result = createImage(image.width, image.height, RGB); // create a new, initially transparent, ’result’ image
    for(int i = 0; i < image.width * image.height; i++) {
        color c = image.pixels[i];
        float hue = hue(c);
        float brightness = brightness(c);
        float sat = saturation(c);
        if(minHue <= hue && maxHue >= hue && brightness < maxBright && brightness > minBright && sat > minSat && sat < maxSat) {
            result.pixels[i] = color(255);
        } else {
            result.pixels[i] = color(0);
        }
    }
    result.updatePixels();
    return result;
}

PImage threshold(PImage image, int tres)
{
    PImage result = createImage(image.width, image.height, RGB); // create a new, initially transparent, ’result’ image
    for(int i = 0; i < image.width * image.height; i++) {
        color c = image.pixels[i];
        if(brightness(c) < tres) {
            result.pixels[i] = color(0);
        } else {
            result.pixels[i] = color(255);
        }
    }
    return result;
}

PImage gaussianBlur(PImage img, int kernelSize)
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

    result = convolve(img,hKer);
    result = convolve(result,vKer);
    return result;
}


ArrayList<PVector> hough(PImage edgeImg,int nLines)
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
    for(int phi = 0; phi < phiDim; phi++) {
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
                for(int phi = 0; phi < phiDim; phi++) {
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

    PImage houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);
    for (int i = 0; i < accumulator.length; i++) {
        houghImg.pixels[i] = color(min(255, accumulator[i]));
    }
    // You may want to resize the accumulator to make it easier to see:
    houghImg.resize(height, height);
    houghImg.updatePixels();
    image(houghImg,600,0);

    ArrayList<Integer> bestCandidates = new ArrayList<Integer>();
    //for (int idx = 0; idx < accumulator.length; idx++) {
    //    if (accumulator[idx] > minVotes) {
    //      bestCandidates.add(idx);
    //    }
    //  }
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
                for(int dPhi=-neighbourhood/2; dPhi < neighbourhood/2+1; dPhi++) {
// check we are not outside the image
                    if( accPhi+dPhi < 0 || accPhi+dPhi >= phiDim) continue;
                    for(int dR=-neighbourhood/2; dR < neighbourhood/2 +1; dR++) {
                        // check we are not outside the image
                        if(accR+dR < 0 || accR+dR >= rDim) continue;
                        int neighbourIdx = (accPhi + dPhi + 1) * (rDim + 2) + accR + dR + 1;
                        if(accumulator[idx] < accumulator[neighbourIdx]) {
// the current idx is not a local maximum!
                            bestCandidate=false;
                            break;
                        }
                    }
                    if(!bestCandidate) break;
                }
                if(bestCandidate) {
// the current idx *is* a local maximum
                    bestCandidates.add(idx);
                }
            }
        }
    }


    Collections.sort(bestCandidates, new HoughComparator(accumulator));
    ArrayList<PVector> selection = new ArrayList();
    for(int i = 0; i < bestCandidates.size() && i < nLines; i++) {
        int idx = bestCandidates.get(i);
        int accPhi = (int) (idx / (rDim + 2)) - 1;
        int accR = idx - (accPhi + 1) * (rDim + 2) - 1;
        float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
        float phi = accPhi * discretizationStepsPhi;
        selection.add(new PVector(r,phi));
        int x0 = 0;
        int y0 = (int) (r / sin(phi));
        int x1 = (int) (r / cos(phi));
        int y1 = 0;
        int x2 = edgeImg.width;
        int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
        int y3 = edgeImg.width;
        int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));

//        stroke(204,102,0);
//        if (y0 > 0) {
//          if (x1 > 0)
//              line(x0, y0,
//                   x1, y1);
//          else if (y2 > 0)
//              line(x0, y0,
//                   x2, y2);
//          else
//              line(x0, y0,
//                   x3, y3);
//        } else {
//          if (x1 > 0) {
//              if (y2 > 0)
//                  line(x1,
//                       y1, x2, y2);
//              else
//                  line(x1,
//                       y1, x3, y3);
//          } else
//              line(x2, y2,
//                   x3, y3);
//        }
    }
    return selection;
}
PVector intersection(PVector line1, PVector line2)
{
    float d = cos(line2.y)*sin(line1.y)-cos(line1.y)*sin(line2.y);
    float x = (line2.x*sin(line1.y)-line1.x*sin(line2.y))/d;
    float y = (-line2.x*cos(line1.y)+line1.x*cos(line2.y))/d;
    return new PVector(x,y);
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
            intersections.add(new PVector(x,y));
            // compute the intersection and add it to ’intersections’
            // draw the intersection
            //fill(255, 128, 0);
            //ellipse(x, y, 10, 10);
        }
    }
    return intersections;
}