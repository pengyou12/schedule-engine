`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:53:03 07/17/2015 
// Design Name: 
// Module Name:    check-receive-window 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module check_receive_window#(
		parameter OFFSET = 100,
		parameter WAIT_TABLE = 0,
		parameter WAIT_TIME = 1,
		parameter WAIT_DATA = 2,
		parameter DROP_DATA = 3
		)
	(
	input clk,
	input rst_n,
	input [63:0] in_tt_data,
	input [7:0] in_tt_ctrl,
	input in_tt_wr,
	input in_buffer_rdy,
	input in_table_wr,
	input [15:0] in_port_number,
	input [15:0] in_buffer_number,
	input [63:0] in_window_start,
	input [63:0] in_window_end,
	input [63:0] in_global_time,
	input [15:0] in_flow_id,
	output reg [63:0] out_buffer_data,
	output reg [7:0] out_buffer_ctrl,
	output reg out_buffer_wr,
	output reg out_tt_rdy,
	output reg [3:0] out_switch_port,
	output reg [3:0] out_switch_buffer,
	output reg out_table_rdy,
	//
	output reg [2:0] cstate,
//	output reg [2:0] nstate,
	output reg [15:0] temp_port_number,
	output reg [3:0] temp_buffer_number,
	output reg [63:0] temp_window_start,
	output reg [63:0] temp_window_end,
	output reg wait_table,
	output reg wait_time,
	output reg wait_data,
	output reg drop_data
    );
	 
	 reg [63:0] temp_data [1:0];
	 reg [1:0] in_count;
	 reg [1:0] out_count;
	 
//	reg [2:0] cstate;
//	reg [2:0] nstate;
//	reg [15:0] temp_port_number;
//	reg [3:0] temp_buffer_number;
//	reg [63:0] temp_window_start;
//	reg [63:0] temp_window_end;
//	reg wait_table;
//	reg wait_time;
//	reg wait_data;
//	reg drop_data;
	
	initial begin
	in_count = 0;
	out_count = 0;
	wait_table = 1;
	out_table_rdy = 0;
	wait_time = 1;
	wait_data = 1;
	drop_data = 0;
	cstate = WAIT_TABLE;
	end
		
	always @(cstate or wait_table or wait_time or wait_data or drop_data or in_buffer_rdy or in_tt_data or in_tt_ctrl or in_tt_wr or temp_port_number or temp_buffer_number or out_count) begin
	case(cstate)
	WAIT_TABLE:	begin
		out_tt_rdy <= 0;
		out_buffer_data <= 0;
		out_buffer_ctrl <= 0;
		out_buffer_wr <= 0;
		out_switch_port <= 0;
		out_switch_buffer <= 0;
		end
	WAIT_TIME: 
	if(wait_time == 0)begin
		out_tt_rdy <= 0;
		out_buffer_data <= in_tt_data;
		out_buffer_ctrl <= in_tt_ctrl;
		out_buffer_wr <= 0;
		case(temp_port_number)
		1: out_switch_port <= 4'b0001;
		2: out_switch_port <= 4'b0010;
		3: out_switch_port <= 4'b0100;
		4: out_switch_port <= 4'b1000;
		default: out_switch_port <= 4'b0000;
		endcase
		out_switch_buffer <= temp_buffer_number;
		end
	else if(drop_data == 1)begin
		out_tt_rdy <= 1;
		out_buffer_data <= 0;
		out_buffer_ctrl <= 0;
		out_buffer_wr <= 0;
		out_switch_port <= 0;
		out_switch_buffer <= 0;
		end
	else begin
		out_tt_rdy <= 1;
		out_buffer_data <= 0;
		out_buffer_ctrl <= 0;
		out_buffer_wr <= 0;
		out_switch_port <= 0;
		out_switch_buffer <= 0;
		end
	WAIT_DATA: begin
	if(out_count < 2)begin
	out_tt_rdy <= 0;
	out_buffer_data <= temp_data[out_count];
	out_buffer_ctrl <= 0;
	if(in_count == 2) out_buffer_wr <= 1;
	else out_buffer_wr <= 0;
	case(temp_port_number)
		1: out_switch_port <= 4'b0001;
		2: out_switch_port <= 4'b0010;
		3: out_switch_port <= 4'b0100;
		4: out_switch_port <= 4'b1000;
		default: out_switch_port <= 4'b0000;
		endcase
		out_switch_buffer <= temp_buffer_number;
	end
	else begin
		out_tt_rdy <= in_buffer_rdy;
		out_buffer_data <= in_tt_data;
		out_buffer_ctrl <= in_tt_ctrl;
		out_buffer_wr <= in_tt_wr;
		//if(in_tt_ctrl == 1) out_buffer_wr <= 0;
		//else out_buffer_wr <= in_tt_wr;
		case(temp_port_number)
		1: out_switch_port <= 4'b0001;
		2: out_switch_port <= 4'b0010;
		3: out_switch_port <= 4'b0100;
		4: out_switch_port <= 4'b1000;
		default: out_switch_port <= 4'b0000;
		endcase
		out_switch_buffer <= temp_buffer_number;
		end
	end
	DROP_DATA:begin
		out_tt_rdy <= 1;
		out_buffer_data <= 0;
		out_buffer_ctrl <= 0;
		out_buffer_wr <= 0;
		out_switch_port <= 0;
		out_switch_buffer <= 0;
	end
	default: ;
	endcase
	end
	
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
		in_count <= 0;
		out_count <= 0;
		wait_table <= 1;
		wait_time <= 1;
		wait_data <= 1;
		drop_data <= 0;
		out_table_rdy <= 0;
		cstate <= WAIT_TABLE;
		end
		else begin
		case(cstate)
		WAIT_TABLE:	begin
			if(in_table_wr == 1)begin
			temp_port_number <= in_port_number;
			temp_buffer_number <= in_buffer_number;
			temp_window_start <= in_window_start;
			temp_window_end <= in_window_end;
			out_table_rdy <= 0;
			wait_table <= 0;
			wait_data <= 1;
			wait_time <= 1;
			drop_data <= 0;
			in_count <= 0;
			out_count <= 0;
			cstate <= WAIT_TIME;
			end
			else begin 
			out_table_rdy <= 1;
			end
		end
		WAIT_TIME:begin
		in_count <= 0;
		out_count <= 0;
		if(in_tt_wr == 1)begin
		temp_data[in_count] <= in_tt_data;
			if(in_tt_data >= temp_window_start && in_tt_data <= temp_window_end)
			begin
			wait_time <= 0;
			out_table_rdy <= 0;
			drop_data <= 0;
			cstate <= WAIT_DATA;
			out_table_rdy <= 0;
			in_count <= 1;
			end
			else begin
			cstate <= DROP_DATA;
			drop_data <= 1;
			end
		end
	end	
		DROP_DATA:begin
			if(in_tt_ctrl == 1) begin
				if(in_global_time > temp_window_end + OFFSET )begin
					wait_table <= 1;
					cstate <= WAIT_TABLE;
					out_table_rdy <= 0; 
				end
				else begin
				wait_time <= 1;
				in_count <= 0;
				out_count <= 0;
				cstate <= WAIT_TIME;
					end
				end
			else ;
		end
		WAIT_DATA:begin
		if(out_count == 1) out_count <= 2;
		if(in_count == 1) begin
		temp_data[in_count] <= in_tt_data;
		in_count <= 2;
		end
		else begin
		if(out_count == 0) out_count <= 1;
		else begin
		if(in_tt_ctrl == 1) begin
				wait_table <= 1;
				wait_time <= 1;
				wait_data <= 0;
				drop_data <= 0;
				cstate <= WAIT_TABLE;
				out_table_rdy <= 0;
			end
			else ;
		end
		end
	end
	endcase
	end	
end
		

endmodule
