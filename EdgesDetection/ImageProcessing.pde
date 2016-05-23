public final class ImageProcessing{
  private PImage front = null;
  private PImage back = null;
  
  private void assertFrontBack(int w,int h) {
    if(front == null || back == null
    || front.width != w || back.width != w
    || front.height != h || back.height != h) {
      back = createImage(w,h,RGB);
      front = createImage(w,h,RGB);
    }
  }
  
  public PImage fullFilterImage(PImage base) { return fullFilterImage(base,true);}
  
  /**
  *  @brief filter all image using front and back buffer and inplace tranform to avoid creating to much images
  */
  public PImage fullFilterImage(PImage base, boolean copy) {
    PImage front = copy ? base.copy() : base;
    assertFrontBack(base.width,base.height);
    
    front = inplace_filterHueAndBrightness(front, 87, 140,45,255,34,256);
    front = inplace_gaussianBlur(front,8,back);
    front = inplace_threshold(front,244);
    back = inplace_sobel(front,back);
    
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
      image.updatePixels();
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