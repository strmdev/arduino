#include <avr/io.h>

extern "C" {
    void setTimer1();
    void setPiezoToOutput();
    void setPrescalarMode(byte);
    void setOCR1AValue(unsigned int);
    void tooglePiezoPin();
    void piezoOff();
    void disableTimer1();
}

#define PRESCALAR_MODE_CLK_8  0
#define PRESCALAR_MODE_CLK_64 1

int sensorValue;
long pitch;
unsigned int frequency;
unsigned long toogleCount;
byte prescalarMode;

void setup() {
    sensorValue   = 0;
    pitch         = 0;
    frequency     = 0;
    toogleCount   = 0;
    prescalarMode = PRESCALAR_MODE_CLK_8;
    
    setTimer1();
    setPiezoToOutput();
}

void loop() {
    sensorValue = analogRead(A0);
    pitch       = map(sensorValue, 0, 1023, 300, 4000);

    prescalarMode = PRESCALAR_MODE_CLK_8;
    frequency = F_CPU / pitch / 2 - 1;
    if(frequency >= 65535) {
        frequency     = F_CPU / pitch / 2 / 64 - 1;
        prescalarMode = PRESCALAR_MODE_CLK_64;
    }

    toogleCount = 2 * frequency * 20 / 1000;

    setPrescalarMode(prescalarMode);
    setOCR1AValue(frequency);
}

ISR(TIMER1_COMPA_vect) {
    if (toogleCount != 0) {
        tooglePiezoPin();

        if(toogleCount > 0) {
            toogleCount--;
        }
    }
    else {
        disableTimer1();
        piezoOff();
    }
}