module rv32i (
    input wire clk_i,
    output wire [31:0] ibus_addr_o,
    input wire [31:0] ibus_data_i,
    output wire [3:0] dbus_en_o,
    output wire [31:0] dbus_addr_o,
    output wire [31:0] dbus_write_data_o,
    input wire [31:0] dbus_read_data_i
);
    reg [31:0] pc = 0;
    reg [31:0] xreg [0:31]; integer i; initial for (i = 0; i < 32; i = i + 1) xreg[i] = 0;
    assign ibus_addr_o = pc;
    

    wire [31:0] insn = ibus_data_i;

    wire [6:0] opcode = insn[6:0];
    wire [4:0] rd = insn[11:7];
    wire [2:0] funct3 = insn[14:12];
    wire [4:0] rs1 = insn[19:15];
    wire [4:0] rs2 = insn[24:20];
    wire [6:0] funct7 = insn[31:25];

    wire [31:0] i_imm = {{20{insn[31]}}, insn[31:20]};
    wire [31:0] s_imm = {{20{insn[31]}}, insn[31:25], insn[11:7]};
    wire [31:0] b_imm = {{19{insn[31]}}, insn[31], insn[7], insn[30:25], insn[11:8], 1'b0};
    wire [31:0] u_imm = {insn[31:12], 12'b0};
    wire [31:0] j_imm = {{11{insn[31]}}, insn[31], insn[19:12], insn[20], insn[30:21], 1'b0};

    wire [31:0] branch_target = pc + b_imm;
    wire [31:0] jump_target = pc + j_imm;

    wire [31:0] dbus_read_data = dbus_read_data_i;
    assign dbus_en_o = dbus_en;
    assign dbus_addr_o = xreg[rs1] + i_imm;
    assign dbus_write_data_o = dbus_write_data;

    always @(posedge clk_i) begin
        pc <= npc;
        if (xreg_en) xreg[rd] <= xreg_write_data;
    end

    reg [31:0] npc;
    reg xreg_en;
    reg [31:0] xreg_write_data;
    reg dbus_en;
    reg [31:0] dbus_write_data;
    `include "riscv.vh"
    always @(*) begin
        npc = pc + 4;
        xreg_en = 0;
        xreg_write_data = 0;
        dbus_en = 0;
        dbus_write_data = 0;
        casez(insn)
            ADD      :begin xreg_en=1; xreg_write_data = xreg[rs1] + xreg[rs2]; end
            ADDI     :begin xreg_en=1; xreg_write_data = xreg[rs1] + i_imm; end
            AND      :begin xreg_en=1; xreg_write_data = xreg[rs1] & xreg[rs2]; end
            ANDI     :begin xreg_en=1; xreg_write_data = xreg[rs1] & i_imm; end
            AUIPC    :begin xreg_en=1; xreg_write_data = pc + u_imm; end
            BEQ      :begin if (xreg[rs1] == xreg[rs2]) npc = branch_target; end
            BGE      :begin if ($signed(xreg[rs1]) >= $signed(xreg[rs2])) npc = branch_target; end
            BGEU     :begin if (xreg[rs1] >= xreg[rs2]) npc = branch_target; end
            BLT      :begin if ($signed(xreg[rs1]) < $signed(xreg[rs2])) npc = branch_target; end
            BLTU     :begin if (xreg[rs1] < xreg[rs2]) npc = branch_target; end
            BNE      :begin if (xreg[rs1] != xreg[rs2]) npc = branch_target; end
            EBREAK   :begin $display("NOT SUPPORTED!"); end
            ECALL    :begin $display("NOT SUPPORTED!"); end
            FENCE    :begin $display("NOT SUPPORTED!"); end
            JAL      :begin xreg_en=1; xreg_write_data = pc+4; npc = jump_target; end
            JALR     :begin xreg_en=1; xreg_write_data = pc+4; npc = (xreg[rs1] + i_imm) & ~32'b1; end
            LB       :begin xreg_en=1; xreg_write_data = {{24{dbus_read_data[7]}}, dbus_read_data[7:0]}; end
            LBU      :begin xreg_en=1; xreg_write_data = dbus_read_data[7:0]; end
            LH       :begin xreg_en=1; xreg_write_data = {{16{dbus_read_data[15]}}, dbus_read_data[15:0]}; end
            LHU      :begin xreg_en=1; xreg_write_data = dbus_read_data[15:0]; end
            LUI      :begin xreg_en=1; xreg_write_data = u_imm; end
            LW       :begin xreg_en=1; xreg_write_data = dbus_read_data[31:0]; end
            OR       :begin xreg_en=1; xreg_write_data = xreg[rs1] | xreg[rs2]; end
            ORI      :begin xreg_en=1; xreg_write_data = xreg[rs1] | i_imm; end
            SB       :begin dbus_en=1; dbus_write_data = xreg[rs2][7:0]; end
            SH       :begin dbus_en=1; dbus_write_data = xreg[rs2][15:0]; end
            SLL      :begin xreg_en=1; xreg_write_data = xreg[rs1] << xreg[rs2][4:0]; end
            SLLI     :begin xreg_en=1; xreg_write_data = xreg[rs1] << i_imm[4:0]; end
            SLT      :begin xreg_en=1; xreg_write_data = ($signed(xreg[rs1]) < $signed(xreg[rs2])); end
            SLTI     :begin xreg_en=1; xreg_write_data = ($signed(xreg[rs1]) < $signed(i_imm)); end
            SLTIU    :begin xreg_en=1; xreg_write_data = (xreg[rs1] < i_imm); end
            SLTU     :begin xreg_en=1; xreg_write_data = (xreg[rs1] < xreg[rs2]); end
            SRA      :begin xreg_en=1; xreg_write_data = $signed(xreg[rs1]) >>> xreg[rs2][4:0]; end
            SRAI     :begin xreg_en=1; xreg_write_data = $signed(xreg[rs1]) >>> i_imm[4:0]; end
            SRL      :begin xreg_en=1; xreg_write_data = xreg[rs1] >> xreg[rs2][4:0]; end
            SRLI     :begin xreg_en=1; xreg_write_data = xreg[rs1] >> i_imm[4:0]; end
            SUB      :begin xreg_en=1; xreg_write_data = xreg[rs1] - xreg[rs2]; end
            SW       :begin dbus_en=1; dbus_write_data = xreg[rs2]; end
            XOR      :begin xreg_en=1; xreg_write_data = xreg[rs1] ^ xreg[rs2]; end
            XORI     :begin xreg_en=1; xreg_write_data = xreg[rs1] ^ i_imm; end
            default   :begin $display("Unknown instruction: %h", insn); end
        endcase
    end
endmodule