module Toplevel (
    input  logic clk,
    input  logic reset
);

    // Signals between modules
    logic [12:0] packet;
    logic valid, ready, buffer_enable;
    logic [12:0] buffered_packet;
    logic [1:0] route;

    // Instantiate Packet Generator
    PacketGenerator pkt_gen (
        .clk                 (clk),
        .reset               (reset),
        .ready_out            (ready),
        .valid_in           (valid),
        .packet_out          (packet)
    );

    // Instantiate NoC Router Input Port
    NoCRouterInputPort noc_router (
        .clk                 (clk),
        .reset               (reset),
        .valid_in            (valid),
        .packet_in           (packet),
        .ready_out           (ready),
        .buffered_packet_out (buffered_packet),
        .route               (route)
    );

    // Instantiate NoC Router Controller
    NoCRouterController noc_controller (
        .clk                 (clk),
        .reset               (reset),
        .valid_in            (valid),
        .ready_out           (ready),
        .buffer_enable       (buffer_enable),
        //.route(route)
    );

endmodule







