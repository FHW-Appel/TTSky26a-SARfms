// This is a SAR FSM implementation in Verilog.

module sar_fsm 
#(parameter WIDTH = 4)

(
    input wire clk,          // Clock signal
    input wire rst_n,        // Active low reset synchronous signal
    input wire compare,      // Comparator output signal
    output reg EOC,          // End of conversion signal
    output reg [WIDTH-1:0] sar_int,       // SAR internal register
    output reg [WIDTH-1:0] sar_out        // SAR output register
);

// Register to track the active bit being processed (from MSB to LSB)
reg [WIDTH-1:0] active_bit;
// Temporary register for SAR calculations
reg [WIDTH-1:0] sar_tmp; 
// Internal EOC signal to indicate end of conversion
wire internal_EOC;

always @(posedge clk) begin
    if (!rst_n) begin
        sar_int <= (1 << (WIDTH - 1)); // Initialize SAR internal register to 1000 for e.g. 4 bits
        sar_out <= 0; // Initialize SAR output register to 0
        active_bit <= (1 << (WIDTH - 1)); // Start with the MSB
        EOC <= 0; // Clear EOC signal on reset
    end else begin
        
        // Update the SAR internal register based on the comparator output
        if (compare) begin
            // Keep the current bit and set the next bit
            sar_tmp = sar_int | (active_bit >> 1); 
        end else begin
            // Clear the current bit and set the next bit
            sar_tmp = (sar_int & ~active_bit) | (active_bit >> 1);
        end
        sar_int <= sar_tmp; // Update the SAR internal register with the new value

        // Update the active bit
        if (active_bit != 1) begin // If the last bit is not yet processed
            active_bit <= (active_bit >> 1); // Advance from MSB to LSB
        end else begin // Last bit processed
            active_bit <= (1 << (WIDTH - 1)); // Start with the MSB again for the next conversion
            sar_int <= (1 << (WIDTH - 1)); // Initialize SAR internal register to 1000 for e.g. 4 bits
        end

        // Update the SAR output register at the end of conversion
        if (internal_EOC) begin
            sar_out <= sar_tmp; // Update output register with the final SAR value
            EOC <= 1; // Set EOC signal to indicate end of conversion
        end
    end
end

assign internal_EOC = (active_bit == 1);


`ifdef FORMAL

    reg f_past_valid = 0;

    initial assume (rst_n == 0);
    initial assume (internal_EOC == 0);
    always @(posedge clk) begin
        
        f_past_valid <= 1;

        if (f_past_valid) begin

            // Cover any bit of the internal register being set
            _c_any_bit_set_: cover(compare == 0 && rst_n == 1);
            
            // Cover 0101 at the internal register
            _c_0101_: cover(sar_int == 4'b0101);

            // Cover 1010 at the internal register
            _c_1010_: cover(sar_int == 4'b1010);

            // cover reset behavior
            _c_reset_: cover($past(rst_n) == 0 && sar_int == 4'b1000);

            // cover output behavior
            _c_output_: cover($past(internal_EOC) == 1 && sar_out == $past(sar_int));

            // After reset, internal register should be initialized
            if ($past(rst_n) == 0) begin
                _a_prove_reset_: assert(sar_int == 4'b1000);
            end else begin
                // Check behavior based on compare signal
                if (($past(compare)) && ($past(internal_EOC) == 0)) begin
                    _a_prove_set_bit_: assert((sar_int & $past(active_bit))  == $past(active_bit));
                end else begin
                    _a_prove_no_set_bit_: assert((sar_int & $past(active_bit))  == 0);
                end
            end
        end

    end
`endif

endmodule