import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;
AudioPlayer in;
FFT fft;
int frame = 0;
int radius = 256;
int colmax;
int rowmax = radius;


void setup() {
    // window
    size(radius*2, radius*2, P3D);
    background(0);
    smooth();

    // object creation
    minim = new Minim(this);
    String fname = "/Users/edwardm/Downloads/Madeon - Pop Culture.mp3";

    // fft creation
    in = minim.loadFile(fname, 2048);
    in.loop();
    fft = new FFT(in.bufferSize(), in.sampleRate());
    fft.window(FFT.HAMMING);
}


void draw() {
//  background(0);
    colorMode(HSB, 255);
    // stroke(255);

    fft.forward(in.mix);
    int shrink = fft.specSize() / radius;
    for (int i = 0; i < fft.specSize() / shrink; ++i) {
        // fill in the new column of spectral values (and scale)
        int val = (int)Math.round(Math.max(0, 52 * Math.log10(1000 * fft.getBand(i))));
        int nextVal = (int)Math.round(Math.max(0, 52 * Math.log10(1000 * fft.getBand(i+1))));
//        line(radius, radius,radius , radius*2);
//        line(val/10 + radius, radius*2 - i,nextVal/10 + radius , radius*2 -(i+1));

        int sval = Math.min(255, val);
        stroke(255 - sval, sval, sval);
        float theta = radians(270 - frame/30000.0*360);
        point((radius - i)*cos(theta) + radius, (radius - i)*sin(theta + radians(180)) + radius);
    }

    ++frame;
}


void stop() {
    // always close Minim audio classes when you finish with them
    in.close();
    minim.stop();
    super.stop();
}