@ECHO OFF

START matlab /r "addpath(%2); global setSvobodaLabPaths_rootDir;setSvobodaLabPaths_rootDir=%1;setSvobodaLabPaths;"

EXIT