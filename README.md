# Arduino hobbi projektek

## 1. Motivacio

A webes alkalmazasok vilagabol "kiszakadva" uj teruleteket szerettem volna felfedezni. Igy esett a valasztasom az [Arduino](https://www.arduino.cc/en/hardware) hardware (ATMEGA328P) programozas es a benne rejlo lehetosegek alkalmazasara mini projekteken keresztul.

## 2. Hobbi projektek

Nemely esetben Assembly forraskodok is talalhatoak, ennek okai:
- melyebben megszerettem volna erteni az [ATMEGA328P](https://ww1.microchip.com/downloads/en/DeviceDoc/Atmel-7810-Automotive-Microcontrollers-ATmega328P_Datasheet.pdf) mukodesenek rejtelmeit
- a magasabb szintu nyelveken egyszeruen megoldhato feladatok, itt esetenkent tobb kutatast, nehezebb megvalositast foglalnak magukban. Es ez motivalt.

### 2.1 Szobahomero

#### 2.1.1 Altalanos megkozelites

A cel egy egyszeru szobahomero megvalositasa volt, amely 5 percenkent "lekerdezi" a kulso homersekletet. Majd ezt az adatot egy LCD kijelzon megjeleniti. Kodreszlet:

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
