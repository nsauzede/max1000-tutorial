module darkspisequencer (
`ifdef SIMULATION
	input wire x_l_flag,
	output reg [15:0] x_l_response,
`endif
	input wire clk_in,
	input wire nrst,
	
	output reg        RD,             // bus read
	output reg        WR,             // bus write
	output reg [ 3:0] BE,             // byte enable
	output reg [31:0] DATAI,          // data input
	input      [31:0] DATAO,          // data output
	input             IRQ,            // interrupt req
	
	output reg [7:0] led_out
);

localparam
	STATE_Whoami = 4'd0,
	STATE_Whoami_Wait = 4'd1,
	STATE_Init = 4'd2,
	STATE_Init_Wait = 4'd3,
	STATE_Init1 = 4'd4,
	STATE_Init1_Wait = 4'd5,
	STATE_Init2 = 4'd6,
	STATE_Init2_Wait = 4'd7,
	STATE_Read = 4'd8,
	STATE_Read_Wait = 4'd9,
	STATE_LEDout = 4'd10,
	STATE_Halt = 4'd15;
	
reg [3:0] state;

localparam
	DEBUG_0 = 8'hff,
	DEBUG_1 = 8'hfe,
	DEBUG_2 = 8'hfd,
	DEBUG_3 = 8'hfb,
	DEBUG_4 = 8'hf7,
	DEBUG_5 = 8'hef,
	DEBUG_6 = 8'hdf,
	DEBUG_7 = 8'hbf,
	DEBUG_8 = 8'h7f;
	
localparam expected_who_am_i = 8'h33;
`ifdef SIMULATION
localparam expected_HIZ = 8'hzz;
`else
localparam expected_HIZ = 8'hff;
`endif
reg signed [7:0] saved_acc;
`ifdef SIMULATION
reg [15:0] expdat = 16'h9a00;
`endif
`ifdef SPI_POLLING
reg [4:0] poll_ws = 0;
`define POLL_SIZE -1
//`define POLL_SIZE 0
`endif

always @(posedge clk_in or negedge nrst)
	if (nrst == 0) begin
		led_out <= DEBUG_0;
		state <= STATE_Whoami;
		
		DATAI <= 32'b0;
		BE <= 4'b0;
		RD <= 0;
		WR <= 0;
`ifdef SPI_POLLING
		poll_ws = 0;
`endif
		
		saved_acc <= 8'b0;
`ifdef SIMULATION
		x_l_response <= 8'b0;
`endif
	end else begin
		case (state)
			// 1. Read WHO_AM_I register (Addr 0x0F)
			STATE_Whoami: begin
				led_out <= DEBUG_1;
`ifdef SPI_POLLING
				if (poll_ws > 0) begin
				poll_ws <= poll_ws - 1;
				end else begin
				RD <= 1;
				BE <= 4'b1000;
				end
				if (RD) begin
				RD <= 0;
				if (DATAO[24+0] == 0) begin
`endif
				WR <= 1;
				BE <= 4'b0011;
				DATAI <= 31'b10001111_00000000;
`ifndef SPI_POLLING
				if (IRQ) begin
`endif
				state <= STATE_Whoami_Wait;
`ifdef SPI_POLLING
				end else begin
				poll_ws <= `POLL_SIZE;
				end
`endif
				end
			end
			STATE_Whoami_Wait: begin
				led_out <= DEBUG_2;
				WR <= 0;
`ifdef SPI_POLLING
				if (poll_ws > 0) begin
				poll_ws <= poll_ws - 1;
				end else begin
`else
				if (~IRQ) begin
				if (~RD) begin
`endif
				RD <= 1;
				BE <= 4'b0011;
				end
				if (RD) begin
					RD <= 0;
`ifdef SPI_POLLING
				if (DATAO[8+1] == 1) begin
`endif
					if (DATAO[7:0] != expected_who_am_i) begin
						state <= STATE_Halt;
`ifdef SIMULATION
						$display("Bad Whoami response: %02x (expected %02x)", DATAO[7:0], expected_who_am_i);
						$fatal(1);
`endif
					end else begin
						state <= STATE_Init;
					end
`ifdef SPI_POLLING
				end else begin
				poll_ws <= `POLL_SIZE;
`endif
				end
				end
			end
			// 2. Write ODR in CTRL_REG1 (Addr 0x20)
			STATE_Init: begin
				led_out <= DEBUG_3;
`ifdef SPI_POLLING
				if (poll_ws > 0) begin
				poll_ws <= poll_ws - 1;
				end else begin
				RD <= 1;
				BE <= 4'b1000;
				end
				if (RD) begin
				RD <= 0;
				if (DATAO[24+0] == 0) begin
`endif
				WR <= 1;
				BE <= 4'b0011;
				DATAI <= 31'b00100000_01110111;
`ifndef SPI_POLLING
				if (IRQ) begin
`endif
				state <= STATE_Init_Wait;
`ifdef SPI_POLLING
				end else begin
				poll_ws <= `POLL_SIZE;
				end
`endif
				end
			end
			STATE_Init_Wait: begin
				led_out <= DEBUG_4;
				WR <= 0;
`ifdef SPI_POLLING
				if (poll_ws > 0) begin
				poll_ws <= poll_ws - 1;
				end else begin
`else
				if (~IRQ) begin
				if (~RD) begin
`endif
				RD <= 1;
				BE <= 4'b0011;
				end
				if (RD) begin
					RD <= 0;
`ifdef SPI_POLLING
				if (DATAO[8+1] == 1) begin
`endif
					if (DATAO[7:0] != expected_HIZ) begin
						state <= STATE_Halt;
`ifdef SIMULATION
						$display("Bad Ctrlreg1 response: %02x (expected %02x)", DATAO[7:0], expected_HIZ);
						$fatal(1);
`endif
					end else begin
						state <= STATE_Init1;
					end
`ifdef SPI_POLLING
				end else begin
				poll_ws <= `POLL_SIZE;
`endif
				end
				end
			end
			// 3. Enable temperature sensor (Addr 0x1F)
			STATE_Init1: begin
				led_out <= DEBUG_5;
`ifdef SPI_POLLING
				if (poll_ws > 0) begin
				poll_ws <= poll_ws - 1;
				end else begin
				RD <= 1;
				BE <= 4'b1000;
				end
				if (RD) begin
				if (DATAO[24+0] == 0) begin
				RD <= 0;
`endif
				WR <= 1;
				BE <= 4'b0011;
				DATAI <= 31'b00011111_11000000;
`ifndef SPI_POLLING
				if (IRQ) begin
`endif
				state <= STATE_Init1_Wait;
`ifdef SPI_POLLING
				end else begin
				poll_ws <= `POLL_SIZE;
				RD <= 0;
				end
`endif
				end
			end
			STATE_Init1_Wait: begin
				led_out <= DEBUG_6;
				WR <= 0;
`ifdef SPI_POLLING
				if (poll_ws > 0) begin
				poll_ws <= poll_ws - 1;
				end else begin
`else
				if (~IRQ) begin
				if (~RD) begin
`endif
					RD <= 1;
					BE <= 4'b0011;
				end
				if (RD) begin
					RD <= 0;
`ifdef SPI_POLLING
				if (DATAO[8+1] == 1) begin
`endif
					if (DATAO[7:0] != expected_HIZ) begin
						state <= STATE_Halt;
`ifdef SIMULATION
						$display("Bad Tempcfgreg response: %02x (expected %02x)", DATAO[7:0], expected_HIZ);
						$fatal(1);
`endif
					end else begin
						state <= STATE_Init2;
					end
`ifdef SPI_POLLING
				end else begin
				poll_ws <= `POLL_SIZE;
`endif
				end
				end
			end
			// 4. Enable BDU, High resolution (Addr 0x23)
			STATE_Init2: begin
				led_out <= DEBUG_7;
`ifdef SPI_POLLING
				if (poll_ws > 0) begin
				poll_ws <= poll_ws - 1;
				end else begin
				RD <= 1;
				BE <= 4'b1000;
				end
				if (RD) begin
				if (DATAO[24+0] == 0) begin
				RD <= 0;
`endif
				WR <= 1;
				BE <= 4'b0011;
				DATAI <= 31'b00100011_10001000;
`ifndef SPI_POLLING
				if (IRQ) begin
`endif
				state <= STATE_Init2_Wait;
`ifdef SPI_POLLING
				end else begin
				poll_ws <= `POLL_SIZE;
				RD <= 0;
				end
`endif
				end
			end
			STATE_Init2_Wait: begin
				led_out <= DEBUG_8;
				WR <= 0;
`ifdef SPI_POLLING
				if (poll_ws > 0) begin
				poll_ws <= poll_ws - 1;
				end else begin
`else
				if (~IRQ) begin
				if (~RD) begin
`endif
				RD <= 1;
				BE <= 4'b0011;
				end
				if (RD) begin
					RD <= 0;
`ifdef SPI_POLLING
				if (DATAO[8+1] == 1) begin
`endif
					if (DATAO[7:0] != expected_HIZ) begin
						state <= STATE_Halt;
`ifdef SIMULATION
						$display("Bad Ctrlreg4 response: %02x (expected %02x)", DATAO[7:0], expected_HIZ);
						$fatal(1);
`endif
					end else begin
						state <= STATE_Read;
`ifdef SIMULATION
						//$display("STATE_Init2_Wait => STATE_Read DATAO=%08x", DATAO);
`endif
					end
`ifdef SPI_POLLING
				end else begin
				poll_ws <= `POLL_SIZE;
`endif
				end
				end
			end
			// 5. Read OUT_X_L (Addr 0x28)
			STATE_Read: begin
`ifdef SIMULATION
				x_l_response <= expdat;
`endif
`ifdef SPI_POLLING
				if (poll_ws > 0) begin
				poll_ws <= poll_ws - 1;
				end else begin
				RD <= 1;
				BE <= 4'b1000;
				end
				if (RD) begin
				if (DATAO[24+0] == 0) begin
				RD <= 0;
`endif
				WR <= 1;
				BE <= 4'b1111;
				DATAI <= 31'b11101000_00000000_00000000;//28: OUT_X_L
`ifndef SPI_POLLING
				if (IRQ) begin
`endif
					state <= STATE_Read_Wait;
`ifdef SIMULATION
					//$display("STATE_Read => STATE_Read_Wait");
`endif
`ifdef SPI_POLLING
				end else begin
				poll_ws <= `POLL_SIZE;
				RD <= 0;
				end
`endif
				end
			end
			STATE_Read_Wait: begin
				WR <= 0;
`ifdef SPI_POLLING
				if (poll_ws > 0) begin
				poll_ws <= poll_ws - 1;
				end else begin
`else
				if (~IRQ) begin
				if (~RD) begin
`endif
					RD <= 1;
					BE <= 4'b1111;
				end
				if (RD) begin
					RD <= 0;
`ifdef SPI_POLLING
				if (DATAO[16+1] == 1) begin
`endif
`ifdef SIMULATION
					if ({DATAO[7:0], DATAO[15:8]} != expdat) begin
						state <= STATE_Halt;
						$display("Bad Read response: %04x (wanted %04x) DATAO=%08x", DATAO[15:0], expdat, DATAO);
						$fatal(1);
						//$display("STATE_Read_Wait => STATE_LEDout - spi_miso_data=%02x", spi_miso_data);
					end else begin
						expdat[15:8] <= expdat[15:8] + 32;
`endif
						state <= STATE_LEDout;
						//saved_acc <= DATAO[15:8];
						saved_acc <= DATAO[7:0];
						//led_out <= DATAO[7:0];
`ifdef SIMULATION
					end
`endif
`ifdef SPI_POLLING
				end else begin
				poll_ws <= `POLL_SIZE;
`endif
				end
				end
			end
			// 6. Set LED output according to accelerometer value
			STATE_LEDout: begin
				state <= STATE_Read;
`ifdef SIMULATION
				//$display("STATE_LEDout => STATE_Read - saved_acc=%02x", saved_acc);
`endif
				led_out <= 1 << ((saved_acc + 8'Sb1000_0000) >> 5);
				//led_out <= saved_acc;
			end
			STATE_Halt: begin
				// Do nothing
			end
		endcase
	end
endmodule
