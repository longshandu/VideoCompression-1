
%%% mbSize -> size of block (ex 8 -> 8*8) p -> size of window search
%%% Quality -> quality value of the reconstructed video 
%%% nFrames -> number of frames to be processed 
%%% prev -> previous frame, curr -> current frame 
clc
clear 
close all
mbSize = 8;
p = 16;
index = 0;
Qaulity = 90;
nFrames = 120;

%%% Chnage the name of video "kirstina_Dimond_SAD_Q90" to whatever you like %% 
writer = VideoWriter('kirstina_Dimond_SAD_Q90.avi','Grayscale AVI');

%%% chose desirfe frame rate 
writer.FrameRate = 30;  
%%% open video for write 
open(writer);

%%% Initilize values 
mse = zeros(1,nFrames);
PSNR = zeros(1,nFrames);
NbitsV = zeros(1,nFrames);
bitFileBytes= zeros(1,nFrames);
histFileBytes= zeros(1,nFrames);
          
while index < nFrames
    
    index = index + 1;
    
    
   %%% Read first frame only once %%%%%%%%%%
   %%% chnage the name "kristenLowCut" of video if you want to supply one of yours 
   %%% in prev and curr 
    if index == 1
        prev = frame_read('natalieCutNew.mp4', 360, 640, index);               
    end
    
    %%%%%%%%%%%%%%%%%%% Read current frames %%%%%%%%%%%%%%%%%
    curr = frame_read('natalieCutNew.mp4', 360, 640, index + 1);
    prev = prev(:,1:640);
    curr = curr(:,1:640);
    
    %%%%%%%%%%%%Calculate MSR & PSNR %%%%%%%%%%%%%%%%%%%%%%%
        mse = immse(prev,curr);
        PSNR(1,index) = 10*log10((255^2)/mse);
    %%%%%%%%%%%%%%%%%%%% Motion estimation %%%%%%%%%%%%%%%%%%%%%%%%%%   
    
    %%%%%%%%%% Exhaustive search method using MAD  %%%%%%%%%%%%%%%%%%%%
%     [motionVect, computations] = motionEstES_MAD(curr,prev,mbSize,p);
      
    %%%%%%%%% Exhaustive search method using SAD  %%%%%%%%%%%%%%%%%%%%%
%      [motionVect, computations] = motionEstES_SAD(curr,prev,mbSize,p);
       
    %%%%%%%% Dimond Search method using MAD %%%%%%%%%%%%%%%%%%%%%%%%%%
%      [motionVect, computations] = motionEstDS_MAD(curr,prev,mbSize,p);
    
    
    %%%%%%%% Dimond Search method using SAD %%%%%%%%%%%%%%%%%%%%%%%%%%
     [motionVect, computations] = motionEstDS_SAD(curr,prev,mbSize,p);
     
    
    
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
 %%%%%%%%%%%%% Motion comp %%%%%%%%%%%%%%%

    imgComp = motionComp(prev, motionVect, mbSize);
    
    MCPR = double(curr) - double(imgComp);
%%%%%%%%%%%%% DCT+Q + Enco && return imag to reconstruct prev %%%%
    [Nbits, img_back] = Enc_DCT_img(MCPR,'one.bit',Qaulity);
    NbitsV(1,index) = Nbits;
    s = dir('one.bit');
    bitFileBytes(1,index) = s.bytes;
    t = dir('dct_hist.mat');
    histFileBytes(1,index) = t.bytes;
%%%%%%%%%%%%%%%% Q^-1 & IDCT for prev %%%%%%%%%%%%%%%%%
    img_Back = Qinv_IDCT(img_back);
    prev = double(img_Back) + double(imgComp); 
       
%%%%%%%%%%%% Decode frame %%%%%%%%%%%%%%
    img_dec = DEC_DCT('one.bit');
    
    %%% previous frame for decoding + decoded frame %%%%
    if index == 1
    imgComp_DEC = motionComp(prev, motionVect, mbSize);
    else
     imgComp_DEC = motionComp(prev_dec, motionVect, mbSize);  
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    recon_img = double(img_dec) + double(imgComp_DEC);
    
    prev_dec = recon_img;
    
%%%%%%%%%% Write images/frames to output file %%%%%%%%%%%%%%%%%%%%%%%%%%%
    if index == 1
    k = mat2gray(prev);
    else
    k = mat2gray(prev_dec);  
    end
    imwrite(k, 'kirstina_1_reconst.jpg');    
    img = imread('kirstina_1_reconst.jpg');
    writeVideo(writer,img); 
    
    writeVideo(writer,k); 
    
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5   

end

%%%%% Save all varaibles for analysis and plots %%%%%%%%%%

save bitFileBytes_ESMB_MAD_R16_Q50 bitFileBytes
save histFileBytes_ESMB_MAD_R16_Q50 histFileBytes
save PSNR_ESMB_MAD_R16_Q50 PSNR
save NbitsV_ESMB_MAD_R16_Q50 NbitsV

  close(writer);