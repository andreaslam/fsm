`timescale 1s/1ms

module traffic_light(
    input clk,
    input rst,
    output wire [1:0] colour
);

localparam [1:0] RED = 2'b00;
localparam [1:0] RED_YELLOW = 2'b01;
localparam [1:0] GREEN = 2'b10;
localparam [1:0] YELLOW = 2'b11;

localparam [3:0] RED_WAIT_TIME = 4'b1010;
localparam [3:0] GREEN_GO_TIME = 4'b1010;
localparam [3:0] YELLOW_SHOW_TIME = 2'b10;

reg [1:0] current_state;
reg [1:0] next_state;

reg [3:0] state_duration;
reg [3:0] timer;

always @(*) begin
    case (current_state)
        RED: begin
            next_state = RED_YELLOW;
            state_duration = RED_WAIT_TIME;
        end

        RED_YELLOW: begin
            next_state = GREEN;
            state_duration = YELLOW_SHOW_TIME;
        end

        GREEN: begin
            next_state = YELLOW;
            state_duration = GREEN_GO_TIME;
        end

        YELLOW: begin
            next_state = RED;
            state_duration = YELLOW_SHOW_TIME;
        end

        default: begin
            next_state = RED;
            state_duration = RED_WAIT_TIME;
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        current_state <= RED;
        timer <= 4'd0;
    end
    else if (timer == state_duration - 1'b1) begin
        current_state <= next_state;
        timer <= '0;
    end else begin
    timer <= timer + 1;
    end
end

always @(*) begin
    colour = current_state;
end

endmodule
