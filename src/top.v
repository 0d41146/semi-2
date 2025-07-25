module top;
    reg        clk = 1; initial forever #5 clk = ~clk; // 100MHz clock
    reg [63:0] cc  = 0; always @(posedge clk) cc <= cc+1; // clock cycle counter

    string hex_file;
    initial begin
        if ($value$plusargs("hex_file=%s", hex_file)) begin
            $display("Loading hex file: %s", hex_file);
            $readmemh(hex_file, top.dut.ram);
        end else begin
            $display("No hex file specified, using default values.");
        end
    end

    // initial begin
    //     $dumpfile("top.vcd");
    //     $dumpvars(0, top);
    // end

    reg done = 0;
    always @(posedge clk) begin
        if (top.dut.dbus_en==4'hf && top.dut.dbus_write_addr == 32'h40008000) begin
            if (top.dut.dbus_write_data == 32'h777) begin
                $finish;
            end else begin
                $fatal;
            end
        end
    end

    main dut(
        .clk_i(clk),
        .rx_i(1'b1),
        .tx_o()
    );
endmodule