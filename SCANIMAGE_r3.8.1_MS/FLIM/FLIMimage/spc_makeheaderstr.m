function headerstr = spc_makeheaderstr
global spc
global state gh

headerstr = '';
size = spc.size;
sizestr = ['spc.size=', mat2str(spc.size), ';', 13];

state.motor.position = get(gh.motorControls.pmPosnID, 'Value')-1; %For compatibility.

spc.scanHeader = parseHeader(state.headerString);
spc.scanHeader.motor.position = state.motor.position;

headerstr = [headerstr, sizestr];

try
        str1 = mkstr('spc.datainfo');
catch
        str1 = '';
	disp('error in spc_makeheaderstr: str1');
end
try
        str2 = mkstr('spc.fit');
catch
        str2 = '';
        disp('error in spc_makeheaderstr: str2');
end
try
        str3 = mkstr('spc.switches');
catch
        str3 = '';
        disp('error in spc_makeheaderstr: str3');
end
try
        str4 = mkstr('spc.SPCdata');
catch
        str4 = '';
        disp('error in spc_makeheaderstr: str4');
end
try
        str5 = mkstr('spc.scanHeader');
catch
        str5 = '';
        disp('error in spc_makeheaderstr: str5');
end


headerstr = [headerstr, str1, str2, str3, str4, str5];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function headerstr = mkstr (arraystr)
global spc
headerstr = '';

evalc(['global spc; fn = fieldnames(', arraystr, ')']);

for i=1:length(fn)
    a = cell2struct(fn(i), 'a', 1);
    fieldstr = [arraystr, '.', a.a];
    eval (['ntr = isnumeric(', fieldstr, ');']);
    eval (['ctr = ischar(', fieldstr, ');']);
    eval (['sttr = isstruct(', fieldstr, ');']);      
    if  sttr
        exestr = mkstr(fieldstr); %decode_struct (fieldstr);
    elseif ntr
        valstr = mat2str(eval (fieldstr));
        exestr = [fieldstr, ' =    ', valstr, ';', 13]; %Margin 3.
    elseif ctr
        strA = eval(fieldstr);
        strA(strfind(strA, '''')) = [];        
        valstr = strcat('''', strA, '''');
        exestr = [fieldstr, ' = ', valstr, ';', 13];
    else
        exestr = '';    
    end
    eval(headerstr);
    headerstr = [headerstr, exestr];        
end
