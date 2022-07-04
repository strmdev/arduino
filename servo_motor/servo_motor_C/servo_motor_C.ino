#include<Servo.h>

#define POTENTIOMETER_PIN A0
#define SERVO_PIN         9

#define ANALOG_VALUE_MIN  0
#define ANALOG_VALUE_MAX  1023
#define SERVO_MIN_ANGLE   0
#define SERVO_MAX_ANGLE   179

#define DELAY_VALUE       15

Servo myServo;
int potentiometerValue = 0;
int servoAngle         = 0;

void setup() {
    myServo.attach(SERVO_PIN);
}

void loop() {
    potentiometerValue = analogRead(POTENTIOMETER_PIN);
    servoAngle         = map(potentiometerValue, ANALOG_VALUE_MIN, ANALOG_VALUE_MAX, SERVO_MIN_ANGLE, SERVO_MAX_ANGLE);

    myServo.write(servoAngle);
    delay(DELAY_VALUE);
}