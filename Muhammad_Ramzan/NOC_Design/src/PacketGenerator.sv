module PacketGenerator (
    input  logic         clk,
    input  logic         reset,
    input  logic         ready_out,    // From NoC Router
    output logic         valid_in,    // To NoC Router
    output logic [12:0]  packet_out   // 13-bit packet (2-bit dest, 2-bit type, 8-bit payload, 1-bit EOP)
);

    // Packet fields
    logic [1:0]          dest;
    logic [1:0]          package_type;
    logic [7:0]          payload;
    logic                eop;
    
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            valid_in          <= #1 1'b0;
            packet_out        <= #1 13'b0;
        end 
        else if (ready_out) 
        begin
            // Generate packet
            dest              <= #1 2'b00;       // Destination address
            package_type      <= #1 2'b00;       // Packet type
            payload           <= #1 8'hAA;       // Payload data
            eop               <= #1 1'b1;        // End of Packet flag
            
            packet_out        <= #1 {dest, package_type, payload, eop};
            valid_in          <= #1 1'b1;
        end 
        else 
        begin
            valid_in          <= #1 1'b0;
        end
    end
endmodule