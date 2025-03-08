#include <stdint.h>
uint8_t led_from_acc(int8_t saved_acc) {
    return 1 << ((saved_acc + (-128)) >> 5);
}
#include <ut/ut.h>
TESTMETHOD(test_mult) {
    int8_t saved_acc = 120;
    uint8_t led_out;
    for (saved_acc = -128; saved_acc < 127; saved_acc++) {
        led_out = led_from_acc(saved_acc);
        printf("saved_acc=%d led_out=%u\n", saved_acc, led_out);
    }
    ASSERT(led_out == 42);
}
