load('gibbsSample_time1152_runAt20160522233101.mat');
v = VideoWriter('time1152video_noBurnIn.avi');

open(v);
for iterNum=1:2000
	if(mod(iterNum,10)==0)
		fprintf('Now processing iteration %d\n',iterNum);
	end
    ww = iterationMaps{iterNum};
    curImg = mat2gray(ww,[1 3]);
    for i = 1:5
        writeVideo(v,curImg);
    end
end


close(v);

%imgI = mat2gray(ww,[1 3]);
