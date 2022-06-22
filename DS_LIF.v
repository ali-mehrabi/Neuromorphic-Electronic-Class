`timescale  	1ns/1ns
 
module DS_LIF     (reset_n,
		   clk_in,
                   post_spike,
		   tau,
		   charge_rate,
		   Vrst,
		   Vth,
		   syn_i,
		   data_i,
		   data_o);

parameter	tau_w	= 14;
parameter	Vrst_w	= 14;
parameter	Vth_w	= 14;

input 			reset_n;
input			clk_in;
input	[tau_w-1:0]	tau;
input	[tau_w-1:0]	charge_rate;
input	[Vrst_w-1:0]	Vrst;
input	[Vrst_w -1:0]	Vth;
input	[13:0]		syn_i;
input	[13:0]		data_i;
output	[13:0]		data_o;
output			post_spike;

reg	[2*tau_w-1:0]	reg_LIFa;	
reg	[2*tau_w-1:0]	reg_LIFb;	
reg	[2*tau_w-1:0]	reg_LIF;	
reg	[tau_w-1:0]	data_o;	
reg			post_spike;

always@(posedge clk_in or negedge reset_n)
begin
	if(!reset_n)
		reg_LIFa <= #1 'd0;
	else
		reg_LIFa <= #1	charge_rate*data_i;
end

always@(posedge clk_in or negedge reset_n)
begin
	if(!reset_n)
		reg_LIFb <= #1 'd0;
	else
		reg_LIFb <= #1	tau*syn_i;
end

always@(posedge clk_in or negedge reset_n)
begin
	if(!reset_n)
		reg_LIF <= #1 'd0;
	else
		reg_LIF <= #1 reg_LIFa + reg_LIFb;
end

always@(posedge clk_in or negedge reset_n)
begin
	if(!reset_n)
		post_spike <= #1 'd0;
	else if ( reg_LIF[27:14] >= Vth )
		post_spike <= #1 'd1;
	else
		post_spike <= #1 'd0;
end

always@(posedge clk_in or negedge reset_n)
begin
	if(!reset_n)
		data_o <= #1 'd0;
	else if( reg_LIF[27:14] >= Vth )
		data_o <= #1 Vrst;
	else
		data_o <= #1 reg_LIF[27:14];
end

endmodule
