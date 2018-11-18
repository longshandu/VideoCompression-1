function frameMP4 = read_MP4Frame (infile, frame_index)
ReadObj = VideoReader(infile); 
CurFrame = 0;
GetFrame = [0 frame_index];
% disp('h')
while hasFrame(ReadObj)
    CurImage = readFrame(ReadObj);
    CurFrame = CurFrame+1;
%     disp('h1')
    if ismember(CurFrame, GetFrame)
%         disp('h2')
        imwrite(CurImage, sprintf('frame%d.jpg', CurFrame));
        whos CurFrame
        frameMP4 = sprintf('frame%d.jpg', CurFrame);
    end
end
% disp('h4')