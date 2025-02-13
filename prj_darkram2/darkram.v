`ifdef USE__ALTSYNCRAM
module darkram #(parameter INIT_FILE = "memory_init.mem")
(
    input           CLK,    // Clock
    input           RES,    // Reset
    input           HLT,    // Halt

    input           IDREQ,  // Instruction fetch request
    input  [31:0]   IADDR,  // Instruction address
    output [31:0]   IDATA,  // Instruction data output
    output          IDACK,  // Instruction acknowledge

    input           XDREQ,  // Data request
    input           XRD,    // Read enable
    input           XWR,    // Write enable
    input  [3:0]    XBE,    // Byte enable
    input  [31:0]   XADDR,  // Data address
    input  [31:0]   XATAI,  // Data input
    output [31:0]   XATAO,  // Data output
    output          XDACK,  // Data acknowledge

    output [3:0]    DEBUG   // Debug signals
);

    // Internal signals
    wire [31:0] ram_q_a, ram_q_b;
    wire        write_enable;

    assign write_enable = XWR & XDREQ;

    // Instantiate altsyncram
    altsyncram #(
        .operation_mode("BIDIR_DUAL_PORT"),
        .width_a(32),
        .widthad_a(12),  // Address width for 4KB RAM
        .numwords_a(4096),
        .width_b(32),
        .widthad_b(12),
        .numwords_b(4096),
        .lpm_type("altsyncram"),
        .ram_block_type("AUTO"),
        .init_file(INIT_FILE),
        .outdata_reg_a("UNREGISTERED"),
        .outdata_reg_b("UNREGISTERED"),
        .indata_reg_b("CLOCK0"),
        .address_reg_b("CLOCK0"),
        .wrcontrol_wraddress_reg_b("CLOCK0"),
        .byte_size(8),
        .width_byteena_a(4),
        .width_byteena_b(4),
        .byteena_reg_b("CLOCK0")
    ) ram_inst (
        .clock0(CLK),
        .address_a(IADDR[13:2]),
        .q_a(ram_q_a),
        .address_b(XADDR[13:2]),
        .wren_b(write_enable),
        .byteena_b(XBE),
        .data_b(XATAI),
        .q_b(ram_q_b)
    );

    // Assign instruction fetch outputs
    assign IDATA = ram_q_a;
    assign IDACK = IDREQ;  // Immediate ACK for simplicity

    // Assign data read/write outputs
    assign XATAO = ram_q_b;
    assign XDACK = XDREQ;  // Immediate ACK for simplicity

    // Debug outputs (for observability)
    assign DEBUG = {HLT, XDREQ, IDREQ, XWR};

endmodule
`else
module darkram #(parameter INIT_FILE = "memory_init.mem")
(
    input           CLK,    
    input           RES,    
    input           HLT,    

    input           IDREQ,  
    input  [31:0]   IADDR,  
    output [31:0]   IDATA,  
    output          IDACK,  

    input           XDREQ,  
    input           XRD,    
    input           XWR,    
    input  [3:0]    XBE,    
    input  [31:0]   XADDR,  
    input  [31:0]   XATAI,  
    output [31:0]   XATAO,  
    output          XDACK,  

    output [3:0]    DEBUG   
);

    reg [31:0] ram [0:4095];  // 4KB RAM
    reg [31:0] ram_q_a = 0, ram_q_b = 0;

    initial begin
        $readmemh(INIT_FILE, ram); // Load memory contents
    end

    always @(posedge CLK) begin
//        if (RES) begin
//            ram_q_a <= 0;
//        end else begin
        if (XDREQ && XWR) begin
            if (XBE[0]) ram[XADDR[13:2]][7:0]   <= XATAI[7:0];
            if (XBE[1]) ram[XADDR[13:2]][15:8]  <= XATAI[15:8];
            if (XBE[2]) ram[XADDR[13:2]][23:16] <= XATAI[23:16];
            if (XBE[3]) ram[XADDR[13:2]][31:24] <= XATAI[31:24];
        end

//        if (IDREQ)
            ram_q_a <= ram[IADDR[13:2]];
            
        if (XDREQ && XRD)
            ram_q_b <= ram[XADDR[13:2]];
//        end
    end

    assign IDATA = ram_q_a;
    assign IDACK = IDREQ;

    assign XATAO = ram_q_b;
    assign XDACK = XDREQ;

    assign DEBUG = {HLT, XDREQ, IDREQ, XWR};

endmodule
`endif
