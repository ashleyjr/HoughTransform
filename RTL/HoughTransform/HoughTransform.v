/////////////////////////////////////////////////////////////////////
// Design unit : Camera Handler 
//             :
// File name   : HoughTransform.sv
//             :
//             :
//
// Author      : Ashley Robinson
//             : ajr2g10@ecs.soton.ac.uk
//             :
// Comments    : Do The transform
//             : This should take some time so dealy other stuff
//             :
//             : TODO: This is the hard bit, learn the theory
//             : TODO: Choose what shape(s) to implement??
/////////////////////////////////////////////////////////////////////


module HoughTransform(
   Reset,             // Common to all
   Clk,               // Common to all
   ImgMatIn,          // The input data
   AckOut,            // Acknowlegde from next stage
   ReqIn,             // Request from last stage
   ReqOut,            // Request to next stage
   AckIn,             // Acknowledge to last stage
   ImgMatOut,         // The image delayed
   OverlayMat         // The output is a single bit overlay the same size
);

   /*****************************************************************************************************************/ 
   // Parameters
   /*****************************************************************************************************************/

   parameter IMAGE_BITS = 8;
   parameter MATRIX_N = 120;                                                                 // Across
   parameter MATRIX_M = 120;                                                                 // Down
    
   parameter OVERLAY_FLAT_WIDE = MATRIX_N*MATRIX_M;
   parameter FLAT_WIDE = IMAGE_BITS*MATRIX_N*MATRIX_M;

   /*****************************************************************************************************************/ 
   // Input 
   /*****************************************************************************************************************/

   input                               Reset;
   input                               Clk;
   input       [FLAT_WIDE-1:0]         ImgMatIn;
   input                               AckOut;
   input                               ReqIn;

   /*****************************************************************************************************************/ 
   // Outputs 
   /*****************************************************************************************************************/

   output                              ReqOut;
   output                              AckIn;
   output reg  [FLAT_WIDE-1:0]         ImgMatOut;
   output reg  [OVERLAY_FLAT_WIDE-1:0] OverlayMat;


   /*****************************************************************************************************************/ 
   // Internal wires
   /*****************************************************************************************************************/

   reg                                 DelayReqIn;
   wire                                PipeState;


  
   /*****************************************************************************************************************/ 
   // Registers
   /*****************************************************************************************************************/

   integer i,j,k;

   always @ (posedge Clk or negedge Reset) begin
      if(!Reset) begin   
         OverlayMat <= 0;                                 // If low then reset everything to zero
         ImgMatOut <= 0;
         DelayReqIn <= 1;
      end else begin
         if(PipeState) begin                          // Last stage holds valid data, Next stage doesn't care
            ImgMatOut <= ImgMatIn;

            /*****************************************************************************************************************/ 
            // TODO HACK TODO
            /*****************************************************************************************************************/

            for(i = 0;i < MATRIX_M;i = i + 1) begin                                      
               for(j =0;j < MATRIX_N;j = j + 1) begin
                  if(ImgMatIn[(i*MATRIX_N*IMAGE_BITS) + (j*IMAGE_BITS) + IMAGE_BITS - 1]) begin
                     OverlayMat[(i*MATRIX_N) + j]  <= 1;       
                  end else begin
                     OverlayMat[(i*MATRIX_N) + j]  <= 0;     
                  end
               end
            end

         end 
         DelayReqIn <= ReqIn;
      end
   end


   /*****************************************************************************************************************/ 
   // Combo 
   /*****************************************************************************************************************/

   assign PipeState = DelayReqIn & ~AckOut;
   assign ReqOut = PipeState;
   assign AckIn = PipeState;   


   /*****************************************************************************************************************/ 
   // End
   /*****************************************************************************************************************/
endmodule
