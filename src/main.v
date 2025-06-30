module main(
    input wire clk_i,
    input  wire rx_i,
    output wire tx_o
);
    reg [7:0] ram [0:4095]; // 4KB RAM
    `include "ram.vh"
    wire [31:0] ibus_addr;
    wire [31:0] ibus_data = {ram[ibus_addr + 3],
                             ram[ibus_addr + 2],
                             ram[ibus_addr + 1],
                             ram[ibus_addr]};
    wire [3:0]dbus_en;
    wire [31:0] dbus_addr;
    wire [31:0] dbus_write_data;
    always @(posedge clk_i) begin
        if (dbus_en[0]) ram[dbus_addr+0] <= dbus_write_data[7:0];
        if (dbus_en[1]) ram[dbus_addr+1] <= dbus_write_data[15:8];
        if (dbus_en[2]) ram[dbus_addr+2] <= dbus_write_data[23:16];
        if (dbus_en[3]) ram[dbus_addr+3] <= dbus_write_data[31:24];
    end

    wire [31:0] dbus_read_data = {ram[dbus_addr + 3],
                                  ram[dbus_addr + 2],
                                  ram[dbus_addr + 1],
                                  ram[dbus_addr]};
    rv32i proc (
        .clk_i(clk_i),
        .ibus_addr_o(ibus_addr),
        .ibus_data_i(ibus_data),
        .dbus_en_o(dbus_en),
        .dbus_addr_o(dbus_addr),
        .dbus_write_data_o(dbus_write_data),
        .dbus_read_data_i(dbus_read_data)
    );
    assign tx_o = 1'b1;
endmodule
