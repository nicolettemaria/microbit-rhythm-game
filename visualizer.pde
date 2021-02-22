// With code adapted from Daniel Shiffman and Codrops tutorials.

Amplitude amp;
FFT fft;
Amplitude analyzer;

int pieces;
float radius;
float mapMouseX, mapMouseY;

int bands = 512;
float[] spectrum = new float[bands];

void configureVisualizer() {
    analyzer = new Amplitude(this);
    analyzer.input(musicFile);
    
    fft = new FFT(this);
    fft.input(musicFile);
    
    amp = new Amplitude(this);
    amp.input(musicFile);
}

void drawVisualizer() {
  pushMatrix();
  push();
  
  int vizWidth = width;
  int vizHeight = height;

  translate(vizWidth / 2, vizHeight / 2);

  float level = analyzer.analyze();
  fft.analyze(spectrum);

  float treble = getEnergy(150, 250);
  float bass = getEnergy(60, 250);
  float mid = getEnergy(500, 2000);

  float mapMid = map(mid, 0, 255, -100, 200);
  float scaleTreble = map(treble, 0, 255, 0, 1);
  float mapbass = map(bass, 0, 255, 50, 200) * 2;

  mapMouseX = map(mouseX, 0, width, 15, 50);
  float mapMouseXbass = map(mouseY, 0, width, 1, 5);
  mapMouseY = map(mouseY, 0, height, 2, 6);

  pieces = 20;
  radius = 100;

  for (float i = 0; i < pieces; i += 0.1) {

    rotate(TWO_PI / (pieces / 2));

    noFill();
    
    float vol = amp.analyze();
    float diam = map(vol, 0, 0.3, 10, 200);

    if (musicFile.position() >= ARTIFICIAL_MUSIC_START) {
      // foreground triangles
      pushMatrix();
      translate(0,0,60);
      push();
      stroke(getCurrentColorPalette()[2]);
      rotate(frameCount * 0.002);
      strokeWeight(0.5);
      drawPolygon(diam/2 + i, diam/2 - i, 1.05 * i, 3);
      pop();
      popMatrix();
    }

    // background triangles
    pushMatrix();
    push();
    
    if (musicFile.position() < ARTIFICIAL_MUSIC_START) {
      scale(map(musicFile.position(), 0, ARTIFICIAL_MUSIC_START, 1.4, 1));
    }
    
    stroke(getCurrentColorPalette()[1]);
    strokeWeight(0.2);
    drawPolygon(mapMid + i / 2, mapMid - i * 2, 20 * i, 7);
    pop();
    popMatrix();

    // black hole
    pushMatrix();
    translate(0, 0, 20);
    push();
    noStroke();
    fill(getCurrentColorPalette()[0]);

    float blackHoleSize = diam;
    if (musicFile.position() < ARTIFICIAL_MUSIC_START) {
      blackHoleSize = 450;
    }

    ellipse(0, 0, blackHoleSize, blackHoleSize);
    pop();
    popMatrix();

    radius = vizHeight / 4;

    // circles
    pushMatrix();
    translate(0, 0, 40);
    push();
    stroke(getCurrentColorPalette()[3]);
    strokeWeight(15);
    scale(scaleTreble);
    rotate(frameCount * 0.01);
    point(100, diam * 2);
    point(-25, diam * 1.5);
    pop();
    popMatrix();

  }

  pop();
  popMatrix();
}

int freq2Index(int freq) {
  return (int) (freq / (musicFile.sampleRate() / bands / 2.0));
}

float getEnergy(int start, int end) {
  int normalizedStart = freq2Index(start);
  int normalizedEnd = freq2Index(end);
  
  float result;
  
  if (normalizedStart == normalizedEnd) {
    result = spectrum[normalizedStart];
  } else {
    float sum = 0;
    for (int i = normalizedStart; i < normalizedEnd; i++) {
      sum += spectrum[i];
    }
    result = (sum/(normalizedEnd - normalizedStart));
  }
    
  return map(result, 0, 1, 0, 255);
}


void drawPolygon(float x, float y, float radius, int npoints) {
    float angle = TWO_PI / npoints;
    beginShape();
    for (float a = 0; a < TWO_PI; a += angle) {
        float sx = x + cos(a) * radius;
        float sy = y + sin(a) * radius;
        vertex(sx, sy);
    }
    endShape(CLOSE);
}
