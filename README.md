# Arduino hobbi projektek

## 1. Motivacio

A webes alkalmazasok vilagabol "kiszakadva" uj teruleteket szerettem volna felfedezni. Igy esett a valasztasom az [Arduino UNO R3](https://www.arduino.cc/en/hardware) hardware programozas es a benne rejlo lehetosegek alkalmazasara mini projekteken keresztul.

## 2. Hobbi projektek

Nemely esetben Assembly forraskodok is talalhatoak, ennek okai:
- melyebben megszerettem volna erteni az [ATMEGA328P](https://ww1.microchip.com/downloads/en/DeviceDoc/Atmel-7810-Automotive-Microcontrollers-ATmega328P_Datasheet.pdf) mukodesenek rejtelmeit
- a magasabb szintu nyelveken egyszeruen megoldhato feladatok, itt esetenkent tobb kutatast, nehezebb megvalositast foglalnak magukban. Es ez motivalt.

### 2.1 Szobahomero 🌡

Forraskod megtekintheto [ide kattintva](/thermometer).

![Szobahomero](images/thermometer.png)

#### 2.1.1 Altalanos megkozelites

A cel egy egyszeru szobahomero megvalositasa volt, amely 5 percenkent "lekerdezi" a kulso homersekletet. Majd ezt az adatot egy LCD kijelzon megjeleniti.

#### 2.1.2 Kodreszlet

```C
// ...
void setup() {
    pinMode(LCD_V0, OUTPUT);
    lcd.begin(16, 2);
    
    createCelsiusSymbol();
    createTemperatureSymbol();

    lcd.clear();
}

void loop() {
    int temperatureSensorValue = analogRead(ANALOG_PIN);
    
    float voltage              = (temperatureSensorValue / 1024.0) * 5.0;
    float temperatureInCelsius = (voltage - .5) * 100;

    displayTemperatureData(temperatureInCelsius);
    displayTemperatureSymbol();
    
    delay(DELAY_TIME);
    lcd.clear();
}
// ...
```

### 2.2 RGBLED "koktel" 🍸

Forraskod megtekintheto [ide kattintva](/rgbled_cocktail).

![RGBLED "koktel"](images/rgbled_cocktail.png)

#### 2.2.1 Altalanos megkozelites

Adott 3 db phototransistor es 1 db RGBLED. A kornyezetbol vett adatok alapjan, olyan szint "keverunk" ki, majd jelenitunk meg az RGBLED-en, amelyek a phototransistoron keresztul erkeznek a LED egyes labaihoz. A szenzorokon keresztul beolvasott ertekeket a serial porton is megjelenitjuk.

#### 2.2.2 Kodreszlet - Assembly megkozelitesben

C-bol hívjuk az egyes assembly eljarasokat:


```C
// ...
void setup() {
    initRGBLEDCocktail();            //Inicializalas: portok es serial kommunikacio beallitasa.
}

void loop() {
    A0_AnalogRead();                 /*A0 portrol erkezo analog jel:
                                           - Beolvasasa.
                                           - Digitalis jelle konvertalasa.*/
    printMessage(A0_ANALOG_PORT_ID);     //- Kuldese OUTPUT-ra: - Serial port pl.: "Red value: 020".
    RGBLEDOn(A0_ANALOG_PORT_ID);                              //- RGBLed "red" laba.
// ...
}
```

Fobb assembly eljarasok a megvalositas felso szintjen:

```assembly
; ...
initRGBLEDCocktail:                               ;Inicializalo eljaras
    RCALL setPorts
    RCALL setSerialPortCommunication
RET

setPorts:                                         ;Portok beallitasa
    SBI DDRB,0b00000011                           ;RGBLED "red laba" output
    SBI DDRB,0b00000010                           ;RGBLED "blue laba" output
    SBI DDRB,0b00000001                           ;RGBLED "green laba" output
        
    SBI DDRC,0b00000000                           ;"A0" analog port INPUT
    SBI DDRC,0b00000001                           ;"A1" analog port INPUT
    SBI DDRC,0b00000010                           ;"A2" analog port INPUT
RET

setSerialPortCommunication:                       ;Serial port kommunikacio beallitasa
    CLR R24                                       
    STS UCSR0A,R24
    STS UBRR0H,R24
    LDI R24,0b01100111                            ;Baud Rate = 9600 ((pow(10,6) / 9600) - 1 = 103)
    STS UBRR0L,R24
    LDI R24,1<<RXEN0 | 1<<TXEN0                   ;Tx (serial port write) es Rx (serial port read) engedelyezese
    STS UCSR0B,R24
    LDI R24,1<<UCSZ00 | 1<<UCSZ01                 ;Aszinkron mod, character frame = 8, 1 stop bit, no parity coding
    STS UCSR0C,R24
RET
; ...
```

```assembly
; ...
A0_AnalogRead:                                    ;Az "A0" portrol erkezo analog jel digitalissa konvertalasa eljaras (RGBLed "red" lab)
    RCALL setADC_A0
    RCALL convertAnalogToDigital    
RET

printMessage:                                     ;"Red value: xxx" / "Blue value: yyy" / "Green value: zzz" uzenet megjelenitese
    printMsg R24
RET

RGBLEDOn:                                         ;Fenyerosseg beallitasa az RGBLED "red"/"blue"/"green" laban a "LedOn" makron keresztul
    LEDOn R24
RET
; ...
```

### 2.3 SM-S2309S servo motor vezerlese 🕹

Forraskod megtekintheto [ide kattintva](/servo_motor).

![Servo motor](images/servo_motor.png)

#### 2.3.1 Altalanos megkozelites

A servo motor vezerlese volt itt fokuszban, hogy a rajta elhelyezett "propeller" mozogjon 180 fokban oda-vissza. Azt hogy eppen hany fokon "allunk", az eppen beolvasott ertek hatarozza meg, amely analog input formajaban erkezik egy potentiometer-en keresztul.

#### 2.3.2 Kodreszlet Assembly megkozelitesben

C-bol hívjuk az egyes assembly eljarasokat, amelyeket korabban mar megirtunk:
```C
// ...

void setup() {
    initServoMotor_ASM();
}

void loop() {
    potentiometerValue = analogRead(POTENTIOMETER_PIN);
    servoAngle         = map(potentiometerValue, ANALOG_VALUE_MIN, ANALOG_VALUE_MAX, SERVO_MIN_ANGLE, SERVO_MAX_ANGLE);

    setAngle(servoAngle);
    delay(20);
}
```

Assembly eljarasok:

```assembly
#define __SFR_OFFSET 0x00
#include "avr/io.h"

.global initServoMotor_ASM  ;Inicializalas. C-bol valo hivashoz.
.global setAngle            ;Angle beallitasa. C-bol valo hivashoz.

initServoMotor_ASM:         ;Potentiometer: OUTPUT. PWM mod beallitasa: CTC.
    SBI DDRB,0b00000001
    RCALL setPWMModeToServo
RET

setPWMModeToServo:          ;PWM mod beallitasa: CTC.
    LDI R20,0b10000011
    STS TCCR1A,R20
    LDI R20,0b00001100
    STS TCCR1B,R20
RET

setAngle:                   ;A potentiometer-bol erkezo ertek szerinti forgatas.
    STS OCR1A,R24
RET
```

### 2.4 "Arturito" 🎸

Forraskod megtekintheto [ide kattintva](arturito/).

![Arturito](images/arturito.png)

#### 2.4.1 Altalanos megkozelites

A phototransistoron keresztul beolvasott analog jel lekepzese egy adott frekvenciatartomanyba. Majd a lekepzett ertek atadasa a piezo-nak, amely a kapott frekvencia erteken elkezd majd "csipogni". A "csipogas" az eppen beolvasott erteknek megfeleloen valtozik majd.

Ilyesmit hallanank, amely egy jol ismert "klasszikust" idez majd elenk: [Star Wars Arturito](https://www.youtube.com/watch?v=2-BKjnAgNgY)

#### 2.4.2 Kodreszlet Assembly megkozelitesben

C-bol hívjuk majd az assembly eljarasokat:

```C
// ...

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

// ...
```

Assembly kodreszletek:

```assembly
; ...

setPrescalarMode:
    CPI R24,0
    BREQ setClock8
    CPI R24,1
    BREQ setClock64

    setClock8:
        CLR R16
        LDI R16,0b00001010
        STS TCCR1B,R16
    RJMP retSetClock

    setClock64:
        CLR R16
        LDI R16,0b00001011
        STS TCCR1B,R16
    retSetClock:
RET

setOCR1AValue:
    STS OCR1AH,R25
    STS OCR1AL,R24
    CLR R16
    LDI R16,0b00000010
    STS TIMSK1,R16
    SEI
RET

; ...
```
