#include <stdio.h>

/*

 lumd% =

rmit% :0 zHdvid()d%=.

printf("timr0: %dHz (div=%d)\n",(io->board_cm*2000000u)/(io->timer+1),io->timer);

rmit

% :0

 zHdvid()d%=.

printf("timr0: %dHz (div=%d)\n",(io->board_cm*2000000u)/(io->timer+1),io->timer);

*/

int mem2bin(int output_len, char *output, const char *input) {
    int result = 0;
    if (!output_len || !output || !input) {
        return -1;
    }
    while (1) {
        int c = *input++;
        if (!c) {
            break;
        }
        printf("read c=%c\n", c);
        if (c == '0') {
            output[result++] = 0;
        }
    }
    return result;
}

#include <ut/ut.h>

TESTMETHOD(test_mem2bin_simple1) {
    const char *input = "0";
    char output[1] = { 0xee};
    int output_len = sizeof(output);
    int res;
    res = mem2bin(output_len, output, input);
    ASSERT_EQ(output_len, res);
    ASSERT_EQ(0, output[0]);
}

TESTMETHOD(test_mem2bin_degenerate) {
    int res;
    res = mem2bin(0, 0, 0);
    ASSERT_EQ(-1, res);
    res = mem2bin(1, 0, 0);
    ASSERT_EQ(-1, res);
    res = mem2bin(0, (void *)1, 0);
    ASSERT_EQ(-1, res);
    res = mem2bin(0, 0, (void *)1);
    ASSERT_EQ(-1, res);
}
