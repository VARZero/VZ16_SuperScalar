/*  ====================================
    VZ16(MMC16) Instruction Set Decoder
    ==================================== */

module scRenamer();
    input clk, reset_n;
    input [15:0] i0, i1, i2, i3;
    input [15:0] pc0, pc1, pc2, pc3;
    output reg [15:0] oi0, oi1, oi2, oi3;
    output reg RN_ACTIVE;

    RegisterFile #(.ENTRY(32), .WIDTH(16), .RCha(4), .WCha(4)) U0_tempRegList()
endmodule
