function [fieldnames,default_vals,data_types] = getfieldnames
% This is a private function to access the valide fieldnames for the
% Multi_Clamp class.  The only updates that need to be made are to this list
% when changing the object fields.  The constructors automatically reflect
% these updates.
%
% OUTPUTS
% fieldnames - cell array of strings;  current fieldnames.
% default_vals - cell array; default values for constructor.
% data_types - cell array of strings; default classes of each field.
% internal - array of bools; 1 = not settable by user through set and get
%            methods.
%
% Field definitions:
% amplifier internal gain
% amplifier internal mode (possibly ...)
% boolean; is amplifier in a current clamp mode?
% amplifier internal v_hold (holding potential (voltage clamp) or holding current (current clamp)
% parent is the name of the base class
% channel is the channel number on the multiclamp
% v_clamp_input_factor is the hardware gain on the 200 B amplifier in the
% voltage clamp mode.
% i_clamp_input_factor is the hardware gain on the 200 B amplifier in the
% current clamp mode
% v_clamp_output_factor is the hardware gain on the 200 B amplifier in the
% voltage clamp mode.
% i_clamp_output_factor is the hardware gain on the 200 B amplifier in the
% current clamp mode
%
% CHANGES
%  TO112008D - Switch to using MulticlampTelegraph.mexw32 as an interface. -- Tim O'Connor 11/20/08

fieldnames = {'text_file_location','gain','mode','current_clamp','v_hold','parent','channel',...
    'i_clamp_input_factor','v_clamp_input_factor','i_clamp_output_factor','v_clamp_output_factor', ...
    'saveTime', 'loadTime', ...
    'uComPortID', 'uAxoBusID', 'uSerialNum', 'uChannelID'};
default_channel=1;
matlab_version = version;
if str2num(matlab_version(1:3)) < 7
    parent='amplifier';
else
     parent='AMPLIFIER';
end
default_vals = {'',1,'V_CLAMP',0,0,parent,default_channel,...
    1, 1, .0025, .05, ...
    zeros(1, 6), zeros(1, 6), ...
    -1, -1, -1, -1};
% default_vals = {[matlabroot '\Physiology\MClampChannel' num2str(default_channel) '.txt'],1,'V_CLAMP',0,0,parent,default_channel,...
%     1000, 1000, .0005, .05, ...
%     zeros(1, 6), zeros(1, 6)};
data_types = {'char','double','char','double','double','char','double','double','double','double','double', ...
              'double', 'double', 'double', 'double', 'double', 'double'};
internal = [0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0];