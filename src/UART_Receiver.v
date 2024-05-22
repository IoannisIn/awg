module UART_Receiver (
    input wire clk,
    input wire rst,
    input wire uart_rx,
    output reg [7:0] uart_data,
    output reg data_valid
);

    parameter BAUD_RATE = 9600;
    parameter CLK_FREQ = 50000000;

    localparam integer BAUD_TICK_COUNT = CLK_FREQ / BAUD_RATE;

    reg [15:0] baud_counter;
    reg [3:0] bit_index;
    reg [7:0] rx_shift_reg;
    reg rx_sample;
    reg rx_busy;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            baud_counter <= 0;
            bit_index <= 0;
            rx_shift_reg <= 0;
            rx_sample <= 1;
            rx_busy <= 0;
            uart_data <= 0;
            data_valid <= 0;
        end else begin
            if (!rx_busy) begin
                if (!uart_rx) begin // Start bit detected
                    rx_busy <= 1;
                    baud_counter <= BAUD_TICK_COUNT / 2; // Sample in the middle of the bit
                    bit_index <= 0;
                end
            end else begin
                baud_counter <= baud_counter - 1;
                if (baud_counter == 0) begin
                    baud_counter <= BAUD_TICK_COUNT;
                    rx_sample <= uart_rx;
                    if (bit_index == 8) begin
                        uart_data <= rx_shift_reg;
                        data_valid <= 1;
                        rx_busy <= 0;
                    end else begin
                        rx_shift_reg <= {rx_sample, rx_shift_reg[7:1]};
                        bit_index <= bit_index + 1;
                    end
                end
            end
            if (data_valid) begin
                data_valid <= 0;
            end
        end
    end
endmodule
