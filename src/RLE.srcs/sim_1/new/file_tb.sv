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

int file, i, idx;
int mem [MAX_NR_OF_VECTORS];

logic [7:0] tab [MAX_NR_OF_VECTORS];

/**
 * Tasks
*/
task read_vectors_from_txt (output logic [7:0] testvectors [MAX_NR_OF_VECTORS]);
    
    automatic int line_counter = 0;
    automatic logic [7:0] line = 0;
   
    file = $fopen ("testvectors.txt", "r");
    
    if (file) begin 
        $display("File was opened successfully : %0d", file);
        
        while (!$feof(file)) begin
          $fscanf(file,"%d",line);
          testvectors[line_counter] = line;
          line_counter = line_counter + 1;
          if (line_counter == MAX_NR_OF_VECTORS)
            break;
        end
        
        $fclose(file);      
    end
    else
        $display("File was not opened successfully : %0d", file);
endtask


/**
 * Test
*/

initial begin
    
    read_vectors_from_txt(tab);
    
    for (int i = 0; i < MAX_NR_OF_VECTORS; i++) begin
      $display ("%d", tab[i]);
    end
    
    $display("Loading rom.");
    $readmemh("testvectors.mem", mem);
    
    for (int i = 0; i < MAX_NR_OF_VECTORS; i++) begin
          $display ("%d", mem[i]);
    end
    
    $stop;
end
endmodule
