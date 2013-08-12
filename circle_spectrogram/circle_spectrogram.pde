import controlP5.*;
import ddf.minim.analysis.*;
import ddf.minim.*;

ControlP5 cp5;
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
Float prevAngleOverride = 0.0;
Float playAngle = 0.0;
Float angleOverride = 0.0;
Float mouseAngle = 0.0;
PImage graphImg = createImage(graphDiameter, graphDiameter, ARGB);
boolean saveGraphics = false;


void setup() {
    // window
    frameRate(fps);
    size(xCenter*2, yCenter*2, P3D);
    background(0);
    smooth();

    // object creation
    cp5 = new ControlP5(this);
    cp5.addButton("colorA")
     .setValue(0)
     .setPosition(0,0)
     .setSize(200,19)
     ;
    cp5.addButton("colorB")
     .setValue(100)
     .setPosition(0,20)
     .setSize(200,19)
     ;
    
    minim = new Minim(this);
//    String fname = "/Users/edwardm/Downloads/Madeon - Pop Culture.mp3";
//    String fname = "/Users/edwardm/Downloads/11 Animals.mp3";
    String fname = "/Users/edwardm/Downloads/06 Pick Up [Four Tet Mix Edit].mp3";
//    String fname = "/Users/edwardm/Downloads/sexual healing-hot 8 brass band.mp3";
//    String fname = "/Users/edwardminnett/Downloads/Michel Camilo (Discography)/1994 - One more once/07. Caribe.mp3";
//    String fname = "/Users/edwardminnett/Downloads/Michel Camilo (Discography)/2006 - Rhapsody in Blue/01 - Rhapsody in Blue (Gershwin).mp3";
//    String fname = "/Users/edwardminnett/Downloads/Ravel - Bolero - www.LoKoTorrents.com/01 - Bolero (Tempo Di Bolero Moderato Assai).mp3";
//    String fname = "/Users/edwardminnett/Downloads/Beethoven, Ludwig van Symphony No.5 in C minor/1 - Symphony No.5 - Allegro con brio.mp3";
    
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
    playAngle = frame/trackFrames* 2 * PI + angleOverride;
    
    stroke(255);
    line(xCenter, yCenter + holeRadius, xCenter, yCenter + graphRadius);
    if(in.isPlaying()){
        graphImg.loadPixels();
        for (int i = 0; i < fft.specSize() / shrink; ++i) {
            // fill in the new column of spectral values (and scale)
            int val = (int)Math.round(Math.max(0, 52 * Math.log10(1000 * fft.getBand(i))));
            int nextVal = (int)Math.round(Math.max(0, 52 * Math.log10(1000 * fft.getBand(i+1))));
    //        stroke(128, 255, 255);
    
            stroke(255);
            line(val/20 + xCenter, yCenter + graphRadius - i, nextVal/20 + xCenter, yCenter + graphRadius - (i+1));
    
            int sval = Math.min(255, val);
            Float svalMod= sval - (255-sval)*1.0;
            color pointColor = color(255 - svalMod, svalMod, svalMod);
    //        color pointColor = color(svalMod);
            float theta = 3 * PI / 2 + playAngle;
            int xSpecPoint = (int)Math.min(graphDiameter, (graphRadius - i) * cos(theta) + graphRadius);
            int ySpecPoint = (int)Math.min(graphDiameter, (graphRadius - i) * sin(theta - PI) + graphRadius);
            int pixIndex = Math.max(0, Math.min(graphImg.width*graphImg.height - 1, ySpecPoint*graphDiameter + xSpecPoint));
            graphImg.pixels[pixIndex] = pointColor;
        }
        graphImg.updatePixels();
    }
    translate(xCenter, yCenter);
    pushMatrix();
    rotate(playAngle);
    popMatrix();
    translate(-xCenter*2 + xPadding, -yCenter*2 + yPadding);
    image(graphImg, xCenter, yCenter);
    
    if (in.isPlaying()) {
      ++frame; 
    }
}

void mousePressed() {
    prevAngleOverride = angleOverride;
    if(in.isPlaying()) {
//      Float percentPlayed = in.position() / ( in.length() * 1.0 );
//      Float mouseAngle = percentPlayed * 2 * PI; 
//      println("current angle: " + String.valueOf(mouseAngle));
//      in.pause();
    } else {
      in.play(); 
    }
    if(saveGraphics) {
      save("images/spectrogram_"+year()+""+month()+""+day()+"_"+hour()+""+minute()+"_"+second()+""+millis()+".tif");
    }
}

void mouseDragged() {
    if(in.isPlaying()) {
        in.pause();
    }
    double xDiff = xCenter - mouseX;
    double yDiff = yCenter - mouseY;
    mouseAngle = (float)(Math.atan2(yDiff, xDiff) + PI / 2);
//    println("mouse angle: " + String.valueOf(mouseAngle));
    angleOverride = prevAngleOverride + mouseAngle;
}

void mouseReleased() {
    int skipMils = (int)((playAngle / (2*PI)) * in.length());
    in.cue(skipMils);
    println("skip in milliseconds: " + String.valueOf(skipMils));
    mouseAngle = 0.0;
    if(!in.isPlaying()) {
        in.play();
    }
}

public void controlEvent(ControlEvent theEvent) {
  println(theEvent.getController().getName());
//  n = 0;
}

// function colorA will receive changes from 
// controller with name colorA
public void colorA(int theValue) {
  println("a button event from colorA: "+theValue);
//  c1 = c2;
//  c2 = color(0,160,100);
}

// function colorB will receive changes from 
// controller with name colorB
public void colorB(int theValue) {
  println("a button event from colorB: "+theValue);
//  c1 = c2;
//  c2 = color(150,0,0);
}

void stop() {
    // always close Minim audio classes when you finish with them
    in.close();
    minim.stop();
    super.stop();
}
