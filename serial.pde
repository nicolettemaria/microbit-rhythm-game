/**
 * Gets the serial port the MicroBit is on
 */
Serial getSerial() {
  // List all the available serial ports
  String[] ports = Serial.list();
  // printArray(ports);
  
  String matchingPort = null;
  String predicate = "/dev/cu.usbmodem";
  
  for (String port : ports) {         
    if (port.indexOf(predicate) > -1) {
       matchingPort = port; 
    }
  }
  
  if (matchingPort == null) {
    throw new IllegalStateException("No serial port matched the predicate " + "\"" + predicate + "\"");
  }
  
  // Open the port you are using at the rate you want:
  return new Serial(this, matchingPort, 115200);
}

int lastXVal = 0;

/**
 * Gets outputted values (x) from the MicroBit
 */
void getMicroBitValues() {
  while (myPort.available() > 0) {
    // read line
    String[] lines = myPort.readString().split("\n");
    if (lines.length > 0) {
      String inStr = lines[0].trim();
      println(inStr);
    
      // get x serial value
      int xVal = getXOrientation(inStr);
      
      // check if x is valid
      if (xVal != MINIMUM_INTEGER) {     
        // debounce & threshold limit
        if (frameCount % 3 == 0 && abs(lastXVal - xVal) > 100) {
          // convert to range between 1 - 3
          playerTrack = Math.min(floor(map(xVal, -1023, 1023, 0, 3)) + 1, 3);
          
          lastXVal = xVal;
        }
      }
      
      // TODO: check for other values if necessary
    }
  }
}


/**
 * Gets the x accelerometer orientation
 */
int getXOrientation(String inStr) {
  String xParam = getSerialParameter("x", inStr);
  if (xParam != null) {
    try {
      return Integer.parseInt(xParam);
    } catch (NumberFormatException e) {}
  }
  
  return MINIMUM_INTEGER;
}


/**
 * gets an arbitrary serial parameter from string
 */
String getSerialParameter(String param, String inStr) {
  String paramPrefix = param + ":";
  
  String paramVal = null;
  if (inStr.length() > paramPrefix.length() && inStr.substring(0, 2).equals(paramPrefix)) {
    String paramStr = inStr.substring(inStr.indexOf(':') + 1);
    paramVal = paramStr;
  }
  
  return paramVal;
}
