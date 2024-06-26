module cpnt_rf #(
    parameter ENTRY = 8,
    parameter WIDTH = 16,
    parameter RCha = 2,
    parameter WCha = 2
)
(
    input clk, input reset_n,
    input wrAcv, // Write/Read Signal (0: read/1: write)
    input [ENTRY-1:0] readAddr [RCha-1:0],
    input [ENTRY-1:0] writeAddr [WCha-1:0],
    input [WIDTH-1:0] writeData [WCha-1:0],
    output logic [WIDTH-1:0] readData [RCha-1:0]
);
    reg [WIDTH-1:0] registers[ENTRY-1:0];
    logic [WIDTH-1:0] regst_next[ENTRY-1:0];

    integer initREG, oneSelCha;

    // Registers Define
    always_ff @(posedge clk or negedge reset_n) begin
        if (reset_n == 1'b0) begin
            for (initREG = 0; initREG < ENTRY; initREG = initREG + 1) begin
                registers[initREG] <= 0;
            end
        end
        else begin
            for (initREG = 0; initREG < ENTRY; initREG = initREG + 1) begin
                registers[initREG] <= regst_next[initREG];
            end
        end
    end
    
    // Read Section
    always_comb begin
        if (wrAcv == 1'b0) begin
            for (oneSelCha = 0; oneSelCha < RCha; oneSelCha = oneSelCha + 1) begin
                readData[oneSelCha] = registers[readAddr[oneSelCha]];
            end
        end
        else begin
            for (oneSelCha = 0; oneSelCha < RCha; oneSelCha = oneSelCha + 1) begin
                readData[oneSelCha] = 0;
            end
        end
    end

    // Write Section
    always_comb begin
        if (wrAcv == 1'b1) begin
            for (oneSelCha = 0; oneSelCha < ENTRY; oneSelCha = oneSelCha + 1) begin
                // 우선순위 디코더 삽입예정
                regst_next[writeAddr[oneSelCha]] = writeData[oneSelCha];
            end
        end
        else begin
            for (oneSelCha = 0; oneSelCha < ENTRY; oneSelCha = oneSelCha + 1) begin
                regst_next[oneSelCha] = registers[oneSelCha];
            end
        end
    end
endmodule

module RegisterFile;
	wire clk, rst, wracv;
	wire [7:0] ra[1:0];
	wire [7:0] wa[1:0];
	wire [15:0] rd[1:0];
	wire [15:0] wd[1:0];
	reg [15:0] rout [1:0];
	cpnt_rf asdfasfda(clk, rst, wracv, 
	ra, 
	wa, 
	wd, 
	rout);
endmodule
