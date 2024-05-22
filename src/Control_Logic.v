module Control_Logic (
    input wire clk,
    input wire rst,
    input wire [7:0] uart_data,
    input wire data_valid,
    output reg [1:0] waveform_type,
    output reg [15:0] frequency,
    output reg [9:0] amplitude,
    output reg [9:0] dc_offset
);

    // UART data handling
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            waveform_type <= 2'b00;
            frequency <= 16'h0001;
            amplitude <= 10'h3FF;
            dc_offset <= 10'h200;
        end else if (data_valid) begin
            // Assume the UART data packet is structured in a specific way
            // Here, we decode based on assumed structure (update as needed)
            waveform_type <= uart_data[1:0];
            frequency <= {uart_data[7:2], uart_data}; // Example structuring
            amplitude <= {uart_data[7:4], uart_data}; // Example structuring
            dc_offset <= {uart_data[7:4], uart_data}; // Example structuring
        end
    end

endmodule
