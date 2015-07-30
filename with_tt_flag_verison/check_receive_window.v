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
		parameter OFFSET = 10,
		parameter WAIT_TABLE = 0,
		parameter CHECK_FLAG = 1,
		parameter CHECK_TIME = 0,
		parameter WAIT_DATA = 1,
		parameter DROP_DATA = 2,
		parameter CHECK_ID_LENGTH = 3
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
	input in_tt_flag,
	input [15:0] in_tt_length,
	output reg out_tt_flag_clear,
	output reg [63:0] out_buffer_data,
	output reg [7:0] out_buffer_ctrl,
	output reg out_buffer_wr,
	output reg out_tt_rdy,
	output reg [3:0] out_switch_port,
	output reg [3:0] out_switch_buffer,
	output reg out_table_rdy,
	//
	output reg state1,
	output reg [1:0] state2,
//	output reg [2:0] cstate,
//	output reg [2:0] nstate,
	output reg [15:0] temp_port_number,
	output reg [3:0] temp_buffer_number,
	output reg [63:0] temp_window_start,
	output reg [63:0] temp_window_end,
	output reg [15:0] temp_flow_id,
	output reg [15:0] temp_tt_length,
	output reg check_header_done
    );
	 
	 reg [63:0] temp_data [1:0];
	 reg [1:0] in_count;
	 reg [1:0] out_count;
	 reg empty;
	
	initial begin
	check_header_done = 0;
	empty = 1;
	in_count = 0;
	out_count = 0;
	out_table_rdy = 0;
	state1 = WAIT_TABLE;
	state2 = CHECK_TIME;
	out_table_rdy = 0;
	temp_port_number = 0;
	temp_buffer_number = 0;
	temp_window_start = 0;
	temp_window_end = 0;
	temp_flow_id = 0;
	temp_tt_length = 0;
	out_tt_flag_clear = 0;
	end

	always @(posedge clk or negedge rst_n)begin//decide wheter or not
	if(!rst_n)begin
		out_table_rdy <= 0;
		empty <= 1;
		state1 <= WAIT_TABLE;
		temp_port_number <= 0;
		temp_buffer_number <= 0;
		temp_window_start <= 0;
		temp_window_end <= 0;
		temp_flow_id <= 0;
		temp_tt_length <= 0;
		out_tt_flag_clear <= 0;
		end
	else begin
	case(state1)
	WAIT_TABLE:begin
		out_tt_flag_clear <= 0;
		if(in_table_wr == 1)begin
		empty <= 0;
		temp_port_number <= in_port_number;
		temp_buffer_number <= in_buffer_number;
		temp_window_start <= in_window_start;
		temp_window_end <= in_window_end;
		temp_tt_length <= in_tt_length;
		temp_flow_id <= in_flow_id;
		state1 <= CHECK_FLAG;
		out_table_rdy <= 0;
		end
		else begin
		out_table_rdy <= 1;
		end
	end
	CHECK_FLAG:begin
		if(in_global_time >= temp_window_end + OFFSET)begin
			if(in_tt_flag == 0)begin
				state1 <= WAIT_TABLE;
			end
			else begin
				if(check_header_done == 1)begin
					out_tt_flag_clear <= 1;
					state1 <= WAIT_TABLE;
				end
			end
		end
	end
	endcase
	end
	end

	always @(posedge clk or negedge rst_n)begin//decide whether data is valid or not
	if(!rst_n)begin
		state2 <= CHECK_TIME;
		in_count <= 0;
		out_count <= 0;
		check_header_done <= 0;
		end
	else
	case(state2)
	CHECK_TIME:begin
	if(empty == 1) ;
	else begin
			if(in_count == 2 )begin
				if(temp_data[0] >= temp_window_start && temp_data[0] <= temp_window_end)begin
				check_header_done <= 1;
				state2 <= CHECK_ID_LENGTH;
				in_count <= 0;
				end
				else begin
				state2 <= DROP_DATA;
				in_count <= 0;
				end
			end
			else if(in_count == 1)begin
				if(in_tt_wr == 1)begin
				temp_data[in_count] <= in_tt_data;
				in_count <= 2;
				out_count <= 0;
				check_header_done <= 0;
				end
			end
			else begin
				if(in_tt_wr == 1)begin
				check_header_done <= 0;
				out_count <= 0;
				temp_data[in_count] <= in_tt_data;
				in_count <= 1;
				end
			end
	end
end
	CHECK_ID_LENGTH: begin
		if(temp_data[1][63:48] == temp_flow_id && temp_data[1][47:32] == temp_tt_length)begin
		out_count <= 0;
		state2 <= WAIT_DATA;
		check_header_done <= 1;
		end
		else begin
		in_count <= 0;
		state2 <= DROP_DATA;
		end
end
	DROP_DATA:begin
		if(in_tt_ctrl == 1) state2 <= CHECK_TIME;
	end
	WAIT_DATA:begin
		if(out_count == 2) out_count <= 3;
		if(out_count == 1) out_count <= 2;
		else if(out_count == 0) out_count <= 1;
		else begin
		if(in_tt_ctrl == 1) begin
				state2 <= CHECK_TIME;
			end
			else ;
		end
	end
	endcase
	end
	
	always @(state2 or temp_data[0] or temp_data[1] or empty or out_count or temp_port_number or temp_buffer_number or in_buffer_rdy or in_tt_data or in_tt_ctrl or in_tt_wr ) begin
	case(state2)
	CHECK_TIME: 
	begin
		if(in_count == 0) out_tt_rdy <= 1;
		else out_tt_rdy <= 0;
		out_buffer_data <= 0;
		out_buffer_ctrl <= 0;
		out_buffer_wr <= 0;
		out_switch_port <= 0;
		out_switch_buffer <= 0;
	end
	CHECK_ID_LENGTH:begin
		out_tt_rdy <= 0;
		out_buffer_data <= 0;
		out_buffer_ctrl <= 0;
		out_buffer_wr <= 0;
		out_switch_port <= 0;
		out_switch_buffer <= 0;
	end
	WAIT_DATA: begin
	if(out_count == 0) begin
		out_tt_rdy <= 0;
		out_buffer_data <= 0;
		out_buffer_ctrl <= 0;
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
	else if(out_count <= 2)begin
	out_tt_rdy <= 0;
	out_buffer_data <= temp_data[out_count-1];
	out_buffer_ctrl <= 0;
	out_buffer_wr <= 1;
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
	default: begin
		out_tt_rdy <= 0;
		out_buffer_data <= 0;
		out_buffer_ctrl <= 0;
		out_buffer_wr <= 0;
		out_switch_port <= 0;
		out_switch_buffer <= 0;
	end
	endcase
	end

	
endmodule
