/// PQC_closeDevice(device)
/// device can be matrix like PQC_closeDevice([0,1,2,3,4]);
#include <stdio.h>
#include "mex.h"
#include "th260defin.h"
#include "th260lib.h"
#include "errorcodes.h"


void mexFunction( int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[] )
{
    
    int     i;
    int     retcode;
    int     mrows, ncols;
    double  *ret;
    int     *dev;
    
     if(nrhs!=1) {
        mexErrMsgIdAndTxt( "MATLAB:PQC_closeDevice:invalidNumInputs",
                "Two input required.");
    } else if(nlhs>1) {
        mexErrMsgIdAndTxt( "MATLAB:PQC_initialize:maxlhs",
                "Too many output arguments.");
    }
    
    /* The input must be a noncomplex scalar double.*/
        mrows = mxGetM(prhs[0]);
        ncols = mxGetN(prhs[0]);
        if( !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) ||
                (mrows*ncols>MAXDEVNUM) ) {
            mexPrintf("\nMaximum device: %d\n", MAXDEVNUM);
            mexErrMsgIdAndTxt( "MATLAB:PQC_closeDevice:inputNotRealScalarDouble",
                    "Input must be a noncomplex scalar Martrix with size smaller than Maximum");
        }
    
    dev = mxGetPr(prhs[0]);
    for (i=0; i<mrows*ncols; i++)
        if (dev[i] <= MAXDEVNUM)
            TH260_CloseDevice(dev[i]);
}