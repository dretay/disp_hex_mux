#name of the component
NAME = disp_hex_mux


#do simulation and synthesis
all: sim sint

#do simulation
sim: $(NAME)_tb.vcd

#do synthesis
sint: $(NAME).bin

view: 
	yosys -p "read_verilog $(NAME).v" -p"hierarchy -check;" -p"proc;" -p"opt;" -p"fsm;" -p"opt;" -p"show $(NAME);" 1>/dev/null

#compile and simulate
$(NAME)_tb.vcd: $(NAME).v $(NAME)_tb.v

	#compile
	iverilog -o $(NAME)_tb.out $(NAME).v $(NAME)_tb.v

	#simulate
	./$(NAME)_tb.out

	#visualize simulation
	gtkwave $(NAME)_tb.vcd $(NAME)_tb.gtkw &

#complete
$(NAME).bin: $(NAME).v $(NAME).pcf

	#synthesize
	yosys -p "synth_ice40 -blif $(NAME).blif" $(NAME).v

	#place & route
	arachne-pnr -d 1k -p $(NAME).pcf $(NAME).blif -o $(NAME).txt

	#build final binary
	icepack $(NAME).txt $(NAME).bin


#cleanup
clean:
	rm -f *.bin *.txt *.blif *.out *.vcd *~

.PHONY: all clean