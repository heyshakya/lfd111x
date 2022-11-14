\TLV_version 1d: tl-x.org
\SV

// ------------------------
// SystemVerilog data types

typedef logic [15:0] mips_word;
typedef logic  [7:0] mips_byte;
typedef logic  [2:0] mips_reg;


typedef enum bit [3:0] {
    op_add  = 4'b0001,
    op_and  = 4'b0101,
    op_br   = 4'b0000,
    op_jmp  = 4'b1100,   /* also RET */
    op_jsr  = 4'b0100,   /* also JSRR */
    op_ldb  = 4'b0010,
    op_ldi  = 4'b1010,
    op_lea  = 4'b1110,
    op_not  = 4'b1001,
    op_ldr  = 4'b0110,
    op_rti  = 4'b1000,
    op_shf  = 4'b1101,
    op_stb  = 4'b0011,
    op_sti  = 4'b1011,
    op_str  = 4'b0111,
    op_trap = 4'b1111
} mips_opcode;

typedef enum bit [3:0] {
    alu_add,
    alu_and,
    alu_not
} mips_aluop;






module top(input wire clk, input wire reset, input wire [31:0] cyc_cnt, output wire passed, output wire failed);    /* verilator lint_save */ /* verilator lint_off UNOPTFLAT */  bit [256:0] RW_rand_raw; bit [256+63:0] RW_rand_vect; pseudo_rand #(.WIDTH(257)) pseudo_rand (clk, reset, RW_rand_raw[256:0]); assign RW_rand_vect[256+63:0] = {RW_rand_raw[62:0], RW_rand_raw};  /* verilator lint_restore */  /* verilator lint_off WIDTH */ /* verilator lint_off UNOPTFLAT */
\TLV
   /*
   
   // Fetch pipe fetches an insruction.
   |fetch
      @1   // "fetch1"
      @2   // "fetch2"
   // A pipeline for execution, beginning from fetch response from memory.
   |exe
      @2   // "fetch2"
      @3   // "fetch3"
      @4   // "decode"
      @5   // exe ("add", "and", "not", "calc_addr", "br")
      @6   // "ld1/st1", "br_taken", or next "fetch 1"
      @7   // "st2", next "fetch 1" after "br_taken"
   // Pipeline for memory response for fetch/load/store.
   // Stages align with those of the instruction fetch response.
   |resp
      @2   // "ld1/st2"
      @3   // "ld2", IR, next "fetch1" for store
      @4   // next "fetch1" for load
   */
   
   // Fetch next instruction
   |fetch
      // Next PC
      @0
         $reset = *reset;
         
         $valid_br_taken = /top|exe>>6$valid_br_taken;
         $pc[15:0] =
            $reset ? 16'b0 :
            ($valid_br_taken && >>1$instr_valid)
               ? // Add to PC (increment or branch).
                 >>1$pc +
                    (>>1$instr_valid
                       ? // increment
                         16'd2
                       : // branch
                         {{7{/top|exe>>6$offset9[8]}},  // sign ext
                          /top|exe>>6$offset9})         // branch target
               : $RETAIN;
               
      // Next instruction
      @1
         $instr_valid =
            // first instruction
            (>>1$reset && ! $reset) ||
            // store
            (/top|resp>>2$mem_resp && /top|resp>>2$StorePending) ||  // /top|resp>>2$st_resp_valid, but better timing.
            // load
            /top|resp>>3$ld_resp_valid ||
            // else (alu, branch not-taken)
            /top|exe>>5$valid_exe_inst;
   
   // Execute the instruction that was fetched.
   |exe
      //@2
      //   $reset = *reset;
         
      @3
         $instr_valid      = /top|resp<>0$fetch_resp_valid;    
         $ir[15:0] = $instr_valid ? /top|resp<>0$mem_rdata :
                                    $RETAIN;
      
      // Decode
      @4
         // Condition on valid instruction if pipelined implementation.
         ?$instr_valid
            // Instruction fields:
            $opcode[3:0]  = $ir[15:12];
            $dest[2:0]    = $ir[11:9];
            $src1[2:0]    = $ir[8:6];
            $src2[2:0]    = $ir[2:0];
            $offset6[5:0] = $ir[5:0];
            $offset9[8:0] = $ir[8:0];
         
            // Opcode Decode:
            \always_comb
               casez($opcode)
                  op_add:  $$aluop[3:0] = alu_add;
                  op_and:  $aluop = alu_and;
                  op_not:  $aluop = alu_not;
                  default: $aluop = 'x;
               endcase
            $br = $opcode == op_br;
         $valid_ld = $instr_valid && $opcode == op_ldr;
         $valid_st = $instr_valid && $opcode == op_str;
         $valid_mem_instr = $valid_ld || $valid_st;
            
      // Regfile
      @4
         regfile rf(.clk(*clk),
                    .load(/top|resp<<1$ld_resp_valid),
                    .in(($instr_valid && ! $valid_mem_instr)
                              ? >>1$rslt :
                                /top|resp<<1$mem_rdata),
                    .src_a($src1),
                    .src_b($src2),
                    .dest($dest),
                    .reg_a($$reg_a[15:0]),
                    .reg_b($$reg_b[15:0]));

      // ALU
      @5
         $adj_offset6[15:0] = {{10{$offset6[5]}}, $offset6};
         alu alu(.aluop($aluop),
                 .a($reg_a),
                 .b($valid_mem_instr ? $adj_offset6 : $reg_b),
                 .f($$rslt[15:0]));

      // Branch target
      @5
         $cc[2:0] = {$rslt[15], $rslt == 16'b0, | $rslt[14:0]};
      @6
         $valid_br_taken = $instr_valid && $br &&
                           $cc == $dest;  // CCCOMP
         // Cases that go to "fetch 1" after "exe".
         $valid_exe_inst = $instr_valid && !($valid_mem_instr || $valid_br_taken);
         
      // MAR/MDR
      @5
         $mar[15:0] =
            $valid_mem_instr          ? $rslt :             // ld/st
            /top|fetch<<4$instr_valid ? /top|fetch<<4$pc :  // instruction load
                                        $RETAIN;
         // Note: MDR as spec'ed holds both ld and store data, which gets in the way for
         //       a pipelined design, so I just let load data stage separately.
         $mdr[15:0] =
            $valid_st     ? $rslt :     // st
                            $RETAIN;
      // Memory
      @6
         $fetch = /top|fetch<<4$instr_valid;
         // Just return random data for now, 2 cycles later.
         $mem_rdata[15:0] = *RW_rand_vect[(0 + (0)) % 257 +: 16];
         $mem_op = $valid_mem_instr || $fetch;
         $mem_resp = >>2$mem_op;
   
   // Handle response from memory, whether fetch, ld, or st.
   |resp
      @1
         $reset = *reset;
      @2
         // Remember the purpose of the memory operation: fetch, load, or store.
         {<<1$FetchPending,
          <<1$LoadPending,
          $next_store_pending} =
            $reset || $mem_resp        ? 3'b000 :
            /top|fetch<>0$instr_valid  ? 3'b100 :
            /top|exe>>4$valid_ld       ? 3'b010 :
            /top|exe>>5$valid_st       ? 3'b001 :
                                         {$FetchPending, $LoadPending, $StorePending};  // $RETAIN
         <<1$StorePending = $next_store_pending;
         
      // This pipeline is fed from memory response.
      @2
         $mem_resp = /top|exe>>4$mem_resp;
         $mem_rdata[15:0] = /top|exe>>4$mem_rdata;
         
      // Characterize response.
      @3
         $ld_resp_valid    = $mem_resp && $LoadPending;
         //$st_resp_valid    = $mem_resp && $StorePending;
         $fetch_resp_valid = $mem_resp && $FetchPending;
         
   
   // ---------
   // Testbench
   // ---------
   
   // Just run for fixed number of cycles
   $reset = *reset;
   $Cnt[15:0] <= $reset ? 16'b0 :
                               $Cnt + 16'b1;
   *passed = $Cnt > 16'd100;

\SV
endmodule




// -------------
// ALU

module alu
(
    input mips_aluop aluop,
    input mips_word a, b,
    output mips_word f
);

always_comb
begin
    case (aluop)
        alu_add: f = a + b;
        alu_and: f = a & b;
        alu_not: f = ~a;
        default: f = f;
    endcase
end

endmodule : alu



// ---------------
// Register File

module regfile
(
    input clk,
    input load,
    input mips_word in,
    input mips_reg src_a, src_b, dest,
    output mips_word reg_a, reg_b
);

mips_word data [7:0];

initial
begin
    for (int i = 0; i < $size(data); i++)
    begin
        data[i] = 16'b0;
    end
end

always_ff @(posedge clk)
begin
    if (load == 1)
    begin
        data[dest] = in;
    end
end

always_comb
begin
    reg_a = data[src_a];
    reg_b = data[src_b];
end

endmodule : regfile