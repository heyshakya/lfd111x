// AND Gate Example

\m4_TLV_version 1d: tl-x.org
\SV
   m4_makerchip_module
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

\m4_TLV_version 1d: tl-x.org
\SV
   m4_makerchip_module
\TLV
   
   // Verilog arithmetic operators: +, -, *, /, %, etc.
   $out[7:0] = ($num1[3:0] + $num2[3:0]) - 1;
   
\SV
endmodule

//---------------------------------------------------------------------------------------

// MUX Example

\m4_TLV_version 1d: tl-x.org
\SV
   m4_makerchip_module
\TLV
   
   // Ternary operator:
   $num1[7:0] = $big ? 255 : 0;
   
   // Chained ternary operator:
   $num2[7:0] = $big ? 255 : $medium ? 100 : $small ? 5 : 0;
\SV
endmodule

//---------------------------------------------------------------------------------------

// ALU Example

\m4_TLV_version 1d: tl-x.org
\SV
   m4_makerchip_module
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