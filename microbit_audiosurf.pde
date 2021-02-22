import processing.serial.*;
import javax.sound.midi.*;
import processing.sound.*;

static int MINIMUM_INTEGER = -2147483648;


// sound specifics

static float ARTIFICIAL_MUSIC_START = 3;

static int[][] COLOR_PALETTES = {
  { #000000, #74F94C, #74F94C, #FFFFFF },
  { #FFFFFF, #000000, #000000, #000000 }
};

static float[] COLOR_CHANGE_CUES = { 18.8, 34.74, 50.8, 66.84, 82.74, 98.7, 114.86, 130.94, 146.75, 162.7, 178.8, 194.9, 198.7, 202.9, 206.8 };


/** the serial port the MicroBit is on */
Serial myPort;

SoundFile musicFile;
ArrayList<Beat> beats;
ArrayList<Integer> hitBeatIds = new ArrayList();

int beatIndex = 0;
float PATH_TRAVEL_DURATION = 2; // 1s

int colorPaletteIndex = 0;
int[] getCurrentColorPalette() {
  return COLOR_PALETTES[colorPaletteIndex];
}

void changeColorPalette() {
  int nextIndex = colorPaletteIndex + 1;
  if (nextIndex >= COLOR_PALETTES.length) {
    nextIndex = 0;
  }
  
  colorPaletteIndex = nextIndex;
}

int colorChangeCueIndex = 0;

int boardWidth;
int boardHeight;

float getBeatBarYPosition() {
  return boardHeight - 100;
}

PFont titleFont;
PFont subtitleFont;
PFont scoreFont;

int score = 0;

void setup() {
  try {
    titleFont = createFont("Frutiger-Black.otf", 100);
    subtitleFont = createFont("Frutiger-Black.otf", 40);
    scoreFont = createFont("Frutiger-Black.otf", 30);
    
    musicFile = new SoundFile(this, "supermassive-blackhole.wav");
    
    beats = loadBeatMap("supermassive-blackhole-easy-beatmap.json");
    println("Loaded " + beats.size() + " beats");
    
    myPort = getSerial();
    configureVisualizer();
    
    // musicFile.cue(202.9);
    musicFile.play();
  } catch (Exception e) {
    e.printStackTrace();
    exit();
  }
  
  size(900, 900, P3D);
  
  boardWidth = 600;
  boardHeight = 1000;
}

/** the player cursor's position in int range [1,3] */
int playerTrack = 2;

void draw() {  
  background(getCurrentColorPalette()[0]);  
  
  if (colorChangeCueIndex < COLOR_CHANGE_CUES.length &&  musicFile.position() > COLOR_CHANGE_CUES[colorChangeCueIndex]) {
    colorChangeCueIndex++;
    changeColorPalette();
  }
  
  // update passed beat index
  if (beats.size() > beatIndex && beats.get(beatIndex).time < musicFile.position() + PATH_TRAVEL_DURATION) {
    beatIndex++;
  }
  
  Boolean done = (frameCount > 1 && musicFile.position() == 0) || musicFile.position() == musicFile.duration();
  
  if (!done) {
    
    getMicroBitValues();
    
    pushMatrix();
    translate(0, 0, -400);
    drawVisualizer();
    popMatrix();
    
    pushMatrix();
     translate((width - boardWidth)/2, -50, -300);
     rotateX(PI/5);
    
    drawPlayerSprite();
    drawBeats();
    
    popMatrix();
    
    if (musicFile.position() < ARTIFICIAL_MUSIC_START) {
      push();
      float ellipseSize = map(musicFile.position(), 0, ARTIFICIAL_MUSIC_START, width, 350);
      fill(getCurrentColorPalette()[0]);
      ellipse(width/2, height/2, ellipseSize, ellipseSize);
      pop();
    }
    
    if (musicFile.position() > 1 && musicFile.position() < ARTIFICIAL_MUSIC_START - 0.25) {
      push();
      textFont(titleFont);
      textAlign(CENTER, BOTTOM);
      fill(255,255,255);
      text("SUPERMASSIVE\nBLACK HOLE", width/2, height/2 + 50); 
      
      textFont(subtitleFont);
      textAlign(CENTER, TOP);
      fill(255,255,255);
      text("MUSE", width/2, height/2 + 125); 
      pop();
    }
    
  }
  
  textFont(scoreFont);
  fill(getCurrentColorPalette()[3]);
  text(score, 10, 30); 
  
  if (done || musicFile.position() > musicFile.duration() - 5) {
    pushMatrix();
    float whiteoutOpacity = map(musicFile.position(), musicFile.duration() - 5, musicFile.duration() - 2, 0, 255);
    if (done) {
      whiteoutOpacity = 255;
    }

    push();
    fill(255, 255, 255, whiteoutOpacity);
    rectMode(CORNER);
    rect(0,0,width,height);
    pop();
    
    push();
    fill(0,0,0);
    
    textFont(subtitleFont);
    textAlign(CENTER, BOTTOM);
    text("SCORE", width/2, height/2 - 50); 
    
    textFont(titleFont);
    textAlign(CENTER);
    text(score, width/2, height/2 + 50); 
    pop();
    popMatrix();
  }
}

float xPositionFromTrack(int track) {
  return boardWidth * (track + (track - 1))/6;
}
