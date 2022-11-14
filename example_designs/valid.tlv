// 4 Stage Pipelined Pythagora’s Theorem Example with Valid Signal

\m4_TLV_version 1d --xinj --xclk: tl-x.org
\SV
   `include "sqrt32.v";

   `include "makerchip_module.v"
\TLV
   
   // Stimulus
   |calc
      @0
         $valid = 0;
         $aa[3:0] = 0;
         $bb[3:0] = 0;
   
   // DUT (Design Under Test)
   |calc
      ?$valid
         @1
            $aa_sq[7:0] = $aa[3:0] ** 2;
            $bb_sq[7:0] = $bb[3:0] ** 2;
         @2
            $cc_sq[8:0] = $aa_sq + $bb_sq;
         @3
            $cc[4:0] = sqrt($cc_sq);

\SV
   endmodule
