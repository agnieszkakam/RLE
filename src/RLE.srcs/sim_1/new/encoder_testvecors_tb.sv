`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: AGH
// Engineer: Agnieszka Kamien
// 
// Create Date: 22.07.2021 17:45:17
// Design Name: RLE 
// Module Name: encoder_testvecors_tb
// 
//////////////////////////////////////////////////////////////////////////////////


module encoder_testvecors_tb();

/**
 * Parameters
 */
 
localparam MAX_NR_OF_VECTORS = 32;


/**
 * Local variables and signals
*/

int file;             //file handle
int i, idx, tab [MAX_NR_OF_VECTORS];


/**
 * Test
*/

initial begin  
    file = $fopen ("encoder_testvectors.txt", "r");
    
    if (file) begin 
        $display("File was opened successfully : %0d", file);
        
        while (!$feof(file)) begin
          $fscanf(file,"%x",idx);
          tab[i] = idx;
          i = i + 1;
          if (i == MAX_NR_OF_VECTORS)
            break;
        end
        
        $fclose(file);      
    end
    else
        $display("File was not opened successfully : %0d", file);
    
    $stop;
end
endmodule
