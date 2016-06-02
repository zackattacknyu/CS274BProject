%load('gibbsSample_time325_runAt20160522232046_2.mat');

files = {'gibbsSample_time1114_runAt20160528164231',...
'gibbsSample_time325_runAt20160528150142'};

times = {'1114','325'};

for timeNum = 1:length(times)
    
    load(files{timeNum});
    
    seq=1;
        
    fileNm = strcat('time',times{timeNum},'video_seq',num2str(seq),'.avi');
    v = VideoWriter(fileNm);

    open(v);
    for iterNum=1:3000
        if(mod(iterNum,10)==0)
            fprintf('Now processing iteration %d for seq %d in time %s\n',iterNum,seq,times{timeNum});
        end
        ww = iterationMaps{iterNum};
        curImg = mat2gray(ww,[1 3]);
        for i = 1:5
            writeVideo(v,curImg);
        end
    end
    close(v);
    
end

%imgI = mat2gray(ww,[1 3]);
