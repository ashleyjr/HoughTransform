/////////////////////////////////////////////////////////////////////
// Design unit : Pre-Processing 
//             :
// File name   : PreProcessing.v
//             :
//             :
//
// Author      : Ashley Robinson
//             : ajr2g10@ecs.soton.ac.uk
//             :
// Comments    : Get raw image matrix from camera
//             : Strip it down for processing
//             : Wrapper for pipeline of processes
//             :  
/////////////////////////////////////////////////////////////////////


module PreProcessing(
   Reset,            // Common to all
   Clk,              // Common to all
   ImgMatIn,         // The input image matrix
   AckOut,           // Acknowlegde from next stage
   ReqIn,            // Request from last stage
   ReqOut,           // Request to next stage
   AckIn,            // Acknowledge to last stage
   ImgMatOut,        // The output image matrix
   ppImgMatOut       // The preprocessed matrix
);

   /*****************************************************************************************************************/ 
   // Parameters 
   /*****************************************************************************************************************/

   parameter IMAGE_BITS = 8;
   parameter MATRIX_N_IN = 120;                    // Across
   parameter MATRIX_M_IN = 120;                    // Down
   parameter MATRIX_N_OUT =120;                    // Across
   parameter MATRIX_M_OUT = 120;                   // Down

   parameter FLAT_WIDE_IN = IMAGE_BITS*MATRIX_N_IN*MATRIX_M_IN;
   parameter FLAT_WIDE_OUT = IMAGE_BITS*MATRIX_N_OUT*MATRIX_M_OUT;



   /*****************************************************************************************************************/ 
   // Inputs 
   /*****************************************************************************************************************/

   input                            Reset;
   input                            Clk;
   input       [FLAT_WIDE_IN-1:0]   ImgMatIn;
   input                            AckOut;
   input                            ReqIn;



   /*****************************************************************************************************************/ 
   // Outputs 
   /*****************************************************************************************************************/
   
   output                           ReqOut;
   output                           AckIn;
   output      [FLAT_WIDE_OUT-1:0]  ImgMatOut;
   output      [FLAT_WIDE_OUT-1:0]  ppImgMatOut;


   /*****************************************************************************************************************/ 
   // Processing 
   /*****************************************************************************************************************/

   // -- Image rotation -- //
   ImgRot
   #(
      .IMAGE_BITS (IMAGE_BITS),
      .MATRIX_N   (MATRIX_N_OUT),
      .MATRIX_M   (MATRIX_M_OUT),
      .ROTATE     (90)
   )
   ImgRot
   (
      .Reset      (Reset),
      .Clk        (Clk),
      .ImgMatIn   (ImgMatIn),
      .AckOut     (AckOut),         // AND from both ACKS
      .ReqIn      (ReqIn),
      .ReqOut     (ReqOut),
      .AckIn      (AckIn),
      .ImgMatOut  (ImgMatOut)

   );
  
   /*****************************************************************************************************************/ 
   // Glue
   /*****************************************************************************************************************/
   
   assign ppImgMatOut = ImgMatOut;

   /*****************************************************************************************************************/ 
   // End 
   /*****************************************************************************************************************/
endmodule
