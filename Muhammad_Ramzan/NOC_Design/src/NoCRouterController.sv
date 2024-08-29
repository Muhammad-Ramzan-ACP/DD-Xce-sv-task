module NoCRouterController (
    input  logic          clk,
    input  logic          reset,
    input  logic          valid_in,   // From Packet Generator
    output logic          ready_out,  // To Packet Generator
    output logic          buffer_enable, // Enables writing to the buffer
);
localparam IDLE    = 2'b00;
localparam RECEIVE = 2'b01;
localparam ROUTE   = 2'b10;
localparam BUFFER  = 2'b11;

logic [1:0] current_state;
logic[1:0] next_state;

// State transition logic
always_ff @(posedge clk or posedge reset) 
begin
    if (reset) 
    begin
        current_state <= #1 IDLE;
    end 
    else 
    begin
        current_state <= #1 next_state;
    end
end
// Next state logic
always_comb begin
    case (current_state)
        IDLE: begin
            if (valid_in) next_state = RECEIVE;
            else next_state = IDLE;
        end
        RECEIVE: begin
            next_state = ROUTE;
        end
        ROUTE: begin
            next_state = BUFFER;
        end
        BUFFER: begin
            next_state = IDLE;
        end
        default: next_state = IDLE;
    endcase
end
// Output logic
always_comb begin
    case (current_state)
        IDLE: begin
            ready_out     = 1'b0;
            buffer_enable = 1'b0;
        end
        RECEIVE: begin
            ready_out     = 1'b1;
            buffer_enable = 1'b0;
        end
        ROUTE: begin
            ready_out     = 1'b0;
            buffer_enable = 1'b0;
        end
        BUFFER: begin
            ready_out     = 1'b0;
            buffer_enable = 1'b1;
        end
        default: begin
            ready_out     = 1'b0;
            buffer_enable = 1'b0;
        end
    endcase
end
endmodule
