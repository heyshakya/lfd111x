// AND Gate Example

\TLV_version 1d: tl-x.org
\SV
   module top(  input wire clk, input wire reset, input wire [31:0] cyc_cnt, 
                output wire passed, output wire failed);    
   /* verilator lint_save */ /* verilator lint_off UNOPTFLAT */  
   bit [256:0] RW_rand_raw; bit [256+63:0] RW_rand_vect; 
   pseudo_rand #(.WIDTH(257)) pseudo_rand (clk, reset, RW_rand_raw[256:0]); 
   assign RW_rand_vect[256+63:0] = {RW_rand_raw[62:0], RW_rand_raw};  
   /* verilator lint_restore */  /* verilator lint_off WIDTH */ 
   /* verilator lint_off UNOPTFLAT */
\TLV
   
   // Sample logical operators.
   // |: OR
   // &: AND
   // ^: XOR
   $out = $in1 & $in2;
   
\SV
endmodule

//---------------------------------------------------------------------------------------

// ADD Example

\TLV_version 1d: tl-x.org
\SV
   module top(  input wire clk, input wire reset, input wire [31:0] cyc_cnt, 
                output wire passed, output wire failed);    
   /* verilator lint_save */ /* verilator lint_off UNOPTFLAT */  
   bit [256:0] RW_rand_raw; 
   bit [256+63:0] RW_rand_vect; 
   pseudo_rand #(.WIDTH(257)) pseudo_rand (clk, reset, RW_rand_raw[256:0]); 
   assign RW_rand_vect[256+63:0] = {RW_rand_raw[62:0], RW_rand_raw};  
   /* verilator lint_restore */  /* verilator lint_off WIDTH */ 
   /* verilator lint_off UNOPTFLAT */
\TLV
   
   // Verilog arithmetic operators: +, -, *, /, %, etc.
   $out[7:0] = ($num1[3:0] + $num2[3:0]) - 1;
   
\SV
endmodule

//---------------------------------------------------------------------------------------

// MUX Example

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
   
   // Ternary operator:
   $num1[7:0] = $big ? 255 : 0;
   
   // Chained ternary operator:
   $num2[7:0] = $big ? 255 : $medium ? 100 : $small  ? 5 : 0;
\SV
endmodule

//---------------------------------------------------------------------------------------

// ALU Example

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
   // Stimulus
   $op[0:0] = *cyc_cnt[0];
   $num1[7:0] = *cyc_cnt[7:0];
   $num2[7:0] = *cyc_cnt[8:1];
   
   // Add when $op, else subtract.
   $rslt[7:0] = ($op == 1) ? $num1 + $num2 : $num1 - $num2;
   
   // Checking
   $Accum[7:0] <= *reset ? 0 : $Accum + $rslt;
   *passed = *cyc_cnt == 10 && $Accum == 45;
   *failed = *cyc_cnt > 20;
\SV
endmodule