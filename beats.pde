int trackForbeatTargetID(String targetID) {
  int track = 3;
  if (targetID.equals("A")) {
    track = 1;
  } else if (targetID.equals("B")) {
    track = 2;
  }
  
  return track;
}

void drawBeats() {
  ArrayList<Beat> addedBeats = new ArrayList(beats.subList(0, beatIndex));
  
  for (Beat beat : addedBeats) {
    int track = trackForbeatTargetID(beat.targetID);
    float xPos = xPositionFromTrack(track);
    
    float timeElapsedSinceAdded = musicFile.position() + PATH_TRAVEL_DURATION - beat.time;
    float yPos = getBeatBarYPosition() * (timeElapsedSinceAdded / PATH_TRAVEL_DURATION);
    
    pushMatrix();
    translate(0, -50, 0);
    push();
    
    noFill();
    stroke(getCurrentColorPalette()[3]);
    strokeWeight(1.5);
    
    if (yPos >= getBeatBarYPosition() + 20 && !hitBeatIds.contains(beat.beatID)) {
      // missed
      line(xPos - 10, yPos - 10, xPos + 10, yPos + 10);
      line(xPos + 10, yPos - 10, xPos - 10, yPos + 10);
    } else {
      rectMode(CENTER);
      rect(xPos, yPos, 40, 40);
    }
    
    if (playerTrack == track && yPos >= getBeatBarYPosition() - 20 && yPos <= getBeatBarYPosition() + 20) {
      fill(getCurrentColorPalette()[3]);
      rectMode(CENTER);
      rect(xPos, yPos, 40, 40);
      
      if (!hitBeatIds.contains(beat.beatID)) {
        hitBeatIds.add(beat.beatID);
        score += 100;
      }
    }
    
    pop();
    popMatrix();
  }
}
