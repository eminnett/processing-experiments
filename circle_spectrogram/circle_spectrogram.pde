import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;
AudioPlayer in;
FFT fft;
int frame = 0;
int holeRadius = 64;
int specRadius = 256;
int graphRadius = holeRadius + specRadius;
int graphDiameter = graphRadius * 2;
int xPadding = 100;
int yPadding = 20;
int xCenter = xPadding + graphRadius;
int yCenter = yPadding + graphRadius;
int fps = 60;
Float trackFrames;
PImage graphImg = createImage(graphDiameter, graphDiameter, ARGB);


void setup() {
    // window
    frameRate(fps);
    size(xCenter*2, yCenter*2, P3D);
    background(0);
    smooth();

    // object creation
    minim = new Minim(this);
//    String fname = "/Users/edwardm/Downloads/Madeon - Pop Culture.mp3";
//    String fname = "/Users/edwardm/Downloads/11 Animals.mp3";
//    String fname = "/Users/edwardm/Downloads/06 Pick Up [Four Tet Mix Edit].mp3";
    String fname = "/Users/edwardm/Downloads/sexual healing-hot 8 brass band.mp3";
    // fft creation
    in = minim.loadFile(fname, 2048);
    in.loop();
    fft = new FFT(in.bufferSize(), in.sampleRate());
    fft.window(FFT.HAMMING);
    trackFrames = in.length() / 1000.0 * fps;
//    graphImg.loadPixels();
//    for (int i = 0; i < graphImg.pixels.length; i++) {
//      graphImg.pixels[i] = color(0, 90, 102); 
//    }
//    graphImg.updatePixels();
}


void draw() {
    background(0);
    colorMode(HSB, 255);

    fft.forward(in.mix);
    int shrink = fft.specSize() / specRadius;
    Float angle = frame/trackFrames*360;
    graphImg.loadPixels();
    for (int i = 0; i < fft.specSize() / shrink; ++i) {
        // fill in the new column of spectral values (and scale)
        int val = (int)Math.round(Math.max(0, 52 * Math.log10(1000 * fft.getBand(i))));
        int nextVal = (int)Math.round(Math.max(0, 52 * Math.log10(1000 * fft.getBand(i+1))));
//        stroke(128, 255, 255);
        stroke(255);
        line(xCenter, yCenter + holeRadius, xCenter , yCenter + graphRadius);
        line(val/20 + xCenter, yCenter + graphRadius - i, nextVal/20 + xCenter, yCenter + graphRadius - (i+1));

        int sval = Math.min(255, val);
        Float svalMod= sval - (255-sval)*1.0;
        color pointColor = color(255 - svalMod, svalMod, svalMod);
//        color pointColor = color(svalMod);
        float theta = radians(270 + angle);
        int xSpecPoint = (int)Math.min(graphDiameter, (graphRadius - i) * cos(theta) + graphRadius);
        int ySpecPoint = (int)Math.min(graphDiameter, (graphRadius - i) * sin(theta - radians(180)) + graphRadius);
        int pixIndex = Math.max(0, Math.min(graphImg.width*graphImg.height - 1, ySpecPoint*graphDiameter + xSpecPoint));
        graphImg.pixels[pixIndex] = pointColor;
    }
    graphImg.updatePixels();
    translate(xCenter, yCenter);
    rotate(radians(angle));
    translate(-xCenter*2 + xPadding, -yCenter*2 + yPadding);
    image(graphImg, xCenter, yCenter);
    ++frame;
}


void stop() {
    // always close Minim audio classes when you finish with them
    in.close();
    minim.stop();
    super.stop();
}
