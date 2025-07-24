module main(
    input wire clk_i,
    input  wire rx_i,
    output wire tx_o
);
//===========================================================
// 32KiB RAM
//===========================================================
    reg   [7:0] ram [0:32767]; // 32KiB RAM
    wire [31:0] ibus_addr;
    wire [31:0] ibus_data = {ram[ibus_addr+3],
                             ram[ibus_addr+2],
                             ram[ibus_addr+1],
                             ram[ibus_addr+0]};

    wire [3:0] ram_en = (dbus_write_addr < 32'h0000_8000) ? dbus_en : 4'b0000; 
    always @(posedge clk_i) begin
        if (ram_en[0]) ram[dbus_write_addr+0] <= dbus_write_data[7:0];
        if (ram_en[1]) ram[dbus_write_addr+1] <= dbus_write_data[15:8];
        if (ram_en[2]) ram[dbus_write_addr+2] <= dbus_write_data[23:16];
        if (ram_en[3]) ram[dbus_write_addr+3] <= dbus_write_data[31:24];
    end

//===========================================================
// CSR (Cycle Counter)
//===========================================================
    reg [63:0] cycle    = 0;
    reg        cycle_en = 0;
    always @(posedge clk_i) begin
        if (dbus_en[0] && dbus_write_addr == 32'h8000_0008)
            cycle_en <= dbus_write_data[0];
        
        if (cycle_en) cycle <= cycle + 1;
        else begin
            if (dbus_en[0] && dbus_write_addr == 32'h8000_0000) cycle[31:0] <= dbus_write_data[31:0];
            if (dbus_en[0] && dbus_write_addr == 32'h8000_0004) cycle[63:32] <= dbus_write_data[31:0];
        end
    end

//===========================================================
// RV32I Processor
//===========================================================
    wire  [3:0] dbus_en;
    wire [31:0] dbus_read_addr;
    wire [31:0] dbus_write_addr;
    wire [31:0] dbus_write_data;
    wire [31:0] dbus_read_data = (dbus_read_addr < 32'h0000_8000) ? {ram[dbus_read_addr+3],
                                                                     ram[dbus_read_addr+2],
                                                                     ram[dbus_read_addr+1],
                                                                     ram[dbus_read_addr+0]} :
                                  (dbus_read_addr == 32'h8000_0000) ? cycle[31:0] : cycle[63:32];
    rv32i proc (
        .clk_i(clk_i),
        .ibus_addr_o(ibus_addr),
        .ibus_data_i(ibus_data),
        .dbus_en_o(dbus_en),
        .dbus_read_addr_o(dbus_read_addr),
        .dbus_write_addr_o(dbus_write_addr),
        .dbus_write_data_o(dbus_write_data),
        .dbus_read_data_i(dbus_read_data)
    );
    assign tx_o = 1'b1;
endmodule
