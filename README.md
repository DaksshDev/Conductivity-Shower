# TESTER 1(a) 12V w/ Software 🚀

A **modern** and **open-source** conductivity tester powered by **Arduino Uno** and **Processing Java**. It not only checks conductivity but also **visualizes** the data in real-time with a sleek UI, graphs, and even lets you save sample values!

## Features 🎯

- **Real-time Conductivity Visualization** 🌊⚡
  - Displays **raw conductivity values** + **converted S/m values**.
  - Graphs conductivity **over time** 📊.
  - Indicates if conductivity is **low, mid, or high**.
- **Physical Conductivity Checker** 🛠️
  - Uses **+ and - wires** for testing.
  - **LED Indicators**: 🔴 1 LED = Low Conductivity, 🔴🔴 2 LEDs = High Conductivity.
- **Sample Saving** 💾
  - Store readings like **"Lemon Juice: 1.5 S/m"** for future reference.
- **Super Modern UI** 🎨🔥
  - Looks like a **Nothing product™** lol.
  - Easy-to-use with a **graphical conductivity meter**.
- **Requires external power** ⚡
  - Needs **PC (for both power & software)** or a **power bank** to function.

## Setup & Installation 🛠️

### **Hardware**
1. **Arduino Uno**
2. **2 LEDs**
3. **+ & - Conductivity Wires**
4. **12V Power Supply (PC or Power Bank)**

 ## 🛠 Wiring Setup
| Component | Arduino Pin |
|-----------|------------|
| Positive Probe | 5V |
| Negative Probe (via resistor) | A0 (Analog Pin) |
| LED 1 (Low Conductivity) | D3 |
| LED 2 (High Conductivity) | D4 |

⚠️ **IMPORTANT:** Use **330Ω or 220Ω resistors** in series with the LEDs to avoid burning them out!

### **Software**
1. Install **[Arduino IDE](https://www.arduino.cc/en/software)**.
2. Install **[Processing IDE](https://processing.org/download/)**.
3. Upload the `arduino_tester.ino` code to your Arduino Uno.
4. Run `processing_visualizer.pde` on your PC.

## Usage 🚀
- **Connect** the Arduino to **COM4**.
- Attach wires to the substance **to test conductivity**.
- Observe LED indicators & **live visualization on PC**.
- Save sample values for reference!

## Showcase 🚀
![1](https://github.com/user-attachments/assets/71fdad72-1bc5-4fa0-b01c-b0319e961604)
![2](https://github.com/user-attachments/assets/5285d7cf-6ca5-4d45-9e24-55b3c018da66)


## License 📜

MIT License © 2025 **Dakssh Bhambre**

> You are free to **use, modify, and distribute** this project as long as proper credit is given.

---

🔥 **"TESTER 1(a) 12V w/Software"** is built with passion and some serious **next-level innovation**. If you like this project, don’t forget to **star** ⭐ it on GitHub!

