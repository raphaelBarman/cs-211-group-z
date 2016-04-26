import processing.video.*;
Capture cam;

PImage base_img;
PImage result; // create a new, initially transparent, ’result’ image

void settings()
{
    size(640, 480);
}
void setup()
{
    String[] cameras = Capture.list();
    if (cameras.length == 0) {
        println("There are no cameras available for capture.");
        exit();
    } else {
        println("Available cameras:");
        for (int i = 0; i < cameras.length; i++) {
            println("index: "+ i+ " = " + cameras[i]);
        }
        cam = new Capture(this, cameras[3]);
        cam.start();
    }

    //base_img = loadImage("board1.jpg");
    //noLoop(); // no interactive behaviour: draw() will be called only once.
    //result = filterHueAndBrightness(base_img,84,140,50,150);
    //result = gaussianBlur(result,32);
    //result = threshold(result,220);
    //result = sobel(result);
    println("Sobel done");
    //result = hough(result);
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
    /*for (int i = 0; i < img.width * img.height; i++) {
      result.pixels[i] = color(0);
    }*/
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

PImage filterHueAndBrightness(PImage image, int minHue, int maxHue, int minBright, int maxBright)
{
    PImage result = createImage(width, height, RGB); // create a new, initially transparent, ’result’ image
    for(int i = 0; i < image.width * image.height; i++) {
        color c = image.pixels[i];
        float hue = hue(c);
        float brightness = brightness(c);
        if(minHue <= hue && maxHue >= hue && brightness < maxBright && brightness > minBright) {
            result.pixels[i] = color(255);
        } else {
            result.pixels[i] = color(0);
        }
    }
    return result;
}

PImage threshold(PImage image, int tres)
{
    PImage result = createImage(width, height, RGB); // create a new, initially transparent, ’result’ image
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

void draw()
{
    if (cam.available() == true) {
        cam.read();
    }
    base_img = cam.get();
//image(base_img , 0, 0);
    result = filterHueAndBrightness(base_img,80,160,50,150);
    result = gaussianBlur(result,18);
    result = threshold(result,180);
    result = sobel(result);

    image(result , 0, 0);
    hough(result);
}

void hough(PImage edgeImg)
{
    float discretizationStepsPhi = 0.06f;
    float discretizationStepsR = 2.5f;
    // dimensions of the accumulator
    int phiDim = (int) (Math.PI / discretizationStepsPhi);
    int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);
    // our accumulator (with a 1 pix margin around)
    int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];
    // Fill the accumulator: on edge points (ie, white pixels of the edge
    // image), store all possible (r, phi) pairs describing lines going
    // through the point.
    for (int y = 0; y < edgeImg.height; y++) {
        for (int x = 0; x < edgeImg.width; x++) {
            // Are we on an edge?
            if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
                // ...determine here all the lines (r, phi) passing through
                // pixel (x,y), convert (r,phi) to coordinates in the
                // accumulator, and increment accordingly the accumulator.
                for(int phi = 0; phi < phiDim; phi++) {
                    float phiFloat = phi*discretizationStepsPhi;
                    float rFloat = x*cos(phiFloat) + y*sin(phiFloat);
                    int r = (int) (rFloat/discretizationStepsR);
                    r += (rDim - 1) / 2;
                    accumulator[(phi+1) * (rDim+2) + r+1] += 1;

                }
            }
        }
    }
    for (int idx = 0; idx < accumulator.length; idx++) {
        if (accumulator[idx] > 190) {
            int accPhi = (int) (idx / (rDim + 2)) - 1;
            int accR = idx - (accPhi + 1) * (rDim + 2) - 1;
            float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
            float phi = accPhi * discretizationStepsPhi;
            int x0 = 0;
            int y0 = (int) (r / sin(phi));
            int x1 = (int) (r / cos(phi));
            int y1 = 0;
            int x2 = edgeImg.width;
            int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
            int y3 = edgeImg.width;
            int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));

            stroke(204,102,0);
            if (y0 > 0) {
                if (x1 > 0)
                    line(x0, y0,
                         x1, y1);
                else if (y2 > 0)
                    line(x0, y0,
                         x2, y2);
                else
                    line(x0, y0,
                         x3, y3);
            } else {
                if (x1 > 0) {
                    if (y2 > 0)
                        line(x1,
                             y1, x2, y2);
                    else
                        line(x1,
                             y1, x3, y3);
                } else
                    line(x2, y2,
                         x3, y3);
            }

            //}
            //PImage houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);
            //println("rDim = " + rDim + " phiDim = " + phiDim);
            //for (int i = 0; i < accumulator.length; i++) {
            //houghImg.pixels[i] = color(min(255, accumulator[i]));
            //}
            //// You may want to resize the accumulator to make it easier to see:
            //houghImg.resize(400, 400);
            //houghImg.updatePixels();
            //image(houghImg,0,0);
            //return houghImg;

        }
    }
}