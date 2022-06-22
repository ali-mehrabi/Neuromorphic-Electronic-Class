`timescale  	1ns/1ns
 
module  TM_LIF    (//reset_n,
		   clk_in,
                   LIF_spike,
		   leak_rate,
		   charge_rate,
		   Vrst,
		   Vth,
		   syn_i,
		   vmem_i,
		   vmem_o);

//input 				reset_n;
input				clk_in;
input	[8:0]			leak_rate;
input	[8:0]			charge_rate;
input	[8:0]			Vrst;
input	[9:0]			Vth;
input	[9:0]			syn_i;
input	[9:0]			vmem_i; //@0
output	[9:0]			vmem_o; //@3
output				LIF_spike;

reg		[1:0]		vmem_sign;
reg		[8:0]		vmem_rate;
reg		[17:0]		vmem_mlt_rlt;
reg 	signed 	[9:0]		signed_vmem;
reg 	signed 	[9:0]		signed_syn;
reg 	signed 	[10:0]		vmem_sum;
reg		[9:0]		vmem_o;
reg                             LIF_spike;
//0@1
//1@2
always@(posedge clk_in)
begin
	vmem_sign[1:0] <= #1 {vmem_sign[0],vmem_i[9]};
end
//@0
always@(*)
begin
	vmem_rate <= #1 ~vmem_i[9] ? leak_rate : charge_rate; 
end
//@1
always@(posedge clk_in)
begin
	vmem_mlt_rlt <= #1 vmem_rate*vmem_i[8:0];
end
//@1
always@(*)
begin
	signed_vmem = {1'b0,vmem_mlt_rlt[17:9]}; 
end
//@1
always@(posedge clk_in)
begin
	signed_syn <= #1 syn_i;
end
//@2
always@(posedge clk_in)
begin
	vmem_sum <= #1 ~vmem_sign[0] ? signed_syn + signed_vmem : vmem_mlt_rlt[17:9];
end
//@3
always@(posedge clk_in)
begin
	LIF_spike <= #1 ~vmem_sign[1] && ~vmem_sum[10] && vmem_sum[9:0] > Vth ? 1'b1 : 1'b0;
end
//@3
always@(posedge clk_in)
begin
	if ( ~vmem_sign[1] && ~vmem_sum[10] && vmem_sum[9:0] > Vth )
		vmem_o[9] <= #1 1'b1;
	else
		vmem_o[9] <= #1 vmem_mlt_rlt[17:9] == 9'b0 ? 1'b0 : vmem_sign[1];
end
//@3
always@(posedge clk_in)
begin
	vmem_o[8:0] <= #1 ( ~vmem_sign[1] && ~vmem_sum[10] && vmem_sum[9:0] > Vth ) ? Vrst : vmem_sum[8:0];
end

endmodule
