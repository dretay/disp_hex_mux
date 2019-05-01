//////////////////////////////////////////////// 
// disp_hex_mux
`include "seven_segment.v"
`include "SPI_slave.v"

module disp_hex_mux
	//IO ports
	(
		input wire CLK_12_MHZ,				
		output reg [5:0] an, //enable
		output reg [7:0] sseg, //led segments
		input wire sck, mosi, ssel,		
		output wire miso,
		output reg [4:0] leds,
	);

// ------ Design implementation ------

//generates a 1ms "tick" and iterate over each display element sequentially
localparam SEGMENTS = 6;
localparam DVSR = 12000/(SEGMENTS);
reg [22:0] ms_reg;
wire [22:0] ms_next;
wire ms_tick;
wire d0_en;
wire [3:0] d0_next;
wire d0_tick;
reg [3:0] d0_reg;
always @(posedge CLK_12_MHZ) begin
	ms_reg <= ms_next;
	d0_reg <= d0_next;
end
assign ms_next = (ms_reg == DVSR) ? 4'b0 : ms_reg +1;
assign ms_tick = (ms_reg == DVSR) ? 1'b1 : 1'b0;
assign d0_en = ms_tick;
assign d0_next = (d0_en && d0_reg == (SEGMENTS-1)) ? 4'b0 : (d0_en)? d0_reg+1: d0_reg;

//on each clock cycle illuminate the appropriate digit and display the value at that index
reg [3:0] hex_in;
reg dp;
wire [3:0] hex5;
wire [3:0] hex4;
wire [3:0] hex3;
wire [3:0] hex2;
wire [3:0] hex1;
wire [3:0] hex0;
always @* begin
	case (d0_next)
		3'b000:
		begin
			an = 6'b111110;
			hex_in = hex0;
			dp = dp_in[0];
		end
		3'b001:
		begin
			an = 6'b111101;
			hex_in = hex1;
			dp = dp_in[1];
		end
		3'b010:
		begin
			an = 6'b111011;
			hex_in = hex2;
			dp = dp_in[2];
		end
		3'b011:
		begin
			an = 6'b110111;
			hex_in = hex3;
			dp = dp_in[3];
		end
		3'b100:
		begin
			an = 6'b101111;
			hex_in = hex4;
			dp = dp_in[4];
		end
		3'b101:
		begin
			an = 6'b011111;
			hex_in = hex5;
			dp = dp_in[5];
		end
	endcase
end

SEVEN_SEGMENT seven_segment(.sseg(sseg), .hex(hex_in), .dp(dp));


//setup a simple spi slave 
wire byteReceived;
wire[7:0] receivedData;
wire dataNeeded;
reg[7:0] dataToSend;
SPI_slave spi_slave(CLK_12_MHZ, sck, mosi, miso, ssel, byteReceived, receivedData, dataNeeded, dataToSend);

//simple state machine that expects the fist byte to be the digit to configure and the second byte to be the 
//hex value to display... [0x01 0x0a] would display "a" in on the first digit
parameter SPI_CMD_NONE = 3'h00;
parameter SEGMENT_0 = 3'h01;
parameter SEGMENT_1 = 3'h02;
parameter SEGMENT_2 = 3'h03;
parameter SEGMENT_3 = 3'h04;
parameter SEGMENT_4 = 3'h05;
parameter SEGMENT_5 = 3'h06;
reg [2:0] spi_cmd = SPI_CMD_NONE;
reg [2:0] spi_bytes_count = 0;

always @(posedge CLK_12_MHZ) begin
	if(byteReceived) begin		
  	if(spi_bytes_count==0) begin // first byte is command
			spi_bytes_count <= spi_bytes_count+1;	
      spi_cmd <= receivedData[2:0];      
	  end else begin // other bytes are command's data
	    case(spi_cmd)
	      SEGMENT_0: begin
	        hex0 <= receivedData[3:0];	     
	      end      
	      SEGMENT_1: begin    
	        hex1 <= receivedData[3:0];
	      end      
	      SEGMENT_2: begin    
	        hex2 <= receivedData[3:0];
	      end      
	      SEGMENT_3: begin    
	        hex3 <= receivedData[3:0];
	      end      
	      SEGMENT_4: begin    
	        hex4 <= receivedData[3:0];
	      end      
	      SEGMENT_5: begin
	        hex5 <= receivedData[3:0];
	      end                                
	      default: begin          
	        // unknown command
	      end
	    endcase	  
	    spi_bytes_count<=0;
	    spi_cmd <= SPI_CMD_NONE;		
		end
	end
end


endmodule