extern "C" {                         //Assembly hivashoz
    void initColorMixingLamp(); 
    void A0_AnalogRead();
    void A1_AnalogRead();
    void A2_AnalogRead();
    
    void RGBLEDOn(byte);
    void printMessage(byte);
    void delay2sec();
}

#define A0_ANALOG_PORT_ID 0
#define A1_ANALOG_PORT_ID 1
#define A2_ANALOG_PORT_ID 2

void setup() {
    initColorMixingLamp();           //Inicializalas: portok es serial kommunikacio beallitasa.
}

void loop() {
    A0_AnalogRead();                 /*A0 portrol erkezo analog jel:
                                           - Beolvasasa.
                                           - Digitalis jelle konvertalasa.*/
    printMessage(A0_ANALOG_PORT_ID);     //- Kuldese OUTPUT-ra: - Serial port pl.: "Red value: 020".
    RGBLEDOn(A0_ANALOG_PORT_ID);                              //- RGBLed "red" laba.

    A1_AnalogRead();                 /*A1 portrol erkezo analog jel:
                                           - Beolvasasa.
                                           - Digitalis jelle konvertalasa.*/
    printMessage(A1_ANALOG_PORT_ID);     //- Kuldese OUTPUT-ra: - Serial port pl.: "Blue value: 030".
    RGBLEDOn(A1_ANALOG_PORT_ID);                              //- RGBLed "blue" laba.

    A2_AnalogRead();                 /*A2 portrol erkezo analog jel:
                                           - Beolvasasa.
                                           - Digitalis jelle konvertalasa.*/
    printMessage(A2_ANALOG_PORT_ID);     //- Kuldese OUTPUT-ra: - Serial port pl.: "Green value: 005".
    RGBLEDOn(A2_ANALOG_PORT_ID);                              //- RGBLed "green" laba.
    
    delay2sec();                     //Delay = 2 sec = 2.000.000 ms
}
