#include "mex.h"
#include "th260defin.h"
#include "th260lib.h"
#include "errorcodes.h"
#include "stdlib.h";

void mexFunction( int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[] )
{
    
    char    HW_Version[16];
    char    HW_Serial[8];
    char    Errorstring[40];
    int     i;
    int     serial;
    int     retcode;

    double  *serialFLIm;
    double  *ret;
    
    int     dev[MAXDEVNUM];
    int     found=0;
    
    serialFLIm = mxGetPr(prhs[0]);
    if(nrhs!=1) {
        retcode = -1;
        mexErrMsgIdAndTxt( "MATLAB:PQC_initialize:invalidNumInputs",
                "One input required.");
    }
    
    for(i=0;i<MAXDEVNUM;i++)
    {
        retcode = TH260_OpenDevice(i, HW_Serial);
        if(retcode==0) //Grab any device we can open
        {
            serial = atoi(HW_Serial);
            mexPrintf("Device: %1d, Serial: %7d", i, serial);
             
            if (serial == (int)serialFLIm[0] + 1251999)
            {
                mexPrintf("     Serial No - OK\n");
                    dev[found]=i; //keep index to devices we want to use
                    found++;
            }
            else
            {
                mexPrintf("     Serial No - does not match\n", serial, serialFLIm[0]);
                TH260_CloseDevice(i);
                break;
            }
        }
        else
        {
            if(retcode==TH260_ERROR_DEVICE_OPEN_FAIL)
            {
//                 mexPrintf("\n  %1d        %7s    no device", i, HW_Serial);
            }
            else
            {
                TH260_GetErrorString(Errorstring, retcode);
                mexPrintf("\n  %1d        %7s    %s \n", i, HW_Serial, Errorstring);
            }
        }
    }
    
    

    if (found < 1)
    {
        plhs[0] = mxCreateDoubleMatrix((mwSize)1, (mwSize)1, mxREAL);
        ret = mxGetPr(plhs[0]);
        ret[0] = -1;
    }
    else{
        plhs[0] = mxCreateDoubleMatrix((mwSize)1, (mwSize)found, mxREAL);
        ret = mxGetPr(plhs[0]); 
         for(i=0;i<found;i++)
            ret[i] = (double)dev[i];
    }
}