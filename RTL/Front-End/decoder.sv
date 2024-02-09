/*  ====================================
    VZ16(MMC16) Instruction Set Decoder
    ==================================== */

module vz16_decoder(oneInst, inPC, outMicroOp, outPC, outRn, outR1, outR2);
    input [15:0] oneInst; // input one Instrucion
    input [15:0] inPC; // input Instruction Address
    output logic [9:0] outMicroOp; // output Micro Opcode (IMM / Branch / MEM / STACK / SHIFT / ALU / MUL / LOGIC / )
    output [15:0] outPC; // output Instruction Address (Program Counter)
    output [3:0] outRn, outR1, outR2; // parsing Register Fields

    always_comb begin
        casex(oneInst[3:0])
            4'b0000: begin outMicroOp = 10'b00_0000_0001 end
            4'b0001: begin outMicroOp = 10'b00_0000_0010 end
            4'b001x: begin outMicroOp = {oneInst[], 8'b0000_0100} end
        endcase
    end

    assign outPC = inPC;
    assign outRn = oneInst[7:4];
    assign outR1 = oneInst[11:8];
    assign outR2 = oneInst[15:12];
endmodule
