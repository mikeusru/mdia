//PQC_initilize(device, mode);
// device = deviceID obtained with PQC_openDevice
// mode = 2 or 3 for TTTR. 3 for 2p.
//

#include "mex.h"
#include "th260defin.h"
#include "th260lib.h"
#include "errorcodes.h"


void mexFunction( int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[] )
{
    
    char    HW_Model[16];
    char    HW_Partno[8];
    char    HW_Version[16];
    char    HW_Serial[8];
    char    Errorstring[40];
    int     i, mrows, ncols;
    int     retcode;
    double  *dev, *mode; //, *serial;
    double  *ret;
    
    
    /* Check for proper number of arguments. */
    if(nrhs!=2) {
        retcode = -1;
        mexErrMsgIdAndTxt( "MATLAB:PQC_initialize:invalidNumInputs",
                "Two input required.");
    } else if(nlhs>1) {
        retcode = -1;
        mexErrMsgIdAndTxt( "MATLAB:PQC_initialize:maxlhs",
                "Too many output arguments.");
    }
    
    /* The input must be a noncomplex scalar double.*/
    for (i=0;i<nrhs;i++)
    {
        mrows = mxGetM(prhs[i]);
        ncols = mxGetN(prhs[i]);
        if( !mxIsDouble(prhs[i]) || mxIsComplex(prhs[i]) ||
                !(mrows==1 && ncols==1) ) {
            retcode = -1;
            mexErrMsgIdAndTxt( "MATLAB:PQC_initialize:inputNotRealScalarDouble",
                    "Input must be a noncomplex scalar double.");
        }
    }
  
    dev = mxGetPr(prhs[0]);
    mode = mxGetPr(prhs[1]); 
    
    retcode = TH260_Initialize((int)dev[0],(int)mode[0]);
    if(retcode<0)
    {
        TH260_GetErrorString(Errorstring, retcode);
        mexPrintf("\nTH260_Initialize error %d (%s). \n",retcode,Errorstring);
    }


    plhs[0] = mxCreateDoubleMatrix((mwSize)1, (mwSize)1, mxREAL);
    ret = mxGetPr(plhs[0]); 
    ret[0] = (double)retcode;


}