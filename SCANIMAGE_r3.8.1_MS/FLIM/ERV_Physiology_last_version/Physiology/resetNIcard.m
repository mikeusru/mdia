function resetNIcard

%Function to Reset National Instruments Devices from MATLAB
%
%This function performs the same function as pushing the "Reset Device" button from Measurement & Automation Explorer (MAX).
%Note that the Matlab function daqreset does not reset devices but Matlab objects. To reset devices use this function instead.
%After running this function all Matlab acquisition objects will be invalid. Make sure to clear them from the workspace.
%
%FOR NATIONAL INSTRUMENTS M-SERIES CARDS WITH NIDAQ-MX
%(Not tested in E-series cards but it should work)
%(Will not work in Traditional NiDaq environments if NiDaq-mx is not installed)
%
%This function requires the Sub-Subfunction "mxpseudoproto" to have the correct syntax from nicaiu.dll
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%After installing a new NI-DAQ version (or porting the function to a new computer),
%run the following lines to load the library and create the prototype M-file:
%
%hfile = ['C:\Program Files\National Instruments\NI-DAQ\DAQmx ANSI C Dev\include\NIDAQmx.h'];
%loadlibrary('nicaiu.dll', hfile, 'mfilename', 'mxproto');
%
%Then open the created file "mxproto.m" and search for the line containing "DAQmxResetDevice".
%Make sure that line is identical to the one in the Sub-Subfunction "mxpseudoproto".
%Also check the beginning of the Sub-Subfunction and the begining of mxproto.m for differences.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Matlab 2006a
%Emiliano M. Rial Verde
%April 2007
%emiliano@rialverde.com


LoadNicaiu; %Calls the subfunction that loads the National Instruments DLL
a=daqhwinfo('nidaq'); %Finds installed devices
a=a.InstalledBoardIds; %Gets device names
for i=1:max(size(a))
    b=calllib('nicaiu', 'DAQmxResetDevice', a{i}); %Resets the devices found
    if b==0
        disp([a{i}, ' reset completed!']);
    else
        warning([a{i}, ' reset FAILED!']);
    end
end
UnloadNicaiu; %Calls the subfunction that un-loads the National Instruments DLL

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Subfunction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LoadNicaiu
%Loads the library nicaiu.dll
if ~libisloaded('nicaiu') % checks if library is loaded
    loadlibrary('nicaiu.dll', @mxpseudoproto);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Subfunction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UnloadNicaiu
%Unoads the library nicaiu.dll
if libisloaded('nicaiu') % checks if library is loaded
    unloadlibrary('nicaiu');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Sub-Subfunction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [methodinfo,structs,enuminfo]=mxpseudoproto;
%MXPROTO Create structures to define interfaces found in 'NIDAQmx'.
ival={cell(1,0)}; % change 0 to the actual number of functions to preallocate the data.
fcns=struct('name',ival,'calltype',ival,'LHS',ival,'RHS',ival,'alias',ival);
structs=[];enuminfo=[];fcnNum=1;
% int32 _stdcall DAQmxResetDevice ( const char deviceName []); 
fcns.name{fcnNum}='DAQmxResetDevice'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'cstring'};fcnNum=fcnNum+1;
methodinfo=fcns;