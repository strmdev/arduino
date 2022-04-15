;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------;
;                                                                     AVR(-GCC) ASSEMBLY - COLOR MIXING LAMP                                                                       ;
;        AUTHOR     : S.M.                                                                                                                                                         ;
;        CREATE DATE: 2022.04.12.                                                                                                                                                  ;
;        MODIFY DATE: 2022.04.15.                                                                                                                                                  ;
;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------;

#define __SFR_OFFSET 0x00
#include "avr/io.h"

.global initColorMixingLamp                       ;Inicializalo eljaras
.global A0_AnalogRead                             ;Az "A0" portrol erkezo analog jel digitalissa konvertalasa eljaras (RGBLed "red" lab)
.global A1_AnalogRead                             ;Az "A1" portrol erkezo analog jel digitalissa konvertalasa eljaras (RGBLed "blue" lab)
.global A2_AnalogRead                             ;Az "A2" portrol erkezo analog jel digitalissa konvertalasa eljaras (RGBLed "green" lab)
.global printMessage                              ;"Red value: xxx" / "Blue value: yyy" / "Green value: zzz" uzenet megjelenitese a serial porton a "printMsg" makron keresztul
.global RGBLEDOn                                  ;Fenyerosseg beallitasa az RGBLED "red"/"blue"/"green" laban a "LedOn" makron keresztul
.global delay2sec                                 ;2sec = 2.000.000 microsec.

redMessage:                                       ;Program memory-ban tarolt uzenet
    .byte 0b00001101                              ;13 byte
    .asciz "Red value: "
greenMessage:                                     ;Program memory-ban tarolt uzenet
    .byte 0b00001101                              ;13 byte
    .asciz "Green value: "
blueMessage:                                      ;Program memory-ban tarolt uzenet
    .byte 0b00001101                              ;13 byte
    .asciz "Blue value: "
   
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

A0_AnalogRead:                                    ;Az "A0" portrol erkezo analog jel digitalissa konvertalasa eljaras (RGBLed "red" lab)
    RCALL setADC_A0
    RCALL convertAnalogToDigital    
RET

setADC_A0:                                        ;Inicializaljuk az ADC-t: "A0"-t kell hasznalni
    LDI R20,0b11100000                            ;0xE0                                  
    STS ADMUX,R20
    LDI R20,0b10000111                            ;0x87
    STS ADCSRA,R20
RET

setPWMModeRGBLEDRed:                              ;Pulse Width Modulation (PWM) beallitasa a "red labhoz" (Fast PWM mode)
    LDI R16,1<<WGM20 | 1<<WGM21 | 1<<COM2A1       
    STS TCCR2A,R16
    LDI R16,1<<CS21                               ;Pulse Width Modulation (PWM) clock beallitasa (clock/8)
    STS TCCR2B, R16
RET

A1_AnalogRead:                                    ;Az "A1" portrol erkezo analog jel digitalissa konvertalasa eljaras (RGBLed "blue" lab)
    RCALL setADC_A1
    RCALL convertAnalogToDigital
RET

setADC_A1:                                        ;Inicializaljuk az ADC-t: "A1"-t kell hasznalni
    LDI R20,0b11100001                            ;0xE1                                  
    STS ADMUX,R20
    LDI R20,0b10000111
    STS ADCSRA,R20
RET

setPWMModeRGBLEDBlue:                             ;Pulse Width Modulation (PWM) beallitasa a "blue labhoz" (Fast PWM mode)
    LDI R16,1<<WGM10 | 1<<WGM11 | 1<<COM1B1       
    STS TCCR1A,R16
    LDI R16,1<<CS11                               ;Pulse Width Modulation (PWM) clock beallitasa (clock/8)
    STS TCCR1B,R16
RET

A2_AnalogRead:                                    ;Az "A2" portrol erkezo analog jel digitalissa konvertalasa eljaras (RGBLed "green" lab)                                          
    RCALL setADC_A2
    RCALL convertAnalogToDigital         
RET

setADC_A2:                                        ;Inicializaljuk az ADC-t: "A2"-t kell hasznalni
    LDI R20,0b11100010                            ;0xE2                                  
    STS ADMUX,R20
    LDI R20,0b10000111
    STS ADCSRA,R20
RET

setPWMModeRGBLEDGreen:                            ;Pulse Width Modulation (PWM) beallitasa a "green labhoz" (Fast PWM mode)
    LDI R16,1<<WGM10 | 1<<WGM11 | 1<<COM1A1       
    STS TCCR1A,R16
    LDI R16,1<<CS11                               ;Pulse Width Modulation (PWM) clock beallitasa (clock/8)
    STS TCCR1B,R16
RET

printDigitalValueToSerialPort:                    ;Az analog jelbol kepzett digitalis ertek megjelenitese a serial porton pl: "011"
    LDI R19,0b00110000                              
    CLR R25
    CLR R23
    
    valueGreaterThan100:
        CPI R16,0b01100100
        BRMI valueCheckLessThan100
        INC R25
        SUBI R16,0b01100100
    RJMP valueGreaterThan100
    valueCheckLessThan100:
        CPI R16,0b00001010
        BRMI printToSerialPort
        INC R23
        SUBI R16,0b00001010
    RJMP valueCheckLessThan100

    printToSerialPort:
        PUSH R16
        ADD R25,R19
        MOV R16,R25
        
        isLowByteReadyToSent:
            LDS R17,UCSR0A
            SBRS R17,UDRE0
        RJMP isLowByteReadyToSent
        STS UDR0,R16                              ;Ha tudtuk fogadni az adatot, akkor megjelenithetjuk
        
        MOV R16,R23
        ADD R16,R19
        isMidByteReadyToSent:
            LDS R17,UCSR0A
            SBRS R17,UDRE0
        RJMP isMidByteReadyToSent
        STS UDR0,R16                              ;Ha tudtuk fogadni az adatot, akkor megjelenithetjuk
        
        POP R16
        ADD R16,R19
        isHighByteReadyToSent:
            LDS R17,UCSR0A
            SBRS R17,UDRE0
        RJMP isHighByteReadyToSent
        STS UDR0,R16                              ;Ha tudtuk fogadni az adatot, akkor megjelenithetjuk
        
        LDI R18,0b00001010    
        newlineCharacter:
            LDS R17,UCSR0A
            SBRS R17,UDRE0
        RJMP newlineCharacter
        STS UDR0,R18                              ;New line character megjelenitese
        LDI R18,0b00001101
        carrigeReturnCharacter:
            LDS R17,UCSR0A
            SBRS R17,UDRE0
        RJMP carrigeReturnCharacter
        STS UDR0,R18                              ;Carriage return character megjelenitese
RET

convertAnalogToDigital:                           ;Analog Digital Converter (ADC)
    LDI R20,0b11000111                            ;Konvertalas inditasa
    STS ADCSRA,R20
    isAnalogConversionDone:                          
        LDS R21,ADCSRA
        SBRS R21,0b00000100
    RJMP isAnalogConversionDone                   ;Amig a konvertalas nem done, addig nem megyunk tovabb
    LDI R17,0b11010111                            ;A konvertalas sikeres, igy annak sikeret jelzo flaget alapertelmezett allapotba tesszuk vissza
    STS ADCSRA,R17
    LDS R16,ADCL                                  ;Beolvassuk a digitalis erteket, amit az analogbol kepeztunk
    LDS R16,ADCH
RET

.MACRO printMsg analogInputPort                   ;analogInputPort = 0: "Red value: xxx" uzenet megjelenitese a serial porton
    CPI \analogInputPort,0b00000000               ;analogInputPort = 1: "Blue value: yyy" uzenet megjelenitese a serial porton
    BREQ redMsg                                   ;analogInputPort = 2: "Greeen value: zzz" uzenet megjelenitese a serial porton
    CPI \analogInputPort,0b00000001
    BREQ blueMsg
    CPI \analogInputPort,0b00000010
    BREQ greenMsg

    redMsg:
        LDI R30,lo8(redMessage)                       
        LDI R31,hi8(redMessage)
        RJMP printMain        
    blueMsg:
        LDI R30,lo8(blueMessage)                       
        LDI R31,hi8(blueMessage)
        RJMP printMain        
    greenMsg:
        LDI R30,lo8(greenMessage)                       
        LDI R31,hi8(greenMessage) 
    printMain:
        characters:
            LPM R18,Z+
            CPI R18,0b00000000
            BREQ printDigitalValue
            isReadyToOutput:
                LDS R17,UCSR0A
                SBRS R17,UDRE0
            RJMP isReadyToOutput
            STS UDR0,R18
        RJMP characters
        printDigitalValue:
            RCALL printDigitalValueToSerialPort   ;Miutan kiirtuk az uzenetet, megjelenitjuk a digitalis erteket is pl: "020"  
.ENDM

.MACRO LEDOn analogInputPort                      ;PWM modban a digitalis erteknek megfelelo fenyerosseg beallitasa az RGBLED "red"/"blue"/"green" laban
    CPI \analogInputPort,0b00000000               ;analogInputPort = 1: RGBLED "red laba"
    BREQ RGBLEDRedOn                              ;analogInputPort = 2: RGBLED "blue laba"
    CPI \analogInputPort,0b00000001               ;analogInputPort = 2: RGBLED "green laba"
    BREQ RGBLEDBlueOn
    CPI \analogInputPort,0b00000010
    BREQ RGBLEDGreenOn

    RGBLEDRedOn:
        RCALL setPWMModeRGBLEDRed
        LDS R16,ADCH                                 
        STS OCR2A,R16
        RJMP endOfMacro
    RGBLEDBlueOn:
        RCALL setPWMModeRGBLEDBlue
        LDS R16,ADCH
        STS OCR1B,R16
        RJMP endOfMacro   
    RGBLEDGreenOn:
        RCALL setPWMModeRGBLEDGreen
        LDS R16,ADCH
        STS OCR1A,R16  
    endOfMacro:
.ENDM

printMessage:                                     ;"Red value: xxx" / "Blue value: yyy" / "Green value: zzz" uzenet megjelenitese a serial porton a "printMsg" makron keresztul
    printMsg R24
RET

RGBLEDOn:                                         ;Fenyerosseg beallitasa az RGBLED "red"/"blue"/"green" laban a "LedOn" makron keresztul
    LEDOn R24
RET

delay2sec:                                        ;2sec = 2.000.000 microsec = R17 + (R18 * R19) + (R17 * R18 * R19)
    LDI R17,0b10100000
    LDI R18,0b10100000
    LDI R19,0b01001110
delayMain:
    DEC R17
    BRNE delayMain
    DEC R18
    BRNE delayMain
    DEC R19
    BRNE delayMain
RET
