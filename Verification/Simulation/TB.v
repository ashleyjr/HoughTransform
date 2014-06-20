/////////////////////////////////////////////////////////////////////
// Design unit : Hough transform testbench
//             :
// File name   : TB.sv
//             :
//             :
// Author      : Ashley Robinson
//             : ajr2g10@ecs.soton.ac.uk
//             :
// Comments    : Top level test bench. 
//             : Any other tests called from here
/////////////////////////////////////////////////////////////////////



`timescale 1ns/1ns

module TB;
    
   /*****************************************************************************************************************/ 
   // Parameters    
   /*****************************************************************************************************************/

   // Hardware

   parameter CLK_PERIOD = 10;          // 100MHz clock - 10ns period  
   parameter IMAGE_BITS = 8;           // 8 bit coding therefore 256 levels of intensity
   parameter IN_MATRIX_N = 80;        // Temp matrix dimensions
   parameter IN_MATRIX_M = 80;
   parameter OUT_MATRIX_N = 80;
   parameter OUT_MATRIX_M = 80;

   parameter FLAT_WIDE = IMAGE_BITS*IN_MATRIX_N*IN_MATRIX_M;

   // Tesetbench
   parameter NUMBER_TEST_IMAGES = 2;



   /*****************************************************************************************************************/ 
   // Test signals
   /*****************************************************************************************************************/ 


   reg                        reset;
   reg                        clk;
   reg      [FLAT_WIDE-1:0]   in;
   reg                        chReqIn;
   reg                        vgaAckOut;
   wire                       chAckIn;
   wire                       vgaReqOut;
   wire     [FLAT_WIDE-1:0]   out; 





   /*****************************************************************************************************************/ 
   // Hook test signals up to DUT instance
   /*****************************************************************************************************************/ 

   HT 
   #(
      .IMAGE_BITS    (IMAGE_BITS),
      .RAW_MATRIX_N  (IN_MATRIX_N),   
      .RAW_MATRIX_M  (IN_MATRIX_M), 
      .PP_MATRIX_N   (OUT_MATRIX_N),                                                       
      .PP_MATRIX_M   (OUT_MATRIX_M)   
   )
   HT_DUT
   (
      .Reset         (reset),
      .Clk           (clk),
      .CameraData    (in),
      .chReqIn       (chReqIn),
      .vgaAckOut     (vgaAckOut),
      .chAckIn       (chAckIn),
      .vgaReqOut     (vgaReqOut),
      .Output        (out)
   );
  



   /*****************************************************************************************************************/ 
   // Variables 
   /*****************************************************************************************************************/ 

   integer                       file;
   integer                       status;
   integer                       i,j,k;
   integer                       load;
   integer                       ticks;
   reg [IMAGE_BITS-1:0]          value;





   /*****************************************************************************************************************/ 
   // Output 
   /*****************************************************************************************************************/ 

   initial begin
      $dumpfile("TB.vcd");
      $monitor("Tick = %d",ticks);
      $dumpvars(0,TB);
   end



   /*****************************************************************************************************************/ 
   // Clock generation
   /*****************************************************************************************************************/ 


   initial begin
      ticks = 0;
      while(1) begin
         #(CLK_PERIOD/2) clk = 0;
         #(CLK_PERIOD/2) clk = 1;
         ticks = ticks + 1;
      end
   end



   /*****************************************************************************************************************/ 
   // Test images I/O 
   /*****************************************************************************************************************/ 


   task LoadImage;
      input [31:0] Image;
      begin
         case(Image)
            0:       file = $fopen("/home/ashley/Electronics/HoughTransform/Verification/Simulation/Lenna.dat","r");    // Lenna
            default: file = $fopen("/home/ashley/Electronics/HoughTransform/Verification/Simulation/Stairs.dat","r");   // Stairs 
         endcase
         for(i=0;i<IN_MATRIX_M;i=i+1) begin                     
            for(j=0;j<IN_MATRIX_N;j=j+1) begin
               status = $fscanf(file,"%d",value);                                      // Readline
               for(k=0;k<IMAGE_BITS;k=k+1) begin                                       // Access bits 
                  in[(i*IN_MATRIX_N*IMAGE_BITS) + (j*IMAGE_BITS) + k] = value[k];      // Flatten out as vector for porting
               end
            end
         end
         $fclose(file);
      end
   endtask


   task SaveImage;
      begin
         file = $fopen("/home/ashley/Electronics/HoughTransform/Verification/Simulation/OutputImage.dat","w");   // Stairs 
         for(i=0;i<IN_MATRIX_M;i=i+1) begin                     
            for(j=0;j<IN_MATRIX_N;j=j+1) begin
               for(k=0;k<IMAGE_BITS;k=k+1) begin                                       // Access bits 
                  value[k] = out[(i*IN_MATRIX_N*IMAGE_BITS) + (j*IMAGE_BITS) + k];      // Flatten out as vector for porting
               end
               $fwrite(file,"%d\n",value);
            end
         end
         $fclose(file);
      end
   endtask


   

   /*****************************************************************************************************************/ 
   // Activity 
   /*****************************************************************************************************************/ 

   initial load = 0;
   always @(negedge clk) begin
      if(!chAckIn) begin
         LoadImage(load);                                            // Load an image in series 
         load = (load == (NUMBER_TEST_IMAGES-1)) ? 0 : load + 1;     // Load increment or reset
      end
   end


   initial 
   begin 
            chReqIn = 1;
            vgaAckOut = 0;
            reset = 1;
      #7    reset = 0;
      #15   reset = 1;

      #40   chReqIn = 0;               // Stall the pipeline
      #100  chReqIn = 1;

 //     #50   vgaAckOut = 1;             // Keep final output, all other data is lost in pipe stall
  //    #100  vgaAckOut = 0;
      

      SaveImage();                     // Save the final output

      $stop();
   end



endmodule



