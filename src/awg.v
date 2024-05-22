module tt_um_awg (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
    );

    // Declare internal signals
    wire rst = ~rst_n; // Create an internal active-high reset signal
    wire uart_rx = ui_in[0]; // Assuming uart_rx is mapped to ui_in[0]

    wire [7:0] uart_data;
    wire data_valid;
    wire [1:0] waveform_type;
    wire [16:0] frequency;
    wire [9:0] amplitude;
    wire [9:0] dc_offset;
    wire [9:0] waveform_data;

    // Assign output signals
    assign uo_out = waveform_data[7:0];
    assign uio_out[1:0] = waveform_data[9:8];
    assign uio_oe  = 8'b11111111; // Assuming all outputs are enabled

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
