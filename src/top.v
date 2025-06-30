module top;
    reg clk = 1'b1; initial forever #5 clk = ~clk;
    reg [63:0] cc = 0;
    reg done = 0;
    always @(posedge clk) if (!done) cc <= cc + 1;

    main main (
        .clk_i(clk),
        .rx_i(1'b1), // No RX input for simulation
        .tx_o()      // TX output not used in this simulation
    );

    always @(posedge clk) begin
        if (cc == 300) done <= 1;
        if (done) begin
            $display("Simulation finished at cycle %03d", cc);
            $finish;
        end
    end

endmodule