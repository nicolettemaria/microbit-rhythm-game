float lastPlayerXPos = xPositionFromTrack(2);
void drawPlayerSprite() {  
  float xPos = xPositionFromTrack(playerTrack);
  
  float lerpedXPos = lerp(lastPlayerXPos, xPos, 0.15);
  lastPlayerXPos = lerpedXPos;
  
  pushMatrix();
  translate(0, -50, 0);
  push();
   
  if (lerpedXPos >= xPos - 40 && lerpedXPos <= xPos + 40) {
    fill(getCurrentColorPalette()[3]);
    ellipse(lerpedXPos, getBeatBarYPosition(), 20, 20);
  } else {
    stroke(getCurrentColorPalette()[3]);
    strokeWeight(3);
    line(lerpedXPos - 10, getBeatBarYPosition(), lerpedXPos + 10, getBeatBarYPosition());
  }
  
  pop();
  popMatrix();
}
