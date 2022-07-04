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
