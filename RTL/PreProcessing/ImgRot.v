/////////////////////////////////////////////////////////////////////
// Design unit : Image rotation  
//             :
// File name   : ImgRot.v
//             :
//             :
//
// Author      : Ashley Robinson
//             : ajr2g10@ecs.soton.ac.uk
//             :
// Comments    : 
//             : 
//             :
//             : TODO: Rotatation of matrix for wire placment 
/////////////////////////////////////////////////////////////////////


module ImgRot(
   Reset,            // Common to all
   Clk,              // Common to all
   ImgMatIn,         // The input image matrix
   AckOut,           // Acknowlegde from next stage
   ReqIn,            // Request from last stage
   ReqOut,           // Request to next stage
   AckIn,            // Acknowledge to last stage
   ImgMatOut         // The output image matrix
);

   /*****************************************************************************************************************/ 
   // Parameters 
   /*****************************************************************************************************************/

   parameter IMAGE_BITS = 8;
   parameter MATRIX_N = 120;                    // Across
   parameter MATRIX_M = 120;                    // Down
   parameter ROTATE = 90;

   parameter FLAT_WIDE = IMAGE_BITS*MATRIX_N*MATRIX_M;



   /*****************************************************************************************************************/ 
   // Inputs 
   /*****************************************************************************************************************/

   input                            Reset;
   input                            Clk;
   input       [FLAT_WIDE-1:0]      ImgMatIn;
   input                            AckOut;
   input                            ReqIn;



   /*****************************************************************************************************************/ 
   // Outputs 
   /*****************************************************************************************************************/
   
   output                           ReqOut;
   output                           AckIn;
   output reg  [FLAT_WIDE-1:0]      ImgMatOut;


   /*****************************************************************************************************************/ 
   // Internal wires
   /*****************************************************************************************************************/

   reg                              DelayReqIn;
   wire                             PipeState;


   /*****************************************************************************************************************/ 
   // Registers 
   /*****************************************************************************************************************/

   integer i,j,iNew,jNew,k;

   always @ (posedge Clk or negedge Reset) begin
      if(!Reset) begin   
         ImgMatOut <= 0;                              // If low then reset everything to zero
         DelayReqIn <= 1;
      end else begin
         if(PipeState) begin                          // Last stage holds valid data, Next stage doesn't care

            /*****************************************************************************************************************/ 
            // Processing 
            /*****************************************************************************************************************/

            for(i = 0;i < MATRIX_M;i = i + 1) begin                                      
               for(j =0;j < MATRIX_N;j = j + 1) begin

                  // How to map wire to the next stage

                  iNew = i;  // Flip it    
                  jNew = j;

                  for(k = 0;k < IMAGE_BITS;k = k + 1) begin
                     ImgMatOut[(iNew*MATRIX_N*IMAGE_BITS) + (jNew*IMAGE_BITS) + k] <= ImgMatIn[(i*MATRIX_N*IMAGE_BITS) + (j*IMAGE_BITS) + k];    // Put in a new place in a new matrix
                  end

               end
            end
         end
         DelayReqIn <= ReqIn;
      end
   end


   /*****************************************************************************************************************/ 
   // Pipeline combo
   /*****************************************************************************************************************/
 
   assign PipeState = DelayReqIn & ~AckOut;
   assign ReqOut = PipeState;
   assign AckIn = PipeState;



   /*****************************************************************************************************************/ 
   // End 
   /*****************************************************************************************************************/
endmodule
