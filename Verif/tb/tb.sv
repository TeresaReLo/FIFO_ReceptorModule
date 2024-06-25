module tb;

// Parameters

  parameter DATAWIDTH = 32;
  parameter BITCOUNTERWIDTH = $clog2(DATAWIDTH);

  // Signals

  bit clk, rst; 
 
  logic [DATAWIDTH-1:0] read_data;

  logic full, empty, sclk, mosi, done;

 
spi_serializer #(

  	.DATAWIDTH(DATAWIDTH),
  	.BITCOUNTERWIDTH(BITCOUNTERWIDTH)

  ) dut (

    .clk(clk),

    .rst(rst),

    .full(full),

  	.empty(empty),
      
  	.read_data(read_data),
  
  	.sclk(sclk),
  
  	.mosi(mosi),
  
  	.done(done)

  );
 
 
 
    // Generate clock signal
    always begin
        #5 clk = ~clk; // 100MHz clock period (10ns)
    end
 
 
// Stimulus generation

initial begin

    // Initialize Inputs

    rst <= 1'b1;

    full <= 1'b0;

    read_data <= '0;

    empty <= 1'b0;
 
    // Reset

    @(posedge clk);

    @(posedge clk);

    rst <= 1'b0;

    // Write data into FIFO

  
  repeat(300) begin

        @(posedge clk);

       read_data <= $urandom;
	
        full<= $urandom;

      // empty <= $urandom; 

    end    


  

    // Finish simulation

    $finish;

  end

    // Monitor signals
    initial begin
        $monitor("Time: %0t | clk: %b | rst: %b | full: %b | empty: %b | readData: %h | sclk: %b | mosi: %b | done: %b", 
        $time, clk, rst, full, empty, read_data, sclk, mosi, done);
    end

      //Simulation config

    initial begin

        $timeformat(-9, 2, " ns", 20);

      $dumpfile("FIFO.vcd"); $dumpvars;

    end
 


//bind spi_serializer fv_fifo fv_fifo_inst(.*); 

endmodule : tb