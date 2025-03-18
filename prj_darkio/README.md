40000000        => io
40000004        => UART.stat 8
40000005        => UART.fifo 8
40000008        => LED 16
# RISCV
DEBUG = { XRES, |FLUSH, SCC, LCC }
IDATAX = XRES ? 0 : HLT2 ? IDATA2 : IDATA
XMCC   <= HLT ? XMCC   : IDATAX[6:0]==`MCC

MCC    0:<----->00000513          <---->li<---->a0,0                    ; _start
SYS    4:<----->f1402573          <---->csrr<-->a0,mhartid              ; _start
BCC    8:<----->00050463          <---->beqz<-->a0,10 <_uart_boot>      ; _start
-------c:<----->0000006f          <---->j<----->c <_thread_lock>        ; _start
      10:<----->400005b7          <---->lui<--->a1,0x40000              ; _uart_boot
      14:<----->00058503          <---->lb<---->a0,0(a1) # 40000000 <_global+0x3fffda74>
      18:<----->04050663          <---->beqz<-->a0,64 <_normal_boot>
      1c:<----->07500513          <---->li<---->a0,117
      20:<----->0c8000ef          <---->jal<--->e8 <_uart_putchar>
00000064 <_normal_boot>:                                                   
      64:<----->00a00513          <---->li<---->a0,10                      ; _normal_boot
      68:<----->080000ef          <---->jal<--->e8 <_uart_putchar>         ; _normal_boot


IDATAX  00000513 00000513 f1402573 
XMCC             1        1        

FLUSH   2        1       0                          2        1        0                                                                          -
HLT                                                                             1                                                                -
HLT2                                                                                     1                                                       -
PC      00000000                   00000004 00000008 0000000c 00000010                                                                           -
IADDR   00000000 00000004 00000008 0000000c 00000010->        00000014 00000018                                                                  -
Fetch   00000513->        f1402573 00050463 0000006f 400005b7->        00058503 04050663->        0c8000ef                                       -
Decode           XMCC----->        XSYS     XBCC     XJAL     XLUI----->        XLCC----->                                                       -
Execute                   MCC      SYS      BCC                                                                                                  -
Opc                       13       73       63                                                                                                   -
Fct3                      000      010      000                                                                                                  -
Fct7                      00       78       00                                                                                                   -

# UART
UART_STATE = { 6'd0, UART_RREQ!=UART_RACK, UART_XREQ!=UART_XACK }
DATAO = { UART_TIMER, UART_RFIFO, UART_STATE }
DEBUG = { RXD, TXD, UART_XSTATE!=`UART_STATE_IDLE, UART_RSTATE!=`UART_STATE_IDLE }

# SPI
STATUS={6'b0, spi_ready, spi_busy}
  BE
W 0011 ADDR,DATA
R 0011 STATUS,DATA
W 1111 00,ADDR,DATAHI,DATALO
R 1111 00,STATUS,DATAHI,DATALO


# SPI sequence
STATE_Whoami => STATE_Whoami_Wait => STATE_Init
0x8f00          RnW=1   MnS=0   16      =>      0x0f    R WHO_AM_I      =>      0xzz33
STATE_Init => STATE_Init_Wait => STATE_Init1
0x2077          RnW=0   MnS=0   16      =>      0x20    W CTRL_REG1     =>      0xzz00
STATE_Init1 => STATE_Init1_Wait => STATE_Init2
0x1fc0          RnW=0   MnS=0   16      =>      0x1f    W TEMP_CFG_REG  =>      0xzz00
STATE_Init2 => STATE_Init2_Wait => STATE_Read
0x2388          RnW=0   MnS=0   16      =>      0x23    W CTRL_REG4     =>      0xzz00
STATE_Read => STATE_Read_Wait => STATE_LEDout
0xe80000        RnW=1   MnS=1   24      =>      0x28    R OUT_X_L       =>      0xfafa
