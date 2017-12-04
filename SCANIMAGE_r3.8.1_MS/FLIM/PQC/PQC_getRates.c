//[ret, sync_rate, count_rate] = PQC_getRates(device);
// device = deviceID obtained with PQC_openDevice
//
#include <stdint.h>
#include "mex.h"
#include "th260defin.h"
#include "th260lib.h"
#include "errorcodes.h"


void mexFunction( int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[] )
{
    
    char    Errorstring[100];
    int     NumChannels;
    int     i, mrows, ncols;
    uint32_t    Syncrate=0;
    uint32_t     Countrate=0;
    uint32_t     CountrateCh[MAXDEVNUM];
    int     retcode;
    double     *rate1, *rate2;
    double  *dev, *mode;
    double  *ret;
    
    for (i=0; i<MAXDEVNUM; i++)
        CountrateCh[i] = 0;
    
    /* Check for proper number of arguments. */
    if(nrhs!=1) {
        mexErrMsgIdAndTxt( "MATLAB:PQC_getRates:invalidNumInputs",
                "One input required.");
    } else if(nlhs>3) {
        mexErrMsgIdAndTxt( "MATLAB:PQC_getRates:maxlhs",
                "Too many output arguments.");
    }
    
    /* The input must be a noncomplex scalar double.*/
    for (i=0;i<nrhs;i++)
    {
        mrows = mxGetM(prhs[i]);
        ncols = mxGetN(prhs[i]);
        if( !mxIsDouble(prhs[i]) || mxIsComplex(prhs[i]) ||
                !(mrows==1 && ncols==1) ) {
            mexErrMsgIdAndTxt( "MATLAB:PQC_getRates:inputNotRealScalarDouble",
                    "Input must be a noncomplex scalar double.");
        }
    }
  
    dev = mxGetPr(prhs[0]);
    
    retcode = TH260_GetNumOfInputChannels(dev[0], &NumChannels);
    if(retcode<0)
    {
        TH260_GetErrorString(Errorstring, retcode);
        mexPrintf("\nTH260_GetNumOfInputChannels error %d (%s).\n",retcode,Errorstring);
        goto ex;
    }
    
    retcode = TH260_GetSyncRate(dev[0], &Syncrate);
    if(retcode<0)
    {
        TH260_GetErrorString(Errorstring, retcode);
        mexPrintf("\nTH260_GetSyncRate error%d (%s).\n",retcode,Errorstring);
        Syncrate = 0;
        goto ex;
    }
    else{
        //printf("\nSyncrate=%1d/s", Syncrate);
    }
    
    for(i=0;i<NumChannels;i++) // for all channels
    {
        retcode = TH260_GetCountRate(dev[0],i,&Countrate);
        if(retcode<0)
        {
            TH260_GetErrorString(Errorstring, retcode);
            mexPrintf("\nTH260_GetCountRate error %d (%s).\n",retcode,Errorstring);
            CountrateCh[i] = 0;
            goto ex;
        }
        else
        {
            CountrateCh[i] = Countrate;
            //printf("\nCountrate[%1d]=%1d/s", i, Countrate);
        }
    }

    ex:

    plhs[0] = mxCreateDoubleMatrix((mwSize)1, (mwSize)1, mxREAL);
    plhs[1] = mxCreateDoubleMatrix((mwSize)1, (mwSize)1, mxREAL);
    plhs[2] = mxCreateDoubleMatrix((mwSize)1, (mwSize)NumChannels, mxREAL);
    ret = mxGetPr(plhs[0]);
    rate1 = mxGetPr(plhs[1]); 
    rate2 = mxGetPr(plhs[2]);
    ret[0] = (double)retcode;
    
    if (retcode >= 0)
    {        
        rate1[0] = (double)Syncrate;
        for (i=0; i<NumChannels; i++)
            rate2[i] = (double)CountrateCh[i];
    }
    else
    {
        rate1[0] = 0;
        rate2[0] = 0;
    }
}