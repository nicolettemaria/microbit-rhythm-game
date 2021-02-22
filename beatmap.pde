// Mapped with http://mapit.chopitvr.com

ArrayList<Beat> loadBeatMap(String filename) {
  JSONObject file = loadJSONObject(filename);
  JSONArray beats = file.getJSONArray("beats");
  
  ArrayList<Beat> parsedBeats = new ArrayList();
  
  for (int i = 0; i < beats.size(); i++) {
    JSONObject beat = beats.getJSONObject(i); 

    float time = beat.getFloat("time");
    String targetID = beat.getString("targetID");
    int beatID = beat.getInt("beatID");
    
    parsedBeats.add(new Beat(time, targetID, beatID));
  }
  
  return parsedBeats;
}

class Beat {
  float time;
  String targetID;
  int beatID;
    
  Beat(float time, String targetID, int beatID) {
    this.time = time;
    this.targetID = targetID;
    this.beatID = beatID;
  }
}
