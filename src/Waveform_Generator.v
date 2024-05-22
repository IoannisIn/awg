module Waveform_Generator (
    input wire clk,
    input wire rst,
    input wire [1:0] waveform_type,
    input wire [16:0] frequency,
    input wire [9:0] amplitude,
    input wire [9:0] dc_offset,
    output reg [9:0] waveform_data
);

    // Parameters
    localparam N = 10; // Resolution
    localparam M = 128; // Number of points per period

    // Internal variables
    reg [31:0] phase_accumulator;
    reg [31:0] phase_increment;
    reg [6:0] lookup_index;

    // Sine lookup table
    reg [9:0] sine_lut [0:M-1];

    // Initialize sine lookup table
    initial begin
        sine_lut[0] = 512; sine_lut[1] = 537; sine_lut[2] = 562; sine_lut[3] = 586;
        sine_lut[4] = 611; sine_lut[5] = 634; sine_lut[6] = 657; sine_lut[7] = 679;
        sine_lut[8] = 700; sine_lut[9] = 720; sine_lut[10] = 739; sine_lut[11] = 757;
        sine_lut[12] = 774; sine_lut[13] = 789; sine_lut[14] = 804; sine_lut[15] = 817;
        sine_lut[16] = 828; sine_lut[17] = 839; sine_lut[18] = 848; sine_lut[19] = 855;
        sine_lut[20] = 861; sine_lut[21] = 866; sine_lut[22] = 869; sine_lut[23] = 871;
        sine_lut[24] = 872; sine_lut[25] = 871; sine_lut[26] = 869; sine_lut[27] = 866;
        sine_lut[28] = 861; sine_lut[29] = 855; sine_lut[30] = 848; sine_lut[31] = 839;
        sine_lut[32] = 828; sine_lut[33] = 817; sine_lut[34] = 804; sine_lut[35] = 789;
        sine_lut[36] = 774; sine_lut[37] = 757; sine_lut[38] = 739; sine_lut[39] = 720;
        sine_lut[40] = 700; sine_lut[41] = 679; sine_lut[42] = 657; sine_lut[43] = 634;
        sine_lut[44] = 611; sine_lut[45] = 586; sine_lut[46] = 562; sine_lut[47] = 537;
        sine_lut[48] = 512; sine_lut[49] = 487; sine_lut[50] = 462; sine_lut[51] = 438;
        sine_lut[52] = 413; sine_lut[53] = 390; sine_lut[54] = 367; sine_lut[55] = 345;
        sine_lut[56] = 324; sine_lut[57] = 304; sine_lut[58] = 285; sine_lut[59] = 267;
        sine_lut[60] = 250; sine_lut[61] = 235; sine_lut[62] = 220; sine_lut[63] = 207;
        sine_lut[64] = 196; sine_lut[65] = 185; sine_lut[66] = 176; sine_lut[67] = 169;
        sine_lut[68] = 163; sine_lut[69] = 158; sine_lut[70] = 155; sine_lut[71] = 153;
        sine_lut[72] = 152; sine_lut[73] = 153; sine_lut[74] = 155; sine_lut[75] = 158;
        sine_lut[76] = 163; sine_lut[77] = 169; sine_lut[78] = 176; sine_lut[79] = 185;
        sine_lut[80] = 196; sine_lut[81] = 207; sine_lut[82] = 220; sine_lut[83] = 235;
        sine_lut[84] = 250; sine_lut[85] = 267; sine_lut[86] = 285; sine_lut[87] = 304;
        sine_lut[88] = 324; sine_lut[89] = 345; sine_lut[90] = 367; sine_lut[91] = 390;
        sine_lut[92] = 413; sine_lut[93] = 438; sine_lut[94] = 462; sine_lut[95] = 487;
        sine_lut[96] = 512; sine_lut[97] = 537; sine_lut[98] = 562; sine_lut[99] = 586;
        sine_lut[100] = 611; sine_lut[101] = 634; sine_lut[102] = 657; sine_lut[103] = 679;
        sine_lut[104] = 700; sine_lut[105] = 720; sine_lut[106] = 739; sine_lut[107] = 757;
        sine_lut[108] = 774; sine_lut[109] = 789; sine_lut[110] = 804; sine_lut[111] = 817;
        sine_lut[112] = 828; sine_lut[113] = 839; sine_lut[114] = 848; sine_lut[115] = 855;
        sine_lut[116] = 861; sine_lut[117] = 866; sine_lut[118] = 869; sine_lut[119] = 871;
        sine_lut[120] = 872; sine_lut[121] = 871; sine_lut[122] = 869; sine_lut[123] = 866;
        sine_lut[124] = 861; sine_lut[125] = 855; sine_lut[126] = 848; sine_lut[127] = 839;
    end

    // Phase accumulator for frequency control
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            phase_accumulator <= 0;
            phase_increment <= 0;
        end else begin
            phase_increment <= (frequency * 32'd4294967296) / 32'd50000000;
            phase_accumulator <= phase_accumulator + phase_increment;
        end
    end

    // Lookup index for the waveform
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            lookup_index <= 0;
        end else begin
            lookup_index <= phase_accumulator[31:25]; // Top bits for lookup
        end
    end

    // Generate waveform
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            waveform_data <= 0;
        end else begin
            case (waveform_type)
                2'b00: // Sine
                    waveform_data <= ((sine_lut[lookup_index] * amplitude) >> 10) + dc_offset;
                2'b01: // Triangle
                    waveform_data <= (((lookup_index < 64) ? lookup_index : (127 - lookup_index)) * amplitude / 64) + dc_offset;
                2'b10: // Sawtooth
                    waveform_data <= (lookup_index * amplitude / 128) + dc_offset;
                2'b11: // Square
                    waveform_data <= ((lookup_index < 64) ? amplitude : 0) + dc_offset;
                default:
                    waveform_data <= 0;
            endcase
        end
    end

endmodule
