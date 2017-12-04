// [ret, data] = PQC_readBuffer(device)
// data = data stored in buffer.


#include <stdint.h>
#include "mex.h"
#include "th260defin.h"
#include "th260lib.h"
#include "errorcodes.h"







void mexFunction( int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[] )
{
    
    
    char    Errorstring[100];
    int     flags, nRecords, retcode;
    int     ctcstatus;
    int     i;
    mwSize  ndim;
    mwSize  dims[2];
    double  *dev, *ret;
    uint32_t buffer[TTREADMAX];
    uint32_t *buf;
    
    /* Check for proper number of arguments. */
    if(nrhs!=1) {
        mexErrMsgIdAndTxt( "MATLAB:PQC_readBuffer:invalidNumInputs",
                "1 input required.");
    } else if(nlhs>2) {
        mexErrMsgIdAndTxt( "MATLAB:PQC_readBuffer:maxlhs",
                "Too many output arguments.");
    }
    
    dev = mxGetPr(prhs[0]);
    //printf("Measurement start!\n");
    retcode = TH260_GetFlags(dev[0], &flags);
    if(retcode<0)
    {
        TH260_GetErrorString(Errorstring, retcode);
        printf("\nTH260_GetFlags error %d (%s). \n",retcode,Errorstring);
    }
    
    if (flags&FLAG_FIFOFULL)
    {
//         printf("\nFiFo Overrun!\n");
    }
    
    retcode = TH260_ReadFiFo(dev[0],buffer,TTREADMAX,&nRecords);	//may return less!
    if(retcode<0)
    {
        TH260_GetErrorString(Errorstring, retcode);
//         printf("\nTH260_ReadFiFo error %d (%s). \n",retcode,Errorstring);
    }
    
    if(nRecords > 0)
    { 
        ndim = 2;
        dims[0] = 1;
        dims[1] = nRecords;
        plhs[1] = mxCreateNumericArray(ndim, dims, mxUINT32_CLASS,  mxREAL);
        buf = mxGetData(plhs[1]);
        for (i=0; i<nRecords; i++)
            buf[i] = buffer[i];
//         memcpy(buf,buffer,sizeof(uint32_t)*nRecords);
        
//        plhs[1] = mxCreateDoubleMatrix((mwSize)nRecords, (mwSize)1, mxREAL);        
//         ret = mxGetPr(plhs[1]);
//         for (i=0; i<nRecords; i++)
//             ret[i] = (double) buffer[i];
    }
    else
    {
        retcode = TH260_CTCStatus(dev[0], &ctcstatus);
        if(retcode<0)
        {
            TH260_GetErrorString(Errorstring, retcode);
//             printf("\nTH260_CTCStatus error %d (%s). \n",retcode,Errorstring);
        }
        if (ctcstatus)
        {
            //printf("\nDone\n");
            retcode = -2;
        }
        

        plhs[1] = mxCreateDoubleMatrix((mwSize)1, (mwSize)1, mxREAL);
        ret = mxGetPr(plhs[1]);

    }
    
    plhs[0] = mxCreateDoubleMatrix((mwSize)1, (mwSize)1, mxREAL);
    ret = mxGetPr(plhs[0]);
    ret[0] = (double)retcode;
    
    
    //within this loop you can also read the count rates if needed.
}