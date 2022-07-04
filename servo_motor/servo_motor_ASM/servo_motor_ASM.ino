extern "C" {
    void initServoMotor_ASM();
    void setAngle(byte);
}

#define POTENTIOMETER_PIN A0
#define ANALOG_VALUE_MIN  0
#define ANALOG_VALUE_MAX  1023
#define SERVO_MIN_ANGLE   0
#define SERVO_MAX_ANGLE   179

int potentiometerValue = 0;
byte servoAngle        = 0;

void setup() {
    initServoMotor_ASM();
}

void loop() {
    potentiometerValue = analogRead(POTENTIOMETER_PIN);
    servoAngle         = map(potentiometerValue, ANALOG_VALUE_MIN, ANALOG_VALUE_MAX, SERVO_MIN_ANGLE, SERVO_MAX_ANGLE);

    setAngle(servoAngle);
    delay(20);
}
