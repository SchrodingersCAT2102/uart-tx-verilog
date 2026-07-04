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

`timescale 1ns/1ps

module uart_tx_tb;

    reg clk;
    reg rst_n;
    reg tx_start;
    reg [7:0] data_in;

    wire tx;
    wire tx_busy;

    uart_tx #(
        .CLK_FREQ(100),
        .BAUD_RATE(10)
    )
    DUT (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(tx_start),
        .data_in(data_in),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    initial
    begin
        clk = 1'b0;

        forever
            #5 clk = ~clk;
    end
    
        initial
    begin
        rst_n    = 1'b0;
        tx_start = 1'b0;
        data_in  = 8'h00;

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

        #100;
        $finish;
    end
endmodule
