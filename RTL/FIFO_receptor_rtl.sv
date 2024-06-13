module spi_serializer #(
    parameter DATAWIDTH = 32,
    parameter BITCOUNTERWIDTH = $clog2(DATAWIDTH)
) (
    input  logic                 clk,
    input  logic                 rst,
    input  logic                 full,        // Use full signal to start serialization
    input  logic                 empty,       // Use empty signal to prevent operations when FIFO is empty
    input  logic [DATAWIDTH-1:0] readData,
    output logic                 sclk,
    output logic                 mosi,
    output logic                 done
);

    typedef enum logic [1:0] {
        IDLE,
        LOAD,
        SHIFT,
        COMPLETE
    } state_t;

	state_t state, next_state;
    	logic [DATAWIDTH-1:0] shift_reg;
    	logic [BITCOUNTERWIDTH:0] bit_counter;
  	bit flag;
  	logic clk_div;
    	logic sclk_enable;
 
  	// Clock divider for generating sclk
    	always_ff @(posedge clk or posedge rst) begin
        	if (rst) begin
        		clk_div <= 1'b0;
        	end else begin
            		clk_div <= ~clk_div;
        	end
    	end

    	// Generate sclk based on divided clock and enable signal
    	always_ff @(posedge clk or posedge rst) begin
        	if (rst) begin
            		sclk <= 0;
        	end else if (clk_div && sclk_enable) begin
            		sclk <= ~sclk;
        	end
    	end
  
 
	always_ff @(posedge clk or posedge rst) begin
      		if (rst || empty) begin
            		state <= IDLE;
            		shift_reg <= '0;
            		bit_counter <= '0;	
        		flag  <= 1'b0;
          		done <= 1'b0;
            		mosi <= 1'b0;
            		sclk_enable <= 1'b0;
        	end else begin
            		state <= next_state;
            	case (state)
                LOAD: begin
                    shift_reg <= readData;
                    bit_counter <= DATAWIDTH;
                    sclk_enable <= 1'b1;  // Enable sclk during SHIFT state
                  	flag <= 1'b1;
                end
                SHIFT: begin
                    if (sclk && clk_div) begin  // Shift data on the positive edge of sclk
                      	flag <= 1'b0;
						mosi <= shift_reg[DATAWIDTH-1];
                        shift_reg <= shift_reg << 1; //1 Shift Left
                        bit_counter <= bit_counter - 1;
                    end
                end
                COMPLETE: begin
                    done <= 1;
                    sclk_enable <= 1'b0;  // Disable sclk in COMPLETE state
                end
            endcase
        end
    end

    	always_comb begin
        	next_state = state;
        	case (state)
            	IDLE: begin //00
              		if (full || !empty) next_state = LOAD;  // Only start when full and not empty
            	end
            	LOAD: begin //01
              		next_state = SHIFT;
            	end
            	SHIFT: begin //10
                	if (bit_counter == 1'b0) next_state = COMPLETE;
            	end
            	COMPLETE: begin //11
                	next_state = IDLE;
            	end
        	endcase
    	end
endmodule

