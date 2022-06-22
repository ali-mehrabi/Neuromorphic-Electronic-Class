`timescale 1ns / 1ps

module LIF_tb ();

parameter	CLK_PD = 10;

parameter   Cycle_per_sec = 15; 

reg                     clk_in;
reg                     reset_n;
reg	[13:0]		tau;
reg	[14:0]		charge_rate;
reg	[13:0]		Vrst;
reg	[13:0]		Vth;

wire			post_spike;
reg	[6:0]			sec_cnt;
reg	[5:0]		   cycle_cnt;	
reg	[14:0]		IHC_out;
reg	[23:0]		address_ihc;

reg	[14:0]	IHC	[0:50*60000 -1];
//reg	[14:0]	IHC	[0:19];

wire	[13:0]	syn_to_LIF;

wire    [13:0]           data_to_LIF;
wire    [13:0]           data_from_LIF;
wire			LIF_buf_wren;
wire    [9:0]           LIF_buf_raddr;
wire    [9:0]           LIF_buf_waddr;
reg     [5:0]           LIF_cnt;
reg     [6:0]           channel_cnt;

reg	 [13:0]				test_ram[0:499];
initial 
begin
$readmemh("c:/LIF_MONE/1.txt", IHC);
end


//first clock,cyc_cnt,  for counting how many cycles it needs to finish one section (15 cycles for each section)
always@(posedge clk_in or negedge reset_n)
begin
        if ( !reset_n )

                cycle_cnt <= #1 'd0;

        else if (cycle_cnt == Cycle_per_sec )

						 cycle_cnt <= #1 'd0  ;
               
			else
			
					 
					 cycle_cnt <= #1  cycle_cnt + 'd1;
	       
end

//second clock,sec_cnt, for counting how many cycles it needs to finish one sample (10 cycles * 50 section = 500 cycles )
always@(posedge clk_in or negedge reset_n)
begin
        if ( !reset_n )
                sec_cnt <= #1 'd0;
					 
        else if (cycle_cnt == Cycle_per_sec )
		 
		if( sec_cnt == 'd49 )

			sec_cnt <= #1 'd0  ;
			
		else
			sec_cnt <= #1  sec_cnt + 'd1;
 
	 else
		 sec_cnt <= #1  sec_cnt;
end

//IHC_reg value 
always@(posedge clk_in or negedge reset_n)
begin
        if ( !reset_n )
		  
                address_ihc <= #1 'd0;

		  else if (cycle_cnt == Cycle_per_sec)
		  
		  
					 address_ihc  <= #1 address_ihc +1'd 1;
		 else
					address_ihc  <= address_ihc ;
end




always@(posedge clk_in or negedge reset_n)
begin
        if ( !reset_n )
                IHC_out <= #1 'd0;

		  else
					 IHC_out <=  #1 IHC[address_ihc];
end

assign syn_to_LIF = IHC_out[13:0];

initial
begin
        clk_in = 1;
	reset_n = 1;
	tau = 'd74;	//10ms
	charge_rate = 'd16309; //10ms
	Vrst = 13'd0;
	Vth = 13'd3;
	//syn_to_LIF = 13'd1234;
        #2
        reset_n = 0;
        #1000
        reset_n = 1;
end



always
begin
        #CLK_PD clk_in = ~clk_in;
end


endmodule
