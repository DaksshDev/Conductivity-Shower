const int testPin = A0;  // Conductivity sensor input
const int led1 = 3;      // Low conductivity indicator
const int led2 = 4;      // High conductivity indicator

#define LOW_CONDUCTIVITY 1  
#define HIGH_CONDUCTIVITY 120  

void setup() {
  Serial.begin(9600);
  pinMode(led1, OUTPUT);
  pinMode(led2, OUTPUT);
}

void loop() {
  int conductivity = analogRead(testPin);
  
  // Send data to Processing
  Serial.println(conductivity);

  // Reset both LEDs
  digitalWrite(led1, LOW);
  digitalWrite(led2, LOW);

  if (conductivity >= LOW_CONDUCTIVITY && conductivity < HIGH_CONDUCTIVITY) {
    digitalWrite(led1, HIGH); // Low conductor → 1 LED
  } 
  else if (conductivity >= HIGH_CONDUCTIVITY) {
    digitalWrite(led1, HIGH);
    digitalWrite(led2, HIGH); // High conductor → Both LEDs
  }

  delay(500); // Stability delay
}
