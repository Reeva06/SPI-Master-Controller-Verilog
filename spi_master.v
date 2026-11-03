module spi_master (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start,
    input  wire [7:0] tx_data,
    output reg  [7:0] rx_data,
    output reg        busy,
    output reg        sclk,
    output reg        mosi,
    input  wire       miso,
    output reg        cs_n
);

    localparam IDLE      = 2'b00;
    localparam TRANSFER  = 2'b01;
    localparam DONE      = 2'b10;

    reg [1:0] state;
    reg [2:0] bit_cnt;
    reg [7:0] shift_reg_tx;
    reg [7:0] shift_reg_rx;
    reg       clk_div;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= IDLE;
            busy         <= 1'b0;
            cs_n         <= 1'b1;
            sclk         <= 1'b0;
            mosi         <= 1'b0;
            bit_cnt      <= 3'd7;
            clk_div      <= 1'b0;
            shift_reg_tx <= 8'h00;
            shift_reg_rx <= 8'h00;
            rx_data      <= 8'h00;
        end else begin
            case (state)
                IDLE: begin
                    busy    <= 1'b0;
                    cs_n    <= 1'b1;
                    sclk    <= 1'b0;
                    clk_div <= 1'b0;
                    if (start) begin
                        state        <= TRANSFER;
                        busy         <= 1'b1;
                        cs_n         <= 1'b0;
                        shift_reg_tx <= tx_data;
                        bit_cnt      <= 3'd7;
                        mosi         <= tx_data[7];
                    end
                end

                TRANSFER: begin
                    clk_div <= ~clk_div;
                    if (!clk_div) begin
                        // SPI Mode 0: Sample MISO on rising edge of SCLK
                        sclk         <= 1'b1;
                        shift_reg_rx <= {shift_reg_rx[6:0], miso};
                    end else begin
                        // Shift MOSI on falling edge of SCLK
                        sclk <= 1'b0;
                        if (bit_cnt == 0) begin
                            state <= DONE;
                        end else begin
                            bit_cnt      <= bit_cnt - 1;
                            shift_reg_tx <= {shift_reg_tx[6:0], 1'b0};
                            mosi         <= shift_reg_tx[6];
                        end
                    end
                end

                DONE: begin
                    sclk    <= 1'b0;
                    cs_n    <= 1'b1;
                    busy    <= 1'b0;
                    rx_data <= shift_reg_rx;
                    state   <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
