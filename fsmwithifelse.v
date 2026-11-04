`timescale 1s/1ms

module traffic_light(
    input clk,
    input rst,
    output reg [1:0] colour
);


localparam [1:0] RED = 2'b00;
localparam [1:0] RED_YELLOW = 2'b01;
localparam [1:0] GREEN = 2'b10;
localparam [1:0] YELLOW = 2'b11;

localparam [3:0] RED_WAIT_TIME = 4'b1010;
localparam [3:0] GREEN_GO_TIME = 4'b1010;
localparam [3:0] YELLOW_SHOW_TIME = 2'b10;

reg [3:0] t = 4'd0;

initial begin
    colour <= RED;
    t <= 0;
end

always @(posedge clk) begin
    if (rst) begin
        colour <= RED;
        t <= 0;
    end else begin
    case (colour)
        RED: begin
            if (t == RED_WAIT_TIME - 1) begin
                colour <= RED_YELLOW;
                t <= 0;
            end
            else begin
                t <= t + 1;
            end
        end

        RED_YELLOW: begin
            if (t == YELLOW_SHOW_TIME - 1) begin
                colour <= GREEN;
                t <= 0;
            end
            else begin
                t <= t + 1;
            end
        end

        GREEN: begin
            if (t == GREEN_GO_TIME - 1) begin
                colour <= YELLOW;
                t <= 0;
            end
            else begin
                t <= t + 1;
            end
        end

        YELLOW: begin
            if (t == YELLOW_SHOW_TIME - 1) begin
                colour <= RED;
                t <= 0;
            end
            else begin
                t <= t + 1;
            end
        end
    endcase
    end
end

endmodule