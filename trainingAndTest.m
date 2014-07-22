% initialize the variables
alphabet=char(65:90);
trainingFeatures=[];
trainlabel=[];

for d = 1:25
    for i=1 : 100
    % exclude 'j' case
    if(d==10)
        continue;
    end

    combinedStr=strcat('backup/',alphabet(d),'/',alphabet(d),'_',num2str(i),'.png');
    img=imread(combinedStr);
    
    % preprocessing for image threshold
    img = preProcess(img);
    
    % resize the image to 100*100 pixel
    img=imresize(img,[100,100]);
    img=double(img);

    % extract HOG features & generate the traininglabel, features
    trainingFeatures= [trainingFeatures;double(extractHOGFeatures(img,'CellSize',[4 4]))];
    trainlabel=[trainlabel;d];
    end
end

% save the label, features
save('trainset','trainingFeatures');
save('trainlabel','trainlabel');

% using trainingSet, execute the svmtraining in cost of 10
% generate the svm model
svmstruct=svmtrain(trainlabel,trainingFeatures,'-c 10');
save('svmstruct','svmstruct');


% test on the svm model
alphabet=char(65:90);
table=zeros(25,25);
for d=1:25
    for i=1:100
        if(d==10)
            continue;
        end
        combinedStr=strcat('backup/',alphabet(d),'/',alphabet(d),'_',num2str(i),'.png');
        img=imread(combinedStr);
        
        % resize image to 100*100 
        img=imresize(img,[100,100]);
        img=double(img);
    
        % extract HOG features from testSet
        testset=double(extractHOGFeatures(img,'CellSize',[4 4]));
        testlabel=d;
        
        % check whether the model is correct or not
        predict=svmpredict(testlabel,testset,svmstruct);
        if(testlabel~=predict)
            table(testlabel,predict)=table(testlabel,predict)+1;
        end
    end
end