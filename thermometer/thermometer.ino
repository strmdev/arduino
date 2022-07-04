#include <LiquidCrystal.h>

#define ANALOG_PIN A0
#define DELAY_TIME 300000

#define LCD_V0  7
#define LCD_RS  12
#define LCD_E   11
#define LCD_DB4 5
#define LCD_DB5 4
#define LCD_DB6 3
#define LCD_DB7 2

LiquidCrystal lcd(LCD_RS, LCD_E, LCD_DB4, LCD_DB5, LCD_DB6, LCD_DB7);

void createCelsiusSymbol() {
    byte celsiusSymbol[] = { B10000, B00110, B01001, B01000,
                             B01000, B01000, B01001, B00110 };
    lcd.createChar(1, celsiusSymbol);
}

void createTemperatureSymbol() {
    byte temperatureSymbol1[8] = { B00000, B00001, B00010, B00100,
                                   B00100, B00100, B00100, B00111 };

    byte temperatureSymbol2[8] = { B00111, B00111, B00111, B01111,
                                   B11111, B11111, B01111, B00011 };

    byte temperatureSymbol3[8] = { B00000, B10000, B01011, B00100,
                                   B00111, B00100, B00111, B11100 };

    byte temperatureSymbol4[8] = { B11111, B11100, B11100, B11110,
                                   B11111, B11111, B11110, B11000 };
    
    lcd.createChar(2, temperatureSymbol1);
    lcd.createChar(3, temperatureSymbol2);
    lcd.createChar(4, temperatureSymbol3);
    lcd.createChar(5, temperatureSymbol4);
}

void displayTemperatureData(float temperatureInCelsius) {
    lcd.setCursor(1, 0);
    lcd.print("Homerseklet");
    lcd.setCursor(4,1);
    lcd.print(temperatureInCelsius);
    
    lcd.setCursor(10, 1);
    lcd.write(1);
}

void displayTemperatureSymbol() {
    lcd.setCursor(13, 0);
    lcd.write(2);

    lcd.setCursor(13, 1);
    lcd.write(3);

    lcd.setCursor(14, 0);
    lcd.write(4);

    lcd.setCursor(14, 1);
    lcd.write(5);
}

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