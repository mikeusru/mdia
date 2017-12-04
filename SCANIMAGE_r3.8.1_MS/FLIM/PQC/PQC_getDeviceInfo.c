// info = PQC_getDeviceInfo(device, parameters);
// device = deviceID obtained with PQC_openDevice
// info: structure

#include "mex.h"
#include "th260defin.h"
#include "th260lib.h"
#include "errorcodes.h"

#define MAXCHARS 80   /* max length of string contained in each field */

void mexFunction( int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[] )
{
    
    
    char    HW_Model[16];
    char    HW_Partno[8];
    char    HW_Version[16];
    char    HW_Serial[8];
    char    Errorstring[40];
    int     i, j, mrows, ncols;
    int     retcode;
    int     NumChannels;
    int     device;
    double  Resolution;
    double  *dev;
    double  *ret, *vin, *vout;
    
    double  *fin, *fout;
    int     nfields, ifield, jstruct;
    int     n_elements, n_dims;
    mwSize  *dims;
    mwSize  NStructElems;
    char    **fnames;  //pointers to field names.
    //mxArray *fout;
    
    
    /* Check for proper number of arguments. */
    if(nrhs!=2) {
        mexErrMsgIdAndTxt( "MATLAB:PQC_getDeviceInfo:invalidNumInputs",
                "One input required.");
    } else if(nlhs>1) {
        mexErrMsgIdAndTxt( "MATLAB:PQC_getDeviceInfo:maxlhs",
                "Too many output arguments.");
    } else if(!mxIsStruct(prhs[1]))
        mexErrMsgIdAndTxt( "MATLAB:PQC_getDeviceInfo:inputNotStruct",
                "Second input must be a structure.");
    
    /* The input must be a noncomplex scalar double.*/
    mrows = mxGetM(prhs[0]);
    ncols = mxGetN(prhs[0]);
    if( !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) ||
            !(mrows==1 && ncols==1) ) {
        mexErrMsgIdAndTxt( "MATLAB:PQC_getDeviceInfo:inputNotRealScalarDouble",
                "Input must be a noncomplex scalar double.");
    }
    
    /* get input arguments */
    dev = mxGetPr(prhs[0]);
    device = (int)dev[0];
    
    nfields = mxGetNumberOfFields(prhs[1]);
    NStructElems = mxGetNumberOfElements(prhs[1]);
    fnames = mxCalloc(nfields, sizeof(*fnames));
    /* get field name pointers */
    for (ifield=0; ifield< nfields; ifield++)
    {
        fnames[ifield] = mxGetFieldNameByNumber(prhs[1],ifield);
    }

    
    if (retcode>=0)
    {
        retcode = TH260_GetHardwareInfo(device,HW_Model,HW_Partno,HW_Version);
        if(retcode<0)
        {
            TH260_GetErrorString(Errorstring, retcode);
            mexPrintf("\nTH260_GetHardwareInfo error %d (%s). \n",retcode,Errorstring);
        }
//         else
//             mexPrintf("\nFound Model %s Part no %s Version %s",HW_Model, HW_Partno, HW_Version);
    }
    
    if (retcode>=0)
    {
        retcode = TH260_GetNumOfInputChannels(device, &NumChannels);
        if(retcode<0)
        {
            TH260_GetErrorString(Errorstring, retcode);
            mexPrintf("\nTH260_GetNumOfInputChannels error %d (%s).\n",retcode,Errorstring);
        }
//         else
//             mexPrintf("\nDevice has %i input channels.",NumChannels);
    }
    
    if (retcode>=0)
    {
        retcode = TH260_GetResolution(device, &Resolution);
        if(retcode<0)
        {
            TH260_GetErrorString(Errorstring, retcode);
            mexPrintf("\nTH260_GetResolution error %d (%s). \n",retcode,Errorstring);
        }
//         else
//              mexPrintf("\nResolution is %1.0lfps\n", Resolution);
    }
    
    
    if (retcode < 0)
    {
        plhs[0] = mxCreateDoubleMatrix((mwSize)1, (mwSize)1, mxREAL);
        ret = mxGetPr(plhs[0]);
        ret[0] = (double)retcode;
    }
    else
    {
        /* create a 1x1 struct matrix for output  */
        plhs[0] = mxCreateStructMatrix(1, 1, nfields, fnames);
       
        
        for(ifield=0; ifield<nfields; ifield++)
        {
//             mexPrintf("Field %d, %s \n", ifield, fnames[ifield]);
            /* create cell/numeric array */
            if(strcmp(fnames[ifield], "HW_Model") == 0)
                fout = mxCreateString(HW_Model);
            
            else if (strcmp(fnames[ifield], "resolution") == 0)
            {
                fout = mxCreateDoubleMatrix(1,1,mxREAL);
                vout = mxGetPr(fout);
                vout[0] = (double)Resolution;
            }
            else if (strcmp(fnames[ifield], "n_channels") == 0)
            {
                fout = mxCreateDoubleMatrix(1,1,mxREAL);
                vout = mxGetPr(fout);
                vout[0] = (double)NumChannels;
            }
            else
            {
                fin = mxGetFieldByNumber(prhs[1],0, ifield);
                n_elements = mxGetNumberOfElements(fin);
                n_dims = mxGetNumberOfDimensions(fin);
                dims = mxGetDimensions(fin);
//                    mexPrintf("dims: %d,%d\n", n_elements, dims[0]);
                vin = mxGetPr(fin);
                fout = mxCreateDoubleMatrix(n_elements,1,mxREAL);
                vout = mxGetPr(fout);
                for (j = 0; j< n_elements; j++)
                    vout[j] = (double)vin[j];
            }
            
            mxSetFieldByNumber(plhs[0], 0, ifield, fout);
        }
        mxFree((void *)fnames);
    }
}