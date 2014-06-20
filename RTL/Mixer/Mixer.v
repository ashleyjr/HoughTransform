/////////////////////////////////////////////////////////////////////
// Design unit : Mixer
//             :
// File name   : Mixer.v
//             :
//             :
//
// Author      : Ashley Robinson
//             : ajr2g10@ecs.soton.ac.uk
//             :
// Comments    : Mix HT lines with the original image
//             :
//             : TODO: What goes in and comes out??
/////////////////////////////////////////////////////////////////////


module Mixer(
   Reset,             // Common to all
   Clk,               // Common to all
   ImgMat,            // The input image matrix
   OverlayMat,        // The input image matrix
   AckOut,            // Acknowlegde from next stage
   ReqIn,             // Request from last stage
   ReqOut,            // Request to next stage
   AckIn,             // Acknowledge to last stage
   MixedMat           // The output image matrix
);

   /*****************************************************************************************************************/ 
   // Parameters 
   /*****************************************************************************************************************/

   parameter IMAGE_BITS = 8;
   parameter MATRIX_N = 120;                                                                          // Across
   parameter MATRIX_M = 120;                                                                          // Down

   parameter FLAT_WIDE = IMAGE_BITS*MATRIX_N*MATRIX_M;
   parameter OVERLAY_FLAT_WIDE = MATRIX_N*MATRIX_M;



   /*****************************************************************************************************************/ 
   // Inputs
   /*****************************************************************************************************************/

   input                                  Reset;
   input                                  Clk;
   input       [FLAT_WIDE-1:0]            ImgMat;
   input       [OVERLAY_FLAT_WIDE-1:0]    OverlayMat;
   input                                  AckOut;
   input                                  ReqIn;



   /*****************************************************************************************************************/ 
   // Outputs
   /*****************************************************************************************************************/

   output                                 ReqOut;
   output                                 AckIn;

   output reg  [FLAT_WIDE-1:0]            MixedMat;


   /*****************************************************************************************************************/ 
   // Internal wires
   /*****************************************************************************************************************/

   reg                                    DelayReqIn;
   wire                                   PipeState;
   wire        [FLAT_WIDE-1:0]            nextMixedMat;

   /*****************************************************************************************************************/ 
   // Registers
   /*****************************************************************************************************************/
                                       

   integer i,j,k;

   always @ (posedge Clk or negedge Reset) begin
      if(!Reset) begin   
         MixedMat <= 0;                               // If low then reset everything to zero
         DelayReqIn <= 1;
      end else begin
         if(PipeState) begin

            /*****************************************************************************************************************/ 
            // Mixing
            /*****************************************************************************************************************/

            for(i = 0;i < MATRIX_M;i = i + 1) begin                                      
               for(j =0;j < MATRIX_N;j = j + 1) begin
                  if(OverlayMat[(i*MATRIX_N) + j]) begin                                                                          // Look for ones in the overlay matrix 
                     for(k = 0;k < IMAGE_BITS;k = k + 1) begin
                        MixedMat[(i*MATRIX_N*IMAGE_BITS) + (j*IMAGE_BITS) + k] <= 1;                                                         // Max value
                     end
                  end else begin
                     for(k = 0;k < IMAGE_BITS;k = k + 1) begin
                        MixedMat[(i*MATRIX_N*IMAGE_BITS) + (j*IMAGE_BITS) + k] <= 0;      // Let pixel pass
                     end
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


   assign nextMixedMat = ImgMat;
   
   /*****************************************************************************************************************/ 
   // End
   /*****************************************************************************************************************/

endmodule

