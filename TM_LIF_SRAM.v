`timescale  	1ns/1ns

module TM_LIF_SRAM (reset_n,
		    clk_in,
                    LIF_spike,
		    leak_rate,
		    charge_rate,
		    Vrst,
		    Vth,
		    syn_i);
	   
input 				reset_n;
input				clk_in;
input	[8:0]			leak_rate;
input	[8:0]			charge_rate;
input	[8:0]			Vrst;
input	[9:0]			Vth;
input	[9:0]			syn_i;
output				LIF_spike;

reg	[9:0]			vmem_buf_raddr[4:0];
reg	[9:0]			vmem_buf_waddr;
reg				vmem_buf_wr;
reg	[2:0]			init_cnt;
wire	[9:0]			vmem_buf_rdata;
wire	[9:0]			vmem_buf_wdata;
//@0
always@(posedge clk_in or negedge reset_n)
begin
	if (~reset_n)
		vmem_buf_raddr[0] <= #1 'b0;
	else
		vmem_buf_raddr[0] <= #1 vmem_buf_raddr[0] + 1'b1;
end
//@1
always@(posedge clk_in or negedge reset_n)
begin
	if (~reset_n)
                vmem_buf_raddr[1] <= #1 'b0;
	else
		vmem_buf_raddr[1] <= #1 vmem_buf_raddr[0];
end
//@2
always@(posedge clk_in or negedge reset_n)
begin
	if (~reset_n)
                vmem_buf_raddr[2] <= #1 'b0;
        else
        	vmem_buf_raddr[2] <= #1 vmem_buf_raddr[1];
end
//@3
always@(posedge clk_in or negedge reset_n)
begin
	if (~reset_n)
                vmem_buf_raddr[3] <= #1 'b0;
        else
        	vmem_buf_raddr[3] <= #1 vmem_buf_raddr[2];
end
//@4
always@(posedge clk_in or negedge reset_n)
begin
	if (~reset_n)
                vmem_buf_raddr[4] <= #1 'b0;
        else
        	vmem_buf_raddr[4] <= #1 vmem_buf_raddr[3];
end
//@5
always@(posedge clk_in or negedge reset_n)
begin
	if (~reset_n)
                vmem_buf_waddr <= #1 'b0;
        else
		vmem_buf_waddr <= #1 vmem_buf_raddr[4];
end
//@5
always@(posedge clk_in or negedge reset_n)
begin
        if (~reset_n)
                vmem_buf_wr <= #1 1'b0;
        else if ( init_cnt == 3'd4 )
                vmem_buf_wr <= #1 1'b1;
	else
		vmem_buf_wr <= #1 1'b0;
end
//@5
always@(posedge clk_in or negedge reset_n)
begin
        if (~reset_n)
                init_cnt <= #1 'b0;
        else if ( init_cnt < 3'd4 )
                init_cnt <= #1 init_cnt + 1'b1;
	else
		init_cnt <= #1 init_cnt;
end

DPRAM_1Kx10bit U_VMEM_BUF (.aclr(~reset_n),
                           .rdaddress(vmem_buf_raddr[0]),	//@0
                           .wraddress(vmem_buf_waddr),	
                           .clock(clk_in),
                           .data(vmem_buf_wdata),	//@2+3
                           .wren(vmem_buf_wr),
                           .q(vmem_buf_rdata));		//@2

TM_LIF U_TM_LIF (//.reset_n(reset_n),
		 .clk_in(clk_in),
                 .LIF_spike(LIF_spike),
		 .leak_rate(leak_rate),
		 .charge_rate(charge_rate),
		 .Vrst(Vrst),
		 .Vth(Vth),
		 .syn_i(syn_i),
		 .vmem_i(vmem_buf_rdata),
		 .vmem_o(vmem_buf_wdata));
	 
endmodule
