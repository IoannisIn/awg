module awg (
    input wire clk,
    input wire rst,
    input wire uart_rx,
    output wire [9:0] waveform_data
);

    wire [7:0] uart_data;
    wire data_valid;
    wire [1:0] waveform_type;
    wire [15:0] frequency;
    wire [9:0] amplitude;
    wire [9:0] dc_offset;

    // Instantiate UART Receiver
    UART_Receiver uart_receiver (
        .clk(clk),
        .rst(rst),
        .uart_rx(uart_rx),
        .uart_data(uart_data),
        .data_valid(data_valid)
    );

    // Instantiate Control Logic
    Control_Logic control_logic (
        .clk(clk),
        .rst(rst),
        .uart_data(uart_data),
        .data_valid(data_valid),
        .waveform_type(waveform_type),
        .frequency(frequency),
        .amplitude(amplitude),
        .dc_offset(dc_offset)
    );

    // Instantiate Waveform Generator
    Waveform_Generator waveform_generator (
        .clk(clk),
        .rst(rst),
        .waveform_type(waveform_type),
        .frequency(frequency),
        .amplitude(amplitude),
        .dc_offset(dc_offset),
        .waveform_data(waveform_data)
    );

endmodule
