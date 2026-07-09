`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.07.2026 19:56:44
// Design Name: 
// Module Name: uart_tx_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module uart_tx_tb;

    parameter CLK_FREQ      = 100;
    parameter BAUD_RATE     = 10;
    parameter PARITY_ENABLE = 1;
    parameter PARITY_TYPE   = 0;

    reg        clk;
    reg        rst_n;
    reg        tx_start;
    reg [7:0]  data_in;

    wire       tx;
    wire       tx_busy;

    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .PARITY_ENABLE(PARITY_ENABLE),
        .PARITY_TYPE(PARITY_TYPE)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(tx_start),
        .data_in(data_in),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    initial
        clk = 1'b0;

    always #5 clk = ~clk;

    initial
    begin
        rst_n    = 1'b0;
        tx_start = 1'b0;
        data_in  = 8'd0;

        #20;
        rst_n = 1'b1;


        #20;

        data_in  = 8'hA5;
        tx_start = 1'b1;

        #10;
        tx_start = 1'b0;

        wait (tx_busy == 1'b0);


        #100;

        data_in  = 8'h55;
        tx_start = 1'b1;

        #10;
        tx_start = 1'b0;

        wait (tx_busy == 1'b0);

        #200;

        $stop;
    end

endmodule