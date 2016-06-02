%load('gibbsSample_time325_runAt20160522232046_2.mat');

%files = {'gibbsSample_time1114_runAt20160528164231',...
%'gibbsSample_time325_runAt20160528150142'};

%files = {'gibbsSample_time325_runAt20160528225331'};

files = {...
'gibbsSample_time1114_runAt20160528235525',...
'gibbsSample_time1152_runAt20160529031056',...
'gibbsSample_time204_runAt20160529081312',...
'gibbsSample_time284_runAt20160529095756'};

times = {'1114','1152','204','804'};

for timeNum = 1:length(times)
    
    load(files{timeNum});
    
    for seq = 1:size(iterationMaps,1)
        
        fileNm = strcat('time',times{timeNum},'video_seq',num2str(seq),'.avi');
        v = VideoWriter(fileNm);
        
        open(v);
        for iterNum=1:size(iterationMaps,2)
            if(mod(iterNum,10)==0)
                fprintf('Now processing iteration %d for seq %d in time %s\n',iterNum,seq,times{timeNum});
            end
            ww = iterationMaps{seq,iterNum};
            curImg = mat2gray(ww,[1 3]);
            for i = 1:5
                writeVideo(v,curImg);
            end
        end
        close(v);
    end
end

%imgI = mat2gray(ww,[1 3]);
