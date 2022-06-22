`timescale 1ns / 1ps

module LIF_tb();

parameter	CLK_PD = 10;

reg                     clk_in;
reg                     reset_n;
reg	[13:0]		tau;
reg	[13:0]		charge_rate;
reg	[13:0]		Vrst;
reg	[13:0]		Vth;
reg	[13:0]		syn_to_LIF;
reg	[19:0]		LFSR_gen;
wire    [13:0]          LIF_state;
wire			post_spike;

initial
begin
        clk_in = 1;
	reset_n = 1;
	tau = 14894;	//10ms
	charge_rate = 14894; //10ms
	Vrst = 13'h0;
	Vth = 13'h1F00;
	//syn_to_LIF = 13'd1234;
        #2
        reset_n = 0;
        #1000
        reset_n = 1;
end

always@(*)
begin
	syn_to_LIF[13:0] = LFSR_gen[13:0];
end

always@(posedge clk_in or negedge reset_n)
begin
        if ( !reset_n )
                LFSR_gen <= #1 20'd8964;
        else
                LFSR_gen <= #1 {LFSR_gen[18:3],LFSR_gen[2]^LFSR_gen[19],LFSR_gen[1:0],LFSR_gen[19]};
end

always
begin
        #CLK_PD clk_in = ~clk_in;
end

DS_LIF U_LIF (.reset_n(reset_n),
              .clk_in(clk_in),
              .post_spike(post_spike),
              .tau(tau),
              .charge_rate(charge_rate),
              .Vrst(Vrst),
              .Vth(Vth),
              .syn_i(syn_to_LIF[13:0]),
              .data_i(LIF_state),
              .data_o(LIF_state));

endmodule
