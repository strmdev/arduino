#define PIEZO_PIN  8
#define ANALOG_PIN A0

int notes [] = {262, 294, 330, 349};

void setup() {}

void loop() {
    int keyValue = analogRead(ANALOG_PIN);

    if(keyValue == 1023) {
        tone(PIEZO_PIN, notes[0]);
    }
    else if(keyValue >= 515 && keyValue <= 970) {
        tone(PIEZO_PIN, notes[1]);
    }
    else if(keyValue >= 100 && keyValue <= 512) {
        tone(PIEZO_PIN, notes[2]);
    }
    else if(keyValue >= 5 && keyValue <= 10) {
        tone(PIEZO_PIN, notes[3]);
    }
    else {
        noTone(PIEZO_PIN);
    }
}