function  mainDir  = readMainDir
%mainDir  = readMainDir reads the main scanimage directory
%mainDir needs to be in the main directory
mainDir=mfilename('fullpath');
[mainDir,~,~]=fileparts(mainDir);
end

