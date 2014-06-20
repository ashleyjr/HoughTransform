/////////////////////////////////////////////////////////////////////
// Design unit : VGA Handler
//             :
// File name   : VgaHandler.v
//             :
//             :
//
// Author      : Ashley Robinson
//             : ajr2g10@ecs.soton.ac.uk
//             :
// Comments    : Take care of processing for a VGA screen 
//             :
//             : TODO: HACK so sims dump a static image file
/////////////////////////////////////////////////////////////////////


module VgaHandler(
   Reset,               // Common to all
   Clk,                 // Common to all
   ImgMat,              // The input image matrix
   AckOut,              // Acknowlegde from next stage
   ReqIn,               // Request from last stage
   ReqOut,              // Request to next stage
   AckIn,               // Acknowledge to last stage
   VgaMat               // The output image matrix
);

   /*****************************************************************************************************************/ 
   // Parameters 
   /*****************************************************************************************************************/

   parameter IMAGE_BITS = 8;
   parameter MATRIX_N = 120;                                                                    // Across
   parameter MATRIX_M = 120;                                                                           // Down

   parameter FLAT_WIDE = IMAGE_BITS*MATRIX_N*MATRIX_M;

   /*****************************************************************************************************************/ 
   // Inputs
   /*****************************************************************************************************************/

   input                         Reset;
   input                         Clk;
   input       [FLAT_WIDE-1:0]   ImgMat;
   input                         AckOut;
   input                         ReqIn;

   /*****************************************************************************************************************/ 
   // Outputs 
   /*****************************************************************************************************************/

   output                        ReqOut;
   output                        AckIn;
   output reg  [FLAT_WIDE-1:0]   VgaMat;


   /*****************************************************************************************************************/ 
   // Internal wires
   /*****************************************************************************************************************/

   reg                           DelayReqIn;
   wire                          PipeState;
   wire        [FLAT_WIDE-1:0]   nextVgaMat;

  
   /*****************************************************************************************************************/ 
   // Registers
   /*****************************************************************************************************************/

   always @ (posedge Clk or negedge Reset) begin
      if(!Reset) begin   
         VgaMat <= 0;                                 // If low then reset everything to zero
         DelayReqIn <= 1;
      end else begin
         if(PipeState) begin                          // Last stage holds valid data, Next stage doesn't care
            VgaMat <= nextVgaMat;                     // Capture
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
   assign nextVgaMat = ImgMat;      


   /*****************************************************************************************************************/ 
   // End
   /*****************************************************************************************************************/

endmodule
