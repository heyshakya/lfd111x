// Fibonacci Sequence Example

\TLV_version 1d: tl-x.org
\SV
   module top(input wire clk, input wire reset, input wire [31:0] cyc_cnt, 
                output wire passed, output wire failed);    
    /* verilator lint_save */ /* verilator lint_off UNOPTFLAT */  
    bit [256:0] RW_rand_raw; bit [256+63:0] RW_rand_vect; 
    pseudo_rand #(.WIDTH(257)) pseudo_rand (clk, reset, RW_rand_raw[256:0]); 
    assign RW_rand_vect[256+63:0] = {RW_rand_raw[62:0], RW_rand_raw};  
    /* verilator lint_restore */  /* verilator lint_off WIDTH */ 
    /* verilator lint_off UNOPTFLAT */
\TLV
   $num[15:0] = *reset ? 1 /* 1 if reset */ : >>1$num + >>2$num;  /* otherwise add previous two */
\SV
   endmodule

//------------------------------------------------------------------------------------------

// Counter Example

\TLV_version 1d: tl-x.org
\SV
   module top(input wire clk, input wire reset, input wire [31:0] cyc_cnt, 
                output wire passed, output wire failed);    
    /* verilator lint_save */ /* verilator lint_off UNOPTFLAT */  
    bit [256:0] RW_rand_raw; bit [256+63:0] RW_rand_vect; 
    pseudo_rand #(.WIDTH(257)) pseudo_rand (clk, reset, RW_rand_raw[256:0]); 
    assign RW_rand_vect[256+63:0] = {RW_rand_raw[62:0], RW_rand_raw};  
    /* verilator lint_restore */  /* verilator lint_off WIDTH */ 
    /* verilator lint_off UNOPTFLAT */
\TLV
   $num[15:0] = *reset ? 0 /* 0 if reset */ : >>1$num + 1;  /* otherwise add one to previous number */
\SV
   endmodule