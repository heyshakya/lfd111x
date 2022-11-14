// Pythagora’s Theorem Example

\TLV_version 1d: tl-x.org
\SV
   `include "sqrt32.v";
   module top(input wire clk, input wire reset, input wire [31:0] cyc_cnt, 
                output wire passed, output wire failed);    
    /* verilator lint_save */ /* verilator lint_off UNOPTFLAT */  
    bit [256:0] RW_rand_raw; bit [256+63:0] RW_rand_vect; 
    pseudo_rand #(.WIDTH(257)) pseudo_rand (clk, reset, RW_rand_raw[256:0]); 
    assign RW_rand_vect[256+63:0] = {RW_rand_raw[62:0], RW_rand_raw};  
    /* verilator lint_restore */  /* verilator lint_off WIDTH */ 
    /* verilator lint_off UNOPTFLAT */
\TLV
   
   |calc
      
      // Pythagora's Theorem
      @1
         $aa_sq[7:0] = $aa[3:0] ** 2;
         $bb_sq[7:0] = $bb[3:0] ** 2;
      // [+] @2
         $cc_sq[8:0] = $aa_sq + $bb_sq;
      // [+] @3
         $cc[4:0] = sqrt($cc_sq);


      // Print
         \SV_plus
            always_ff @(posedge clk) begin
               \$display("sqrt((\%2d ^ 2) + (\%2d ^ 2)) = \%2d", $aa, $bb, $cc);
            end

   // Stop simulation.
   *passed = *cyc_cnt > 40;
\SV
endmodule

//---------------------------------------------------------------------------------------

// 3 Stage Pipelined Pythagora’s Theorem Example

\TLV_version 1d: tl-x.org
\SV
   `include "sqrt32.v";
   module top(input wire clk, input wire reset, input wire [31:0] cyc_cnt, 
                output wire passed, output wire failed);    
    /* verilator lint_save */ /* verilator lint_off UNOPTFLAT */  
    bit [256:0] RW_rand_raw; bit [256+63:0] RW_rand_vect; 
    pseudo_rand #(.WIDTH(257)) pseudo_rand (clk, reset, RW_rand_raw[256:0]); 
    assign RW_rand_vect[256+63:0] = {RW_rand_raw[62:0], RW_rand_raw};  
    /* verilator lint_restore */  /* verilator lint_off WIDTH */ 
    /* verilator lint_off UNOPTFLAT */
\TLV
   
   |calc
      
      // Pythagora's Theorem
      @1
         $aa_sq[7:0] = $aa[3:0] ** 2;
         $bb_sq[7:0] = $bb[3:0] ** 2;
      @2
         $cc_sq[8:0] = $aa_sq + $bb_sq;
      @3
         $cc[4:0] = sqrt($cc_sq);


      // Print
         \SV_plus
            always_ff @(posedge clk) begin
               \$display("sqrt((\%2d ^ 2) + (\%2d ^ 2)) = \%2d", $aa, $bb, $cc);
            end

   // Stop simulation.
   *passed = *cyc_cnt > 40;
\SV
endmodule

