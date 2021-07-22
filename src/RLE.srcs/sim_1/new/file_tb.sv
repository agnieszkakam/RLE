`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: AGH
// Engineer: Agnieszka Kamien
// 
// Create Date: 21.07.2021 17:47:39
// Design Name: RLE 
// Module Name: file_tb
// 
//////////////////////////////////////////////////////////////////////////////////

module file_tb ();

/**
 * Parameters
 */
 
localparam MAX_NR_OF_VECTORS = 32;

/**
 * Local variables and signals
*/

int file;             //file handle
int i, idx, tab [MAX_NR_OF_VECTORS];

initial begin  
    file = $fopen ("testvectors.txt", "r");
    
    if (file) begin 
        $display("File was opened successfully : %0d", file);
        
        while (!$feof(file)) begin
          $fscanf(file,"%d",idx);
          $display("i=%0d (%d)", i, idx);
          tab[i] = idx;
          i = i + 1;
          if (i == MAX_NR_OF_VECTORS)
            break;
        end
        
        $fclose(file);
        
        for (int i = 0; i < MAX_NR_OF_VECTORS; i++) begin
          $display ("%d", tab[i]);
        end
        
    end
    else
        $display("File was not opened successfully : %0d", file);
    
    $stop;
end
endmodule
