// Code written by Dakssh Bhambre
// Licensed under the MIT Open Source License
// You are free to use, modify, and distribute this code 
// as long as proper credit is given to the original author.
// Github - https://github.com/DaksshDev
// Portfolio - https://daksshbhambre.netlify.app/ 
// YT - https://www.youtube.com/@DaksshDev 

// NOTE: TESTER 1(a) should be plugged in COM4 (refer- Ardruino IDE)
// 

import processing.serial.*;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.ArrayList;

Serial myPort;
int rawConductivity = 0;
float conductivitySm = 0; // Conductivity in S/m
ArrayList<String> logs = new ArrayList<String>();
ArrayList<SavedReading> savedReadings = new ArrayList<SavedReading>(); // Store saved readings
ArrayList<Integer> graphData = new ArrayList<Integer>(); // Store data for graph
PFont sfProFont;
boolean showInputField = false;
String inputText = "";
int frozenRawConductivity = 0;
float frozenConductivitySm = 0;
int savedSamplesScrollPosition = 0;
boolean showDeleteConfirmation = false;

// Original panel height for recent readings
int recentReadingsHeight = 210;
// Increased panel height for saved samples
int savedSamplesHeight = 500; // Increased from 210 to 500

// Graph dimensions
int graphWidth = 600; // Adjusted width to fit between panels
int graphHeight = 100;

// Class to store saved readings
class SavedReading {
  String name;
  float value;
  
  SavedReading(String name, float value) {
    this.name = name;
    this.value = value;
  }
}

void setup() {
  fullScreen();
  smooth(8);
  textAlign(CENTER, CENTER);
  
  // Set correct COM port or else it will die
  myPort = new Serial(this, "COM4", 9600);
  myPort.bufferUntil('\n');
  
  // Load font
  sfProFont = createFont("Arial", 32);
  textFont(sfProFont);
  
  // Initialize graph with zeros
  for (int i = 0; i < graphWidth; i++) {
    graphData.add(0);
  }
}

void draw() {
  // bg
  background(0);
  
  // Add centered graph overlay at the bottom
  drawGraphOverlay();
  
  // different components
  drawMainDisplay();
  drawLogPanel();
  drawTimeDisplay();
  drawSavedReadingsPanel();
  
  // Draw save button (now a simple iOS-style text link)
  drawSaveButton();
  
  // Draw input field for naming saved readings
  if (showInputField) {
    drawInputField();
  }
  
  // Draw delete confirmation overlay
  if (showDeleteConfirmation) {
    drawDeleteConfirmation();
  }
}

void drawGraphOverlay() {
  // Update graph data with current reading
  if (graphData.size() >= graphWidth) {
    graphData.remove(0);
  }
  graphData.add(rawConductivity);
  
  // Calculate the centered position
  int startX = (width - graphWidth) / 2;
  int startY = height - graphHeight - 10; // 10px padding from bottom
  
  // No background - transparent overlay
  
  // Draw grid lines with low opacity
  strokeWeight(1);
  stroke(100, 40);
  for (int i = 0; i <= 4; i++) {
    float y = map(i, 0, 4, startY + graphHeight, startY);
    line(startX, y, startX + graphWidth, y);
    
    // Add labels for grid lines
    fill(150, 80);
    textSize(10);
    textAlign(LEFT);
    int labelValue = int(map(i, 0, 4, 0, 1023));
    text(labelValue, startX + 5, y - 5);
  }
  
  // Draw vertical lines
  for (int i = 0; i <= 5; i++) {
    float x = map(i, 0, 5, startX, startX + graphWidth);
    line(x, startY, x, startY + graphHeight);
  }
  
  // Draw graph title
  fill(150, 120);
  textAlign(LEFT);
  textSize(12);
  text("CONDUCTIVITY OVER TIME", startX, startY - 10);
  
  // Draw graph lines with gradient based on conductivity level
  strokeWeight(2);
  noFill();
  beginShape();
  for (int i = 0; i < graphData.size(); i++) {
    int value = graphData.get(i);
    float x = map(i, 0, graphData.size() - 1, startX, startX + graphWidth);
    float y = map(value, 0, 1023, startY + graphHeight, startY);
    
    // Set color based on conductivity level with transparency
    color lineColor = getConductivityColor(value);
    stroke(red(lineColor), green(lineColor), blue(lineColor), 180);
    vertex(x, y);
  }
  endShape();
  
  // Reset text alignment
  textAlign(CENTER);
}

void drawMainDisplay() {
  noStroke();
  
  // Title
  fill(255);
  textSize(20);
  text("CONDUCTIVITY", width/2, height/2 - 170);
  
  // Main value with large display
  int displayValue = showInputField ? frozenRawConductivity : rawConductivity;
  color levelColor = getConductivityColor(displayValue);
  fill(levelColor);
  textSize(120);
  text(displayValue, width/2, height/2 - 30);
  
  // Raw units label
  fill(100);
  textSize(14);
  text("RAW VALUE (0-1023)", width/2, height/2 + 20);
  
  // Converted value
  float displayConductivity = showInputField ? frozenConductivitySm : conductivitySm;
  fill(180);
  textSize(24);
  text(nf(displayConductivity, 0, 2) + " S/m", width/2, height/2 + 60);
  
  // Status label with oval shape
  drawStatusPill(getConductivityStatus(displayValue), levelColor);
}

void drawStatusPill(String status, color pillColor) {
  // pill button
  noStroke();
  fill(pillColor, 30);
  rectMode(CENTER);
  rect(width/2, height/2 + 120, 160, 50, 25);
  
  // Status text
  fill(pillColor);
  textSize(20);
  text(status, width/2, height/2 + 120);
  rectMode(CORNER);
}

void drawLogPanel() {
  // i will draw the panel - KEEPING ORIGINAL HEIGHT
  fill(20);
  noStroke();
  rect(0, height - recentReadingsHeight, 300, recentReadingsHeight);
  
  // readings header
  fill(100);
  textAlign(LEFT);
  textSize(14);
  text("RECENT READINGS", 20, height - recentReadingsHeight + 25);
  
  // Minimal divider
  stroke(40);
  strokeWeight(1);
  line(20, height - recentReadingsHeight + 40, 280, height - recentReadingsHeight + 40);
  
  // DEFINITELY NOT SIMPLE list of readings
  noStroke();
  float yPos = height - recentReadingsHeight + 65;
  
  for (int i = logs.size() - 1; i >= 0; i--) {
    String logEntry = logs.get(i);
    String[] parts = logEntry.split(" → ");
    String timestamp = parts[0];
    String rawValue = parts[1];
    String convertedValue = parts[2];
    
    // Time fuckery
    fill(120);
    textAlign(LEFT);
    textSize(14);
    text(timestamp, 20, yPos);
    
    // Raw value with color indicator
    int value = int(rawValue);
    fill(getConductivityColor(value));
    textAlign(RIGHT);
    textSize(16);
    text(rawValue, 280, yPos);
    
    // Converted to s/m
    fill(80);
    textSize(12);
    text(convertedValue + " S/m", 280, yPos + 15);
    
    yPos += 40;
  }
  
  textAlign(CENTER);
}

void drawTimeDisplay() {
  // time display with simple AM/PM format
  fill(180);
  textAlign(RIGHT);
  
  // Simple AM/PM format
  SimpleDateFormat timeFormatSimple = new SimpleDateFormat("h:mm a");
  textSize(16);
  text(timeFormatSimple.format(new Date()), width - 20, 30);
  
  textAlign(CENTER);
}

// Draw panel for saved readings in bottom right with scrolling - NOW TALLER
void drawSavedReadingsPanel() {
  // Panel background - INCREASED HEIGHT
  fill(20);
  noStroke();
  rect(width - 300, height - savedSamplesHeight, 300, savedSamplesHeight);
  
  // Clip the content to the panel (adjusted for new height)
  pushMatrix();
  beginShape(QUAD);
  texture(get(width - 299, height - savedSamplesHeight + 41, 298, savedSamplesHeight - 45));
  vertex(width - 299, height - savedSamplesHeight + 41, 0, 0);
  vertex(width - 1, height - savedSamplesHeight + 41, 298, 0);
  vertex(width - 1, height - 4, 298, savedSamplesHeight - 45);
  vertex(width - 299, height - 4, 0, savedSamplesHeight - 45);
  endShape();
  popMatrix();
  
  // Panel header
  fill(100);
  textAlign(LEFT);
  textSize(14);
  text("SAVED SAMPLES", width - 280, height - savedSamplesHeight + 25);
  
  // Add small delete button (trash icon)
  fill(80);
  textSize(10);
  text("×", width - 30, height - savedSamplesHeight + 25);
  noFill();
  stroke(80);
  strokeWeight(1);
  rect(width - 38, height - savedSamplesHeight + 18, 16, 14, 2);
  
  // Minimal divider
  stroke(40);
  strokeWeight(1);
  line(width - 280, height - savedSamplesHeight + 40, width - 20, height - savedSamplesHeight + 40);
  
  // List of saved readings with scrolling
  noStroke();
  float yPos = height - savedSamplesHeight + 65 + savedSamplesScrollPosition;
  
  // Draw scroll indicators if there are enough items (adjusted for new height)
  int visibleItems = (savedSamplesHeight - 85) / 30; // Calculate how many items fit
  if (savedReadings.size() > visibleItems) {
    // Draw up indicator if not at top
    if (savedSamplesScrollPosition < 0) {
      fill(100);
      triangle(width - 20, height - savedSamplesHeight + 55, width - 15, height - savedSamplesHeight + 45, width - 10, height - savedSamplesHeight + 55);
    }
    
    // Draw down indicator if not at bottom
    int maxScroll = -((savedReadings.size() - visibleItems) * 30);
    if (savedSamplesScrollPosition > maxScroll) {
      fill(100);
      triangle(width - 20, height - 20, width - 15, height - 10, width - 10, height - 20);
    }
  }
  
  for (int i = 0; i < savedReadings.size(); i++) {
    // Only draw visible items
    if (yPos >= height - savedSamplesHeight + 45 && yPos <= height - 5) {
      SavedReading reading = savedReadings.get(i);
      
      // Sample name
      fill(180);
      textAlign(LEFT);
      textSize(16);
      text(reading.name, width - 280, yPos);
      
      // Conductivity value
      color valueColor = getConductivityColorFromSm(reading.value);
      fill(valueColor);
      textAlign(RIGHT);
      textSize(16);
      text(nf(reading.value, 0, 2) + " S/m", width - 20, yPos);
    }
    
    yPos += 30;
  }
  
  textAlign(CENTER);
}

// Draw save button - now a simple iOS-style text link
void drawSaveButton() {
  color iosBlue = color(0, 122, 255); // iOS blue
  fill(iosBlue);
  textSize(16);
  text("Save Sample", width/2, height/2 + 180);
}

// Draw input field for sample naming - now with improved UI
void drawInputField() {
  // Dim background
  fill(0, 180);
  rect(0, 0, width, height);
  
  // Dialog box with subtle shadow
  fill(40);
  noStroke();
  rectMode(CENTER);
  rect(width/2 + 4, height/2 + 4, 404, 204, 20);
  fill(30);
  rect(width/2, height/2, 400, 200, 20);
  
  // Current reading display
  color valueColor = getConductivityColor(frozenRawConductivity);
  fill(valueColor, 100);
  rect(width/2, height/2 - 60, 300, 50, 10);
  
  fill(valueColor);
  textSize(22);
  text(nf(frozenConductivitySm, 0, 2) + " S/m", width/2, height/2 - 60);
  
  // Title
  fill(220);
  textSize(18);
  text("Name this sample", width/2, height/2 - 100);
  
  // Input field background with subtle outline
  fill(45);
  stroke(60);
  strokeWeight(1);
  rect(width/2, height/2, 300, 40, 10);
  
  // Input text with cursor
  noStroke();
  fill(255);
  textSize(16);
  textAlign(LEFT);
  text(inputText + (frameCount % 60 < 30 ? "|" : ""), width/2 - 140, height/2);
  textAlign(CENTER);
  
  // Buttons - iOS style text buttons
  color iosBlue = color(0, 122, 255);
  fill(iosBlue);
  textSize(16);
  text("Save", width/2 - 70, height/2 + 60);
  
  fill(180);
  text("Cancel", width/2 + 70, height/2 + 60);
  
  rectMode(CORNER);
}

// Draw delete confirmation dialog
void drawDeleteConfirmation() {
  // Dim background
  fill(0, 180);
  rect(0, 0, width, height);
  
  // Dialog box with subtle shadow
  fill(40);
  noStroke();
  rectMode(CENTER);
  rect(width/2 + 4, height/2 + 4, 304, 154, 20);
  fill(30);
  rect(width/2, height/2, 300, 150, 20);
  
  // Warning title
  fill(255, 59, 48); // iOS red
  textSize(18);
  text("Delete All Samples?", width/2, height/2 - 50);
  
  // Warning message
  fill(200);
  textSize(14);
  text("This action cannot be undone.", width/2, height/2 - 20);
  
  // Buttons - iOS style text buttons
  color iosBlue = color(0, 122, 255);
  fill(iosBlue);
  textSize(16);
  text("Cancel", width/2 - 60, height/2 + 30);
  
  fill(255, 59, 48); // iOS red for destructive action
  text("Delete", width/2 + 60, height/2 + 30);
  
  rectMode(CORNER);
}

// Handle mouse clicks
void mousePressed() {
  if (showDeleteConfirmation) {
    // Check if cancel button is clicked
    if (mouseX > width/2 - 90 && mouseX < width/2 - 30 && 
        mouseY > height/2 + 15 && mouseY < height/2 + 45) {
      showDeleteConfirmation = false;
    }
    
    // Check if delete button is clicked
    if (mouseX > width/2 + 30 && mouseX < width/2 + 90 && 
        mouseY > height/2 + 15 && mouseY < height/2 + 45) {
      savedReadings.clear();
      showDeleteConfirmation = false;
    }
  } else if (showInputField) {
    // Check if save button is clicked (now a text button)
    if (mouseX > width/2 - 100 && mouseX < width/2 - 40 && 
        mouseY > height/2 + 45 && mouseY < height/2 + 75) {
      // Save reading with entered name
      if (inputText.length() > 0) {
        savedReadings.add(new SavedReading(inputText, frozenConductivitySm));
        showInputField = false;
        inputText = "";
      }
    }
    
    // Check if cancel button is clicked (now a text button)
    if (mouseX > width/2 + 40 && mouseX < width/2 + 100 && 
        mouseY > height/2 + 45 && mouseY < height/2 + 75) {
      showInputField = false;
      inputText = "";
    }
  } else {
    // Check if save text link is clicked
    if (mouseX > width/2 - 60 && mouseX < width/2 + 60 && 
        mouseY > height/2 + 165 && mouseY < height/2 + 195) {
      // Freeze the current reading
      frozenRawConductivity = rawConductivity;
      frozenConductivitySm = conductivitySm;
      showInputField = true;
    }
    
    // Check if delete button (trash icon) is clicked (adjusted for new panel height)
    if (mouseX > width - 38 && mouseX < width - 22 && 
        mouseY > height - savedSamplesHeight + 18 && mouseY < height - savedSamplesHeight + 32) {
      showDeleteConfirmation = true;
    }
    
    // Handle scrolling in saved readings panel (adjusted for new panel height)
    if (mouseX > width - 300 && mouseX < width && 
        mouseY > height - savedSamplesHeight + 41 && mouseY < height - 5) {
      int visibleItems = (savedSamplesHeight - 85) / 30; // Calculate how many items fit
      if (savedReadings.size() > visibleItems) {
        // Scroll up arrow clicked
        if (mouseX > width - 30 && mouseX < width - 5 && 
            mouseY > height - savedSamplesHeight + 45 && mouseY < height - savedSamplesHeight + 65 && 
            savedSamplesScrollPosition < 0) {
          savedSamplesScrollPosition += 30;
        }
        
        // Scroll down arrow clicked
        int maxScroll = -((savedReadings.size() - visibleItems) * 30);
        if (mouseX > width - 30 && mouseX < width - 5 && 
            mouseY > height - 30 && mouseY < height - 10 && 
            savedSamplesScrollPosition > maxScroll) {
          savedSamplesScrollPosition -= 30;
        }
      }
    }
  }
}

// Enable mouse wheel scrolling for saved samples
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  // Only scroll if mouse is over the saved samples panel (adjusted for new height)
  if (mouseX > width - 300 && mouseX < width && 
      mouseY > height - savedSamplesHeight + 41 && mouseY < height - 5) {
    int visibleItems = (savedSamplesHeight - 85) / 30; // Calculate how many items fit
    if (savedReadings.size() > visibleItems) {
      savedSamplesScrollPosition -= e * 15;
      
      // Limit scrolling to stay within bounds
      int maxScroll = -((savedReadings.size() - visibleItems) * 30);
      if (savedSamplesScrollPosition < maxScroll) {
        savedSamplesScrollPosition = maxScroll;
      }
      if (savedSamplesScrollPosition > 0) {
        savedSamplesScrollPosition = 0;
      }
    }
  }
}

// Handle keyboard input
void keyPressed() {
  if (showInputField) {
    if (key == '\n' || key == '\r') {
      // Enter key - save reading
      if (inputText.length() > 0) {
        savedReadings.add(new SavedReading(inputText, frozenConductivitySm));
        showInputField = false;
        inputText = "";
      }
    } else if (key == ESC) {
      // Escape key - cancel
      showInputField = false;
      inputText = "";
      key = 0; // Prevent app from closing
    } else if (key == BACKSPACE) {
      // Backspace - delete last character
      if (inputText.length() > 0) {
        inputText = inputText.substring(0, inputText.length() - 1);
      }
    } else if (key >= ' ' && key <= '~') {
      // Printable characters - add to input
      inputText += key;
    }
  } else if (showDeleteConfirmation) {
    if (key == ESC) {
      showDeleteConfirmation = false;
      key = 0; // Prevent app from closing
    }
  }
}

void serialEvent(Serial myPort) {
  String input = myPort.readStringUntil('\n');
  if (input != null) {
    input = trim(input);
    rawConductivity = int(input);
    
    // Convert raw value to S/m
    // This is an approximation - actual conversion depends on the specific sensor
    // A typical conversion might be linear mapping or follow sensor documentation
    conductivitySm = convertRawToConductivity(rawConductivity);
    
    // Get timestamp in simple AM/PM format
    SimpleDateFormat sdf = new SimpleDateFormat("h:mm a");
    String timestamp = sdf.format(new Date());
    
    // Add to logs with both raw and converted values
    logs.add(timestamp + " → " + rawConductivity + " → " + nf(conductivitySm, 0, 2));
    if (logs.size() > 5) logs.remove(0);
  }
}

// Convert raw Arduino value (0-1023) to conductivity in S/m
float convertRawToConductivity(int rawValue) {
  // This is a simplified conversion formula
  // For a proper conversion, you would need to calibrate with known solutions
  // and possibly apply temperature compensation
  
  // Assuming a linear relationship for demonstration:
  // 0 = 0 S/m, 1023 = 5.0 S/m
  return map(rawValue, 0, 1023, 0, 5.0);
}

// Get color based on conductivity level 
color getConductivityColor(int value) {
  if (value <= 341) return color(0, 112, 243); // iOS blue (Low: 0-341)
  if (value > 341 && value <= 682) return color(255, 149, 0); // iOS orange (Medium: 342-682)
  return color(255, 59, 48); // iOS red (High: 683-1023)
}

// Get color based on S/m value
color getConductivityColorFromSm(float value) {
  if (value <= 1.67) return color(0, 112, 243); // iOS blue
  if (value > 1.67 && value <= 3.33) return color(255, 149, 0); // iOS orange
  return color(255, 59, 48); // iOS red
}

// status texxt
String getConductivityStatus(int value) {
  if (value <= 341) return "LOW";
  if (value > 341 && value <= 682) return "MEDIUM";
  return "HIGH";
}
