
package spi_defines_pkg;

    `define TRUE 1'b1

// FIFO Parameters
    `define DATA_WIDTH   6'h20
    `define DEPTH        9'h100
    `define PTR_WIDTH    $clog2(`DEPTH)

// SPI Serializer Parameters
    `define BIT_COUNTER_WIDTH $clog2(`DATA_WIDTH)


endpackage
