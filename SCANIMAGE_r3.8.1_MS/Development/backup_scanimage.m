%save matlab folder to share drive
a=clock;
year=num2str(a(1));
month=num2str(a(2));
if length(month)==1 % add 0 in front of single digit months
    month=strcat('0',month);
end
day=num2str(a(3));
b=dir('Z:\Yasuda\User-Personal\Misha\MATLAB\');
version=1;
name=strcat({'Scanimage - '}, year, {'-'}, month, {'-'}, day, '(',num2str(version)',')');
target_folder=strcat('Z:\Yasuda\User-Personal\Misha\MATLAB\',name);
while exist(target_folder{1})
version=version+1;
name=strcat({'Scanimage - '}, year, {'-'}, month, {'-'}, day, '(',num2str(version)',')');
target_folder=strcat('Z:\Yasuda\User-Personal\Misha\MATLAB\',name);
end
disp('Writing to: ');
disp(target_folder{1});
folder_name=uigetdir;
disp('Please wait while copying folder...');
[status,message] = copyfile(folder_name,char(target_folder),'f');
if status==1
    disp('success');
else
    disp(message);
end
