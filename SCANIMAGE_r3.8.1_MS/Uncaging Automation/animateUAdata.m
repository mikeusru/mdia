function animateUAdata(folder_name)
%animateUAdata is meant to create tiff stacks from the multiposition
%imaging data
%make user select folder
global dataStruct

if nargin<1
    folder_name=uigetdir('C:\Users\yasudalab\Documents\data');
end
listing0=dir(folder_name);
dataStruct=struct;

ind = ~cellfun(@isempty,strfind({listing0.name},'Position'));
listing0 = listing0(ind);
allFiles = getAllFiles(folder_name);

%load all images into dataStruct
for i=1:length(listing0)
    posFolder = [folder_name, '\', listing0(i).name];
    dataStruct(i).dirPath{1} = posFolder;
    ind = ~cellfun(@isempty,strfind(allFiles,posFolder));
    posFiles = allFiles(ind);
    ind = ~cellfun(@isempty,strfind(posFiles,'max'));
    posFiles = posFiles(ind);
    dataStruct(i).posFiles = posFiles;
    %     [~,fname,~] = cellfun(@fileparts,posFiles,'UniformOutput',false);
    for j=1:length(posFiles)
        info = imfinfo(posFiles{j},'tif');
        dataStruct(i).info{j} = info;
        num_images = numel(info);
        for k=1:num_images
            dataStruct(i).imageChan(k).stack{j} = imread(posFiles{j}, k, 'Info', info);
        end
    end
end


%write files to tiffs
dirPath=[folder_name,'\_Stacks'];
if ~exist(dirPath, 'dir')
    mkdir(dirPath);
end

for i=1:length(dataStruct)
    [~,posStr,~]=fileparts(dataStruct(i).dirPath{1});
    for j = 1:length(dataStruct(i).imageChan)
        fname=[dirPath, '\',posStr,'_Ch',num2str(j),'.tif'];
        A = uint16(zeros(size(dataStruct(i).imageChan(j).stack{1})));
        imwrite(A,fname,'tif','WriteMode','overwrite');
        for k=2:length(dataStruct(i).imageChan(j).stack)
            A(:,:,k)=uint16(dataStruct(i).imageChan(j).stack{k});
            imwrite(A(:,:,k),fname,'tif','WriteMode','append');
        end
    end
end

disp('Files successfully created from maximum projection images');
%
%
%
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%     listing1=dir(dataStruct(ii).dirPath{1});
%
%     kk=1;
%
%     for k=1:length(listing1)
%         %if file is not dir or max projection, read it into the structure
%         if ~listing1(k).isdir && strcmp(listing1(k).name(end-2:end),'tif') &&  ~strcmp(listing1(k).name(end-6:end-4),'max')
%             %             if ~listing1(k).isdir && strcmp(listing1(k).name(end-6:end),'max.tif')
%
%             fname=[dataStruct(ii).dirPath{1},'\',listing1(k).name];
%             info = imfinfo(fname,'tif');
%             num_images = numel(info);
%             if kk==1
%                 %                     A=zeros(info(1).Height,info(1).Width,num_images);
%                 A=zeros(info(1).Height,info(1).Width,2);
%                 Ch1=zeros(info(1).Height,info(1).Width,num_images/2);
%                 Ch2=zeros(info(1).Height,info(1).Width,num_images/2);
%                 dataStruct(ii).postUncageImages=zeros(size(A));
%             end
%
%             if num_images>1
%                 for j = 1:num_images
%                     %                         A(:,:,j) = imread(fname, j, 'Info', info);
%                     if mod(j,2)==1
%                         Ch1(:,:,(j+mod(j,2))/2)=imread(fname, j, 'Info', info);
%                     elseif mod(j,2)==0
%                         Ch2(:,:,(j+mod(j,2))/2)=imread(fname, j, 'Info', info);
%                     end
%
%
%                 end
%             else
%                 A(:,:,1) = imread(fname, 'Info', info);
%             end
%             Ch1Max=Ch1(:,:,1);
%             Ch2Max=Ch2(:,:,1);
%             for q=1:size(Ch1,3)
%                 Ch1Max=max(Ch1Max(:,:,1),Ch1(:,:,q));
%             end
%             for q=1:size(Ch2,3)
%                 Ch2Max=max(Ch2Max(:,:,1),Ch2(:,:,q));
%             end
%             dataStruct(ii).postUncageImages(:,:,1,kk)=Ch1Max;
%             dataStruct(ii).postUncageImages(:,:,2,kk)=Ch2Max;
%
%             %                 dataStruct(ii).postUncageImages(:,:,:,kk)=A;
%             kk=kk+1;
%         end
%
%
%         % read pre-uncaging images in now
%         if isdir([folder_name, '\', listing0(i).name, '\' , 'pre-uncaging'])
%             dataStruct(ii).dirPath{2}=[folder_name, '\', listing0(i).name, '\' , 'pre-uncaging'];
%             listing1=dir(dataStruct(ii).dirPath{2});
%             kk=1;
%             for k=1:length(listing1)
%                 %if file is not dir or max projection, read it into the structure
%                 if ~listing1(k).isdir && strcmp(listing1(k).name(end-2:end),'tif') &&  ~strcmp(listing1(k).name(end-6:end-4),'max')
%                     %                 if ~listing1(k).isdir && strcmp(listing1(k).name(end-6:end),'max.tif')
%
%                     fname=[dataStruct(ii).dirPath{2},'\',listing1(k).name];
%                     info = imfinfo(fname,'tif');
%                     num_images = numel(info);
%                     if kk==1
%                         %                         A=zeros(info(1).Height,info(1).Width,num_images);
%                         A=zeros(info(1).Height,info(1).Width,2);
%                         Ch1=zeros(info(1).Height,info(1).Width,num_images/2);
%                         Ch2=zeros(info(1).Height,info(1).Width,num_images/2);
%                         dataStruct(ii).preUncageImages=zeros(size(A));
%                     end
%                     for j = 1:num_images
%                         %                         A(:,:,j) = imread(fname, j, 'Info', info);
%                         if mod(j,2)==1
%                             Ch1(:,:,(j+mod(j,2))/2)=imread(fname, j, 'Info', info);
%                         elseif mod(j,2)==0
%                             Ch2(:,:,(j+mod(j,2))/2)=imread(fname, j, 'Info', info);
%                         end
%
%
%                     end
%                     Ch1Max=Ch1(:,:,1);
%                     Ch2Max=Ch2(:,:,1);
%
%                     for q=1:size(Ch1,3)
%                         Ch1Max=max(Ch1Max(:,:,1),Ch1(:,:,q));
%                     end
%                     for q=1:size(Ch2,3)
%                         Ch2Max=max(Ch2Max(:,:,1),Ch2(:,:,q));
%                     end
%                     dataStruct(ii).preUncageImages(:,:,1,kk)=Ch1Max;
%                     dataStruct(ii).preUncageImages(:,:,2,kk)=Ch2Max;
%                     %                     dataStruct(ii).preUncageImages(:,:,:,kk)=A;
%                     kk=kk+1;
%                 end
%
%             end
%         end
%
%         ii=ii+1;
%     end
% end
%
% %write files to tiffs
% dirPath=[folder_name,'\_Stacks'];
% try
%     mkdir(dirPath);
% end
% for j=1:length(dataStruct)
%     %first do post-uncage images
%     %     dirPath=[dataStruct(j).dirPath{1},'\Stacks'];
%     %     mkdir(dirPath);
%     [~,posStr,~]=fileparts(dataStruct(j).dirPath{1});
%     for k=1:size(dataStruct(j).postUncageImages,3)
%
%         fname=[dirPath, '\',posStr,'_POST_UncageStack','_Ch',num2str(k),'.tif'];
%         A=uint16(zeros(size(dataStruct(j).postUncageImages(:,:,k,1))));
%         A(:,:,1)=uint16(dataStruct(j).postUncageImages(:,:,k,1));
%         imwrite(A,fname,'tif','WriteMode','overwrite');
%         for i=2:size(dataStruct(j).postUncageImages,4)
%             A(:,:,i)=uint16(dataStruct(j).postUncageImages(:,:,k,i));
%             imwrite(A(:,:,i),fname,'tif','WriteMode','append');
%         end
%     end
%     %then do pre-uncage images
%     %     dirPath=dataStruct(j).dirPath{2};
%     if isfield(dataStruct(j),'preUncageImages')
%         for k=1:size(dataStruct(j).preUncageImages,3)
%             fname=[dirPath, '\', posStr, '_PRE_UncageStack','_Ch',num2str(k),'.tif'];
%             A=uint16(zeros(size(dataStruct(j).preUncageImages(:,:,k,1))));
%             A(:,:,1)=uint16(dataStruct(j).preUncageImages(:,:,k,1));
%             imwrite(A,fname,'tif','WriteMode','overwrite');
%             for i=2:size(dataStruct(j).preUncageImages,4)
%                 A(:,:,i)=uint16(dataStruct(j).preUncageImages(:,:,k,i));
%                 imwrite(A(:,:,i),fname,'tif','WriteMode','append');
%             end
%         end
%     end
% end
%
% disp('Files successfully created from maximum projection images in Position#');
% disp('and Position#\pre-uncaging folders');

%
% A=uint16(zeros(128,128));
% A(:,:,1)=uint16(dataStruct(1).postUncageImages(:,:,3,1));
% imwrite(A,'images.tif','tif','WriteMode','overwrite');
% for i=2:size(dataStruct(1).postUncageImages,4)
%     A(:,:,i)=uint16(dataStruct(1).postUncageImages(:,:,3,i));
%     imwrite(A(:,:,i),'images.tif','tif','WriteMode','append');
% end


% for k = 2:size(A,4)
%     imwrite(A(:,:,1,k), 'images', 'WriteMode', 'append');
% end

% end

