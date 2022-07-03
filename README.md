# Arduino hobbi projektek

## 1. Motivacio

A webes alkalmazasok vilagabol "kiszakadva" uj teruleteket szerettem volna felfedezni. Igy esett a valasztasom az [Arduino](https://www.arduino.cc/en/hardware) hardware (ATMEGA328P) programozas es a benne rejlo lehetosegek alkalmazasara mini projekteken keresztul.

## 2. Hobbi projektek

Nemely esetben Assembly forraskodok is talalhatoak, ennek okai:
- melyebben megszerettem volna erteni az [ATMEGA328P](https://ww1.microchip.com/downloads/en/DeviceDoc/Atmel-7810-Automotive-Microcontrollers-ATmega328P_Datasheet.pdf) mukodesenek rejtelmeit
- a magasabb szintu nyelveken egyszeruen megoldhato feladatok, itt esetenkent tobb kutatast, nehezebb megvalositast foglalnak magukban. Es ez motivalt.

### 2.1 Szobahomero

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

### 2.2 RGBLED "koktel"

#### 2.2.1 Altalanos megkozelites

Adott 3 db phototransistor es 1 db RGBLED. A kornyezetbol vett adatok alapjan, olyan szint "keverunk" ki, majd jelenitunk meg az RGBLED-en, amelyek a phototransistoron keresztul erkeznek a LED egyes labaihoz. A szenzorokon keresztul beolvasott ertekeket a serial porton is megjelenitjuk.

#### 2.2.2 Kodreszlet - Assembly megkozelitesben

C-bol hívjuk az egyes assembly eljarasokat, amiket korabban megirtunk:


```C
// ...
void setup() {
    initColorMixingLamp();           //Inicializalas: portok es serial kommunikacio beallitasa.
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
initColorMixingLamp:                              ;Inicializalo eljaras
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
