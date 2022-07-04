#define __SFR_OFFSET 0x00
#include "avr/io.h"

.global setTimer1
.global setPiezoToOutput
.global setPrescalarMode
.global setOCR1AValue
.global tooglePiezoPin
.global disableTimer1
.global piezoOff

setTimer1:
    CLR R16
    LDI R16,0b01000000
    STS TCCR1A,R16
    CLR R16
    LDI R16,0b00001001
    STS TCCR1B,R16
RET

setPiezoToOutput:
    SBI DDRB,0b00000001
RET

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

tooglePiezoPin:
    SBIS PORTB,0b00000001
    CBI PORTB,0b00000001
    SBIC PORTB,0b00000001
    SBI PORTB,0b00000001
RET

disableTimer1:
    CLR R16
    STS TIMSK1,R16
RET

piezoOff:
    CBI PORTB,0b00000001
RET