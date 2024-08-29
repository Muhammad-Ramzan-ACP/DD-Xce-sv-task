module noc_router_tb;

    // Packet structure definition
    typedef struct {
        logic [1:0] dest;
        logic [1:0] package_type;
        logic [7:0] payload;
        logic       eop;
    } packet_t;

    // DUT signals
    logic          clk;
    logic          reset;
    logic          valid_in;
    logic          ready_out;
    packet_t       packet_in;
    packet_t       packet_out;

    // Clock generation
    initial
    begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Packet Generator
    module SequenceGenerator (
        output packet_t packet_out,
        output logic    valid_in,
        input  logic    ready_out,
        input  logic    clk,
        input  logic    reset
    );

        packet_t packet;
        logic [2:0] scenario_counter;

        always_ff @(posedge clk or posedge reset) 
        begin
            if (reset) 
            begin
                scenario_counter <= #1 0;
                valid_in         <= #1 0;
            end 
            else if (ready_in) 
            begin
                case (scenario_counter)
                    0: packet = '{dest: 2'b00, package_type: 2'b00, payload: 8'hA5, eop: 1'b1}; // Single packet
                    1: packet = '{dest: 2'b01, package_type: 2'b01, payload: 8'h5A, eop: 1'b1}; // Burst transfer sta
                    2: packet = '{dest: 2'b01, package_type: 2'b00, payload: 8'hFF, eop: 1'b0}; // Burst transfer con
                    3: packet = '{dest: 2'b01, package_type: 2'b00, payload: 8'h00, eop: 1'b1}; // Burst transfer end
                    4: packet = '{dest: 2'b10, package_type: 2'b10, payload: 8'hAA, eop: 1'b1}; // Different packet t
                    5: packet = '{dest: 2'b11, package_type: 2'b11, payload: 8'h55, eop: 1'b1}; // Reserved type
                    default: packet = '{dest: 2'b00, package_type: 2'b00, payload: 8'h00, eop: 1'b1};
                endcase
                scenario_counter <= scenario_counter + 1;
                valid_in        <= #1 1'b1;
                packet_out      <= #1 packet;
            end 
            else 
            begin
                valid_in   <= #1 1'b0;
            end
        end
    endmodule

    // Driver
    module Driver (
        input  packet_t  packet_in,
        input  logic     valid_in,
        output logic     ready_out,
        output logic     [12:0] packet_out,
        input  logic     clk,
        input  logic     reset
    );

        always_ff @(posedge clk or posedge reset) 
        begin
            if (reset) 
            begin
                ready_out  <= #1 1'b0;
                packet_out <= #1 13'b0;
            end 
            else if (valid_in) 
            begin
                ready_out  <= #1 1'b1;
                packet_out <= #1 {packet_in.dest, packet_in.package_type, packet_in.payload, packet_in.eop};
            end 
            else 
            begin
                ready_out  <= #1 1'b0;
                valid_out  <= #1 1'b0;
            end
        end
    endmodule

    // Monitor
    module Monitor (
        input logic       valid_in,
        input packet_t    packet_out,
        input logic       clk
    );

        always_ff @(posedge clk) 
        begin
            if (valid_in) 
            begin
                $display("Time: %0t | Packet Sent: Dest=%0b Packege_Type=%0b Payload=%0h EOP=%0b", 
                         $time, packet_out.dest, packet_out.package_type, packet_out.payload, packet_out.eop);
            end
        end
    endmodule

    // Scoreboard
    module Scoreboard (
        input logic       valid_in,
        input packet_t    packet_out,
        input logic       clk
    );

        always_ff @(posedge clk) 
        begin
            if (valid_in) 
            begin
                // Add checks based on the expected behavior of the DUT
                if (packet_out.package_type == 2'b00) 
                begin
                    assert(packet_out.dest == 2'b00 || packet_out.dest == 2'b01 || 
                           packet_out.dest == 2'b10 || packet_out.dest == 2'b11) 
                    else $error("Invalid destination address for packet type 00");
                end
            end
        end
    endmodule
    // Instantiate the components
    SequenceGenerator seq_gen (
        .packet_out(packet_in),
        .valid_in(valid_in),
        .ready_out(ready_out),
        .clk(clk),
        .reset(reset)
    );

    Driver driver (
        .packet_in(packet_in),
        .valid_in(valid_in),
        .ready_out(ready_out),
        //.valid_out(valid_out),
        .packet_out(packet_out),
        .clk(clk),
        .reset(reset)
    );

    Monitor monitor (
        .valid_in(valid_in),
        .packet_out(packet_out),
        .clk(clk)
    );

    Scoreboard scoreboard (
        .valid_in(valid_in),
        .packet_out(packet_out),
        .clk(clk)
    );
    // Initial block
    initial begin
        $dumpfile("noc_router_tb.vcd");
        $dumpvars(0, noc_router_tb);
        reset <= #1 1;
        @(posedge clk);
        reset <= #1 0;
        repeat (20) @(posedge clk);
        $finish;
    end
endmodule

