`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:40:27 07/21/2015
// Design Name:   check_receive_window
// Module Name:   C:/Users/pengyou/Desktop/RT-switch/xilinx_10.1/switch_reference_2_1_2/check_receive_window/testbench_check_receive_window.v
// Project Name:  check_receive_window
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: check_receive_window
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module testbench_check_receive_window;

	// Inputs
	reg clk;
	reg rst_n;
	reg [63:0] in_tt_data;
	reg [7:0] in_tt_ctrl;
	reg in_tt_wr;
	reg in_buffer_rdy;
	reg in_table_wr;
	reg [15:0] in_port_number;
	reg [15:0] in_buffer_number;
	reg [63:0] in_window_start;
	reg [63:0] in_window_end;
	reg [63:0] in_global_time;
	reg [15:0] in_flow_id;

	// Outputs
	wire [63:0] out_buffer_data;
	wire [7:0] out_buffer_ctrl;
	wire out_buffer_wr;
	wire out_tt_rdy;
	wire [3:0] out_switch_port;
	wire [3:0] out_switch_buffer;
	wire out_table_rdy;
	wire [2:0] cstate;
	wire [15:0] temp_port_number;
	wire [3:0] temp_buffer_number;
	wire [63:0] temp_window_start;
	wire [63:0] temp_window_end;
	wire wait_table;
	wire wait_time;
	wire wait_data;
	wire drop_data;

	// Instantiate the Unit Under Test (UUT)
	check_receive_window uut (
		.clk(clk), 
		.rst_n(rst_n), 
		.in_tt_data(in_tt_data), 
		.in_tt_ctrl(in_tt_ctrl), 
		.in_tt_wr(in_tt_wr), 
		.in_buffer_rdy(in_buffer_rdy), 
		.in_table_wr(in_table_wr), 
		.in_port_number(in_port_number), 
		.in_buffer_number(in_buffer_number), 
		.in_window_start(in_window_start), 
		.in_window_end(in_window_end), 
		.in_global_time(in_global_time), 
		.in_flow_id(in_flow_id), 
		.out_buffer_data(out_buffer_data), 
		.out_buffer_ctrl(out_buffer_ctrl), 
		.out_buffer_wr(out_buffer_wr), 
		.out_tt_rdy(out_tt_rdy), 
		.out_switch_port(out_switch_port), 
		.out_switch_buffer(out_switch_buffer), 
		.out_table_rdy(out_table_rdy), 
		.cstate(cstate), 
		.temp_port_number(temp_port_number), 
		.temp_buffer_number(temp_buffer_number), 
		.temp_window_start(temp_window_start), 
		.temp_window_end(temp_window_end), 
		.wait_table(wait_table), 
		.wait_time(wait_time), 
		.wait_data(wait_data), 
		.drop_data(drop_data)
	);
reg [63:0] count;
	initial begin
		// Initialize Inputs
		in_flow_id = 0;
		count = 1;
		clk = 0;
		rst_n = 1;
		in_tt_data = 0;//48 is ok
		in_tt_ctrl = 0;
		in_tt_wr = 1;
		in_buffer_rdy = 1;
		in_table_wr = 0;
		in_port_number = 3;
		in_buffer_number = 2;
		in_window_start = 10;
		in_window_end = 50;
		in_global_time = 0;

		// Wait 100 ns for global reset to finish
		#100;
      forever begin
		#4 clk = ~clk;
		#1
		in_tt_data = in_tt_data + 1;
		in_tt_ctrl = 0;
		in_tt_wr = 0;
		in_table_wr = out_table_rdy;
		count = count + 1;
		in_global_time = in_global_time+1;
		if(out_tt_rdy == 1) begin
		in_tt_wr = 1;
		end
		if(in_tt_data % 10 == 0)begin
		in_tt_ctrl = 1;
		end
		if(out_table_rdy == 1 ) begin
		in_window_start = in_window_start + 1;
		in_window_end = in_window_end + 1;
		end
		#4 clk = ~clk;
		#1 ;
		end
		// Add stimulus here

	end
      
endmodule

