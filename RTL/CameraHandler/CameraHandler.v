/////////////////////////////////////////////////////////////////////
// Design unit : Camera Handler 
//             :
// File name   : CameraHandler.v
//             :
//             :
//
// Author      : Ashley Robinson
//             : ajr2g10@ecs.soton.ac.uk
//             :
// Comments    : Interface with whatever camera is implemented 
//             : Output a matrix image
//             :
//             : TODO: Find a camera and put frame grabber in here
/////////////////////////////////////////////////////////////////////


module CameraHandler(
   Reset,                                                      // Common to all
   Clk,                                                        // Common to all
   CameraData,                                                 // The input data
   AckOut,                                                     // Acknowlegde from next stage
   ReqIn,                                                      // Request from last stage
   ReqOut,                                                     // Request to next stage
   AckIn,                                                      // Acknowledge to last stage
   ImgMat                                                      // The output image matrix
);

   /*****************************************************************************************************************/ 
   // Parameters 
   /*****************************************************************************************************************/

   parameter IMAGE_BITS = 8;
   parameter MATRIX_N = 120;                                   // Across
   parameter MATRIX_M = 120;                                   // Down

   parameter FLAT_WIDE = IMAGE_BITS*MATRIX_N*MATRIX_M;


   /*****************************************************************************************************************/ 
   // Inputs
   /*****************************************************************************************************************/

   input                         Reset;
   input                         Clk;
   input       [FLAT_WIDE-1:0]   CameraData;
   input                         AckOut;
   input                         ReqIn;



   /*****************************************************************************************************************/ 
   // Outputs
   /*****************************************************************************************************************/

   output                        ReqOut;
   output                        AckIn;
   output reg  [FLAT_WIDE-1:0]   ImgMat;


   /*****************************************************************************************************************/ 
   // Internal wires
   /*****************************************************************************************************************/

   reg                            DelayReqIn;
   wire                           PipeState;
   wire         [FLAT_WIDE-1:0]   nextImgMat;

   /*****************************************************************************************************************/ 
   // Registers 
   /*****************************************************************************************************************/
  

   always @ (posedge Clk or negedge Reset) begin
      if(!Reset) begin   
         ImgMat <= 0;                                 // If low then reset everything to zero
         DelayReqIn <= 1;
      end else begin
         if(PipeState) begin                          // Last stage holds valid data, Next stage doesn't care
            ImgMat <= nextImgMat;                     // Capture
         end
         DelayReqIn <= ReqIn;                         // Need to delay ReqIn to make stable
      end
   end



   /*****************************************************************************************************************/ 
   // Combo 
   /*****************************************************************************************************************/
 
   assign PipeState = DelayReqIn & ~AckOut;
   assign ReqOut = PipeState;
   assign AckIn = PipeState;
   assign nextImgMat = CameraData;    



   /*****************************************************************************************************************/ 
   // End 
   /*****************************************************************************************************************/

endmodule
