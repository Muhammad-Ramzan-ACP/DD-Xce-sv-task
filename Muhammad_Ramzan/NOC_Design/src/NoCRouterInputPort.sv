module NoCRouterInputPort (
    input  logic          clk,
    input  logic          reset,
    input  logic          valid_in,    // From Packet Generator
    input  logic [12:0]   packet_in,   // 12-bit packet
    output logic          ready_out,   // To Packet Generator
    output logic [12:0]   buffered_packet_out, // Buffered packet
    output logic [1:0]    route        // Route computed from destination
);

    // FIFO for buffering packets
    logic [12:0] fifo [3:0]; // Simple 4-entry FIFO
    logic [1:0]  fifo_head, fifo_tail;
    logic        fifo_full, fifo_empty;
    
    // Route computation based on destination address
    always_comb 
    begin
        case (packet_in[12:11]) // Destination address
            2'b00: route   = 2'b00;
            2'b01: route   = 2'b01;
            2'b10: route   = 2'b10;
            2'b11: route   = 2'b11;
            default: route = 2'b00;
        endcase
    end
    
    // FIFO control logic
    always_ff @(posedge clk or posedge reset) 
    begin
        if (reset) begin
            fifo_head  <= #1 1'b0;
            fifo_tail  <= #1 1'b0;
            fifo_full  <= #1 1'b0;
            fifo_empty <= #1 1'b1;
            ready_out  <= #1 1'b0;
        end 
        else if (valid_in && !fifo_full) 
        begin
            // Write packet to FIFO
            fifo[fifo_tail] <= #1 packet_in;
            fifo_tail       <= #1 fifo_tail + 1;
            fifo_empty      <= #1 1'b0;
            if (fifo_tail + 1 == fifo_head)
                  fifo_full <= #1 1'b1;
            ready_out <= 1'b1;
        end 
        else if (!valid_in && !fifo_empty) 
        begin
            // Read packet from FIFO
            buffered_packet_out <= #1 fifo[fifo_head];
            fifo_head           <= #1 fifo_head + 1;
            fifo_full           <= #1 1'b0;
            if (fifo_head + 1 == fifo_tail)
                fifo_empty      <= #1 1'b1;
            ready_out <= #1 1'b0;
        end 
        else 
        begin
            ready_out           <= #1 1'b0;
        end
    end
endmodule

