/*  ====================================
    VZ16(MMC16) Instruction Set Decoder
    ==================================== */

module vz16_decoder(oneInst, inPC, outMicroOp, outPC, outRn, outR1, outR2);
    input [15:0] oneInst; // input one Instrucion
    input [15:0] inPC; // input Instruction Address
    output logic [7:0] outMicroOp; // output Micro Opcode (IMM / Branch / MEM / STACK / SHIFT / ALU / MUL / LOGIC / )
    output [15:0] outPC; // output Instruction Address (Program Counter)
    output [3:0] outRn, outR1, outR2; // parsing Register Fields

    always_comb begin // decoding
        casex(oneInst[3:0])
            4'b0000: begin outMicroOp = 8'b0000_0001 end // IMM
            4'b0001: begin outMicroOp = 8'b0000_0010 end // JUMP
            4'b001x: begin outMicroOp = {3'b000, oneInst[0], 4'b0100} end // LOAD/SAVE
            4'b001x: begin outMicroOp = {3'b001, oneInst[0], 4'b0100} end // PUSH/POP
            4'b011x: begin outMicroOp = {3'b100, oneInst[0], 4'b1000} end // SHIFTER (ALU)
            4'b1xxx: begin outMicroOp = {1'b0, oneInst[2:0], 4'b1000} end // ALU
            default: begin outMicroOp = 8'bx; end
        endcase
    end

    assign outPC = inPC;
    assign outRn = oneInst[7:4];
    assign outR1 = oneInst[11:8];
    assign outR2 = oneInst[15:12];
endmodule
