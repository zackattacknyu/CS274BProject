load('gibbsSample_time1114_runAt20160612235911.mat');
v = VideoWriter('time1114video_3edgeFeats.avi');

open(v);
for iterNum=1:3000
	if(mod(iterNum,10)==0)
		fprintf('Now processing iteration %d\n',iterNum);
	end
    ww = iterationMaps{1,iterNum};
    curImg = mat2gray(ww,[1 3]);
    for i = 1:5
        writeVideo(v,curImg);
    end
end


close(v);

%imgI = mat2gray(ww,[1 3]);
