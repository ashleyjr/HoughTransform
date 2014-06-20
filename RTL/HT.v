/////////////////////////////////////////////////////////////////////
// Design unit : Hough transform  
//             :
// File name   : HT.sv
//             :
//             :
//
// Author      : Ashley Robinson
//             : ajr2g10@ecs.soton.ac.uk
//             :
// Comments    : Top wrapper 
//             : Module instances, to/from outside world and interconnecting wires only
/////////////////////////////////////////////////////////////////////


module HT(
   Reset,
   Clk,
   CameraData,
   chReqIn,
   vgaAckOut,
   chAckIn,
   vgaReqOut,
   Output 
);



   /*****************************************************************************************************************/ 
   // Parameters
   /*****************************************************************************************************************/

   parameter IMAGE_BITS       = 8;
   parameter RAW_MATRIX_N     = 10;                                                       // Raw matrix - Across
   parameter RAW_MATRIX_M     = 10;                                                       // Raw matrix - Down 
   parameter PP_MATRIX_N      = 10;                                                       // Pre-processed matrix - Across
   parameter PP_MATRIX_M      = 10;                                                       // Pre-processed matrix - Down 

   parameter RAW_FLAT_WIDE = IMAGE_BITS*RAW_MATRIX_N*RAW_MATRIX_M;
   parameter PP_FLAT_WIDE = IMAGE_BITS*PP_MATRIX_N*PP_MATRIX_M;
   parameter FLAT_WIDE = PP_MATRIX_N*PP_MATRIX_M;


   /*****************************************************************************************************************/ 
   // Inputs
   /*****************************************************************************************************************/

   input                                  Reset;
   input                                  Clk;
   input    [RAW_FLAT_WIDE-1:0]           CameraData;
   input                                  chReqIn;
   input                                  vgaAckOut;


   /*****************************************************************************************************************/ 
   // Outputs
   /*****************************************************************************************************************/

   output                                 chAckIn;
   output                                 vgaReqOut;
   output   [PP_FLAT_WIDE-1:0]            Output;

   /*****************************************************************************************************************/ 
   // Wires to connect modules
   /*****************************************************************************************************************/

   // ---- Image matrices ---- //

   wire     [RAW_FLAT_WIDE-1:0]        RawImgMat;        
   wire     [PP_FLAT_WIDE-1:0]         pp2htImgMat;      
   wire     [PP_FLAT_WIDE-1:0]         ht2mxImgMat; 
   wire     [FLAT_WIDE-1:0]            OverlayMat;       
   wire     [PP_FLAT_WIDE-1:0]         MixedMat;         


   // ---- Pipeline control ---- //

   wire                                chReq;            // Request in to first stage, dummy?
   wire                                ch2ppReq;         // Request out of camera handler into pre-processing 
   wire                                pp2chAck;         // Acknowledge from pre-processing into camera handler
   wire                                ppReq;            // Request out of pre-processing, may go to many blocks 
   wire                                ht2ppAck;         // Acknowledge in to pre-processing from hough
   wire                                mx2ppAck;
   wire                                ht2mxReq;
   wire                                mx2htAck;
   wire                                mx2vgaReq;
   wire                                vga2mxAck;
   wire                                vgaReq;
   wire                                vgaAck;


   /*****************************************************************************************************************/ 
   // Camera Handler module
   /*****************************************************************************************************************/


   CameraHandler 
   #(
      .IMAGE_BITS       (IMAGE_BITS),
      .MATRIX_N         (RAW_MATRIX_N),                                                   // Keep dimensions throughout 
      .MATRIX_M         (RAW_MATRIX_M)
   )
   CameraHandler                                                                          // Same name as only one
   (
      .Reset            (Reset),
      .Clk              (Clk),
      .CameraData       (CameraData),                                                     // TODO: This will change
      .AckOut           (pp2chAck),
      .ReqIn            (chReqIn),
      .AckIn            (chAckIn), //TODO: Used in testbench to generate data
      .ReqOut           (ch2ppReq),           
      .ImgMat           (RawImgMat)                                                       // Connect
   );


   /*****************************************************************************************************************/ 
   // Pre-Processing module
   /*****************************************************************************************************************/


   PreProcessing 
   #(
      .IMAGE_BITS       (IMAGE_BITS),
      .MATRIX_N_IN      (RAW_MATRIX_N),                                                   // Fall through from top
      .MATRIX_M_IN      (RAW_MATRIX_M),
      .MATRIX_N_OUT     (PP_MATRIX_N),                                                    // Fall through from top
      .MATRIX_M_OUT     (PP_MATRIX_M) 
   )
   PreProcessing                                                                          // Same name as only one
   (
      .Reset            (Reset),
      .Clk              (Clk),
      .ImgMatIn         (RawImgMat),
      .AckOut           (ht2ppAck),
      .ReqIn            (ch2ppReq),
      .ReqOut           (ppReq),
      .AckIn            (pp2chAck),
      .ImgMatOut        (pp2htImgMat)
   );



   /*****************************************************************************************************************/ 
   // The Hough Transform module
   /*****************************************************************************************************************/


   HoughTransform 
   #(
      .IMAGE_BITS       (IMAGE_BITS),
      .MATRIX_N         (PP_MATRIX_N),                                                    // Fall through from top
      .MATRIX_M         (PP_MATRIX_M)
   )
   HoughTransform                                                                         // Same name as only one
   (
      .Reset            (Reset),
      .Clk              (Clk),
      .ImgMatIn         (pp2htImgMat),
      .AckOut           (mx2htAck),
      .ReqIn            (ppReq),
      .ReqOut           (ht2mxReq),
      .AckIn            (ht2ppAck),
      .ImgMatOut        (ht2mxImgMat),
      .OverlayMat       (OverlayMat)
   );


   /*****************************************************************************************************************/ 
   // Mixer module
   /*****************************************************************************************************************/


   Mixer
   #(
      .IMAGE_BITS       (IMAGE_BITS),
      .MATRIX_N         (PP_MATRIX_N),                                                    // Fall through from top
      .MATRIX_M         (PP_MATRIX_M)
   )
   Mixer                                                                                  // Same name as only one
   (
      .Reset            (Reset),
      .Clk              (Clk),
      .ImgMat           (ht2mxImgMat),
      .OverlayMat       (OverlayMat),
      .AckOut           (vga2mxAck),
      .ReqIn            (ht2mxReq),
      .ReqOut           (mx2vgaReq),
      .AckIn            (mx2htAck),
      .MixedMat         (MixedMat)
   );


   /*****************************************************************************************************************/ 
   // VGA Handler module
   /*****************************************************************************************************************/


   VgaHandler
   #(
      .IMAGE_BITS       (IMAGE_BITS),
      .MATRIX_N         (PP_MATRIX_N),                                                    // Fall through from top
      .MATRIX_M         (PP_MATRIX_M)
   )
   VgaHandler                                                                             // Same name as only one
   (
      .Reset            (Reset),
      .Clk              (Clk),
      .ImgMat           (MixedMat),
      .AckOut           (vgaAckOut),
      .ReqIn            (mx2vgaReq),
      .ReqOut           (vgaReqOut),
      .AckIn            (vga2mxAck),
      .VgaMat           (Output)
   );




   /*****************************************************************************************************************/ 
   // END 
   /*****************************************************************************************************************/


endmodule
