`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.07.2026 22:08:40
// Design Name: 
// Module Name: uart_tx
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


module uart_tx #(
    parameter CLK_FREQ      = 50_000_000,
    parameter BAUD_RATE     = 9600,
    parameter PARITY_ENABLE = 0,
    parameter PARITY_TYPE   = 0      // 0 = Even, 1 = Odd
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       tx_start,
    input  wire [7:0] data_in,
    output reg        tx,
    output reg        tx_busy
);

    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    localparam IDLE   = 3'd0,
               START  = 3'd1,
               DATA   = 3'd2,
               PARITY = 3'd3,
               STOP   = 3'd4;

    reg [2:0]  state;
    reg [2:0]  bit_counter;
    reg [7:0]  shift_reg;
    reg         parity_bit;
    reg [12:0] baud_counter;

    always @(posedge clk)
    begin
        if (!rst_n)
        begin
            state        <= IDLE;
            bit_counter  <= 3'd0;
            baud_counter <= 13'd0;
            shift_reg    <= 8'd0;
            tx           <= 1'b1;
            tx_busy      <= 1'b0;
            parity_bit   <= 1'b0;
        end
        else
        begin
            case (state)

                IDLE:
                begin
                    tx           <= 1'b1;
                    tx_busy      <= 1'b0;
                    baud_counter <= 13'd0;
                    bit_counter  <= 3'd0;

                    if (tx_start)
                    begin
                        shift_reg  <= data_in;
                        parity_bit <= (PARITY_TYPE == 0) ?
                                       ^data_in : ~(^data_in);
                        tx_busy    <= 1'b1;
                        state      <= START;
                    end
                end

                START:
                begin
                    tx <= 1'b0;

                    if (baud_counter == CLKS_PER_BIT - 1)
                    begin
                        baud_counter <= 13'd0;
                        state        <= DATA;
                    end
                    else
                    begin
                        baud_counter <= baud_counter + 13'd1;
                    end
                end

                DATA:
                begin
                    tx <= shift_reg[0];

                    if (baud_counter == CLKS_PER_BIT - 1)
                    begin
                        baud_counter <= 13'd0;

                        if (bit_counter == 3'd7)
                        begin
                            if (PARITY_ENABLE)
                                state <= PARITY;
                            else
                                state <= STOP;
                        end
                        else
                        begin
                            shift_reg   <= shift_reg >> 1;
                            bit_counter <= bit_counter + 3'd1;
                        end
                    end
                    else
                    begin
                        baud_counter <= baud_counter + 13'd1;
                    end
                end

                PARITY:
                begin
                    tx <= parity_bit;

                    if (baud_counter == CLKS_PER_BIT - 1)
                    begin
                        baud_counter <= 13'd0;
                        state        <= STOP;
                    end
                    else
                    begin
                        baud_counter <= baud_counter + 13'd1;
                    end
                end

                STOP:
                begin
                    tx <= 1'b1;

                    if (baud_counter == CLKS_PER_BIT - 1)
                    begin
                        baud_counter <= 13'd0;
                        bit_counter  <= 3'd0;
                        tx_busy      <= 1'b0;
                        state        <= IDLE;
                    end
                    else
                    begin
                        baud_counter <= baud_counter + 13'd1;
                    end
                end

                default:
                begin
                    state        <= IDLE;
                    tx           <= 1'b1;
                    tx_busy      <= 1'b0;
                    baud_counter <= 13'd0;
                    bit_counter  <= 3'd0;
                end

            endcase
        end
    end

endmodule