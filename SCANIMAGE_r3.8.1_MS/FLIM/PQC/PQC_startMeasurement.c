// ret = PQC_startMeasurement(device, Tacq);
// device = deviceID obtained with PQC_openDevice
// Tacq: length in ms.
// ret: error
//

#include "mex.h"
#include "th260defin.h"
#include "th260lib.h"
#include "errorcodes.h"


void mexFunction( int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[] )
{
    

    char    Errorstring[100];
    int     i, mrows, ncols;
    int     retcode;
    double  *dev, *Tacq;
    double  *ret;
    
    
    /* Check for proper number of arguments. */
    if(nrhs!=2) {
        mexErrMsgIdAndTxt( "MATLAB:PQC_startMeasurement:invalidNumInputs",
                "Two input required.");
    } else if(nlhs>1) {
        mexErrMsgIdAndTxt( "MATLAB:PQC_startMeasurement:maxlhs",
                "Too many output arguments.");
    }
    
    /* The input must be a noncomplex scalar double.*/
    for (i=0;i<nrhs;i++)
    {
        mrows = mxGetM(prhs[i]);
        ncols = mxGetN(prhs[i]);
        if( !mxIsDouble(prhs[i]) || mxIsComplex(prhs[i]) ||
                !(mrows==1 && ncols==1) ) {
            mexErrMsgIdAndTxt( "MATLAB:PQC_startMeasurement:inputNotRealScalarDouble",
                    "Input must be a noncomplex scalar double.");
        }
    }
  
    dev = mxGetPr(prhs[0]);
    Tacq = mxGetPr(prhs[1]);   
    
    retcode = TH260_StartMeas((int)dev[0],(int)Tacq[0]);
    if(retcode<0)
    {
        TH260_GetErrorString(Errorstring, retcode);
        printf("\nTH260_StartMeas error %d (%s). \n",retcode,Errorstring);
    }

    plhs[0] = mxCreateDoubleMatrix((mwSize)1, (mwSize)1, mxREAL);
    ret = mxGetPr(plhs[0]); 
    ret[0] = (double)retcode;


}