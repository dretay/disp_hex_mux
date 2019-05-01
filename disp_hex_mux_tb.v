module disp_hex_mux_tb();


//-- register to generate the clock signal
reg CLK_12_MHZ = 0;
//-- clock generator with 2 cycle period
always # 0.0001 clk = ~clk;

// signal declaration
localparam DVSR = 120000;
localparam SEGMENTS = 5;
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
assign d0_next = (d0_en && d0_reg ==SEGMENTS) ? 4'b0 : (d0_en)? d0_reg+1: d0_reg;
assign d0_tick = (d0_reg == SEGMENTS) ? 1'b1: 1'b0;


//test vector generator
initial begin
	$dumpfile("disp_hex_mux_tb.vcd");
	$dumpvars(0, disp_hex_mux_tb);

	# 100 $finish;
end

endmodule

