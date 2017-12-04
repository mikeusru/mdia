function saveSpecimenInfo
%saveSpecimenInfo makes a text file and saves some info
global state dia

refPath=[state.files.savePath, '\specimenInfo.txt'];
g=dia.acq.cellInfo.genotype;
t=dia.acq.cellInfo.transDate;
d=dia.acq.cellInfo.div;
c=dia.acq.cellInfo.condition;
n=dia.acq.cellInfo.notes;
fileID=fopen(refPath,'wt');
fprintf(fileID,'%s\n',g);
fprintf(fileID,'%s%s\n','Transfection Date ', t);
fprintf(fileID,'%s%d\n','DIV ', d);
fprintf(fileID,'%s\n',c);
fprintf(fileID,'%s\n','');
fprintf(fileID,'%s\n',n');
fclose(fileID);
end

