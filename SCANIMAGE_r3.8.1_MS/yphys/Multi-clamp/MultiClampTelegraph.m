% MultiClampTelegraph - Interface to the Axon Multiclamp software.
%
% SYNTAX
%  MultiClampTelegraph(command)
%  result = MultiClampTelegraph(command)
%  MultiClampTelegraph(command, ...)
%  [result, ...] = MultiClampTelegraph(command, ...)
%    command - A string, indicating the action to be performed, see below.
%              Multiple actions may be performed, per mex call.
%    result - The return value, if any, from the corresponding command.
%             Multiple results may be returned, if multiple commands are issued.
%
% USAGE
%  Commands:
%   broadcast - Send a request for all Multiclamp Commanders to identify themselves and their amplifiers/channels.
%   getAmplifier - Gets the state of the amplifier.
%                  Args: The ID of the amplifier.
%                  Returns: A struct representing the amplifier.
%   getAllAmplifiers - Retrieves all known states.
%                      Returns a cell array of state structures.
%   get700AID - Returns the unique ID associated with a specified 700A amplifier channel.
%               Args: uComPortID, uAxoBusID, uChannelID
%               All arguments must be of type uint16.
%   get700BID - Returns the unique ID associated with a specified 700B amplifier channel.
%               Args: uSerialNum, uChannelID
%               All arguments must be of type uint16.
%   requestTelegraph - Requests that the Multiclamp Commander send an updated telegraph for the specified ID.
%                      Args: The ID of the amplifier.
%   displayAllAmplifiers - Prints all known states to the screen.
%   openConnection - Opens a connection to a Multiclamp Commander, to recieve automatic change notifications (ie. subscribe).
%                    Args: The ID of the amplifier.
%   closeConnection - Closes a connection to a Multiclamp Commander, to stop recieving automatic change notifications (ie. unsubscribe).
%                     Args: The ID of the amplifier.
%   shutdown - Shuts down the messaging system and releases all dynamic memory (this is the same effect as `clear mex` would have).
%   version - Prints the MulticlampTelegraph version number to the screen.
%
%  Structure:
%   .ID - A unique ID, used to address the amplifier.
%   .uOperatingMode - A string representing the current mode.
%   .uScaledOutSignal - The name of the scaled (primary) output signal.
%   .dAlpha - Gain of scaled (primary) output.
%   .dScaleFactor - Scale factor of scaled (primary) output.
%   .uScaleFactorUnits - A string representing the scale factor of scaled (primary) output
%   .dLPFCutoff - Lowpass filter cutoff frequency [Hz] of scaled (primary) output.
%   .dMembraneCap - Membrane capacitance [F].
%   .dExtCmdSens - External command sensitivity.
%   .uRawOutSignal - A string representing the signal identifier of raw (secondary) output.
%   .dRawScaleFactor - Gain scale factor of raw (secondary) output.
%   .uRawScaleFactorUnits - A string representing the scale factor units of raw (secondary) output.
%   .uHardwareType - Hardware type identifier: 'MCTG_HW_TYPE_MC700A' or 'MCTG_HW_TYPE_MC700B'
%   .dSecondaryAlpha - Gain of raw (secondary) output.
%   .dSecondaryLPFCutoff - Lowpass filter cutoff frequency [Hz] of raw (secondary) output.
%   .szAppVersion - Application version of MultiClamp Commander 2.x.
%   .szFirmwareVersion - Firmware version of MultiClamp 700B.
%   .szDSPVersion - DSP version of MultiClamp 700B.
%   .szSerialNumber - Serial number of MultiClamp 700B.
%   .stateAge - The elapsed time since this structure has been updated, in seconds.
%   .uComPortID - The COM port ID. Only applies to 700A.
%   .uAxoBusID - The AXOBUS ID. Only applies to 700A.
%   .uChannelID - The Channel ID.
%   .uSerialNum - The serial number. Only applies to 700B.
%
% NOTES
%  See MultiClampTelegraph.cpp, and its associated documentation, for more information.
%
% CHANGES
%
% Created 10/26/08 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008