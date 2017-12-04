// info = PQC_setParameters(device, parameters, showparameters);
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
    
    int     debug = 1;
    
    char    HW_Partno[8];
    char    HW_Version[16];
    char    HW_Serial[8];
    char    Errorstring[100];
    int     i, j, mrows, ncols;
    int     retcode;
    int     device;
    
    double  *dev, *input2;
    double  *ret, *vin, *vout;
    
    double  *fin, *fout;
    int     nfields, ifield, jstruct;
    int     n_elements, n_dims;
    mwSize  *dims;
    mwSize  NStructElems;
    char    **fnames;  //pointers to field names.
    
    //OUTPUT
    int     NumChannels;
    double  Resolution;
    char    HW_Model[16];
    
    //INPUT
    int Binning=0; //you can change this, meaningful only in T3 mode
    int Offset=0;  //you can change this, meaningful only in T3 mode
    int Tacq=10000; //Measurement time in millisec, you can change this
    int SyncDivider = 1; //you can change this, observe Mode! READ MANUAL!
    
    //These settings will apply for TimeHarp 260 P boards
    int SyncCFDZeroCross=0; //you can change this
    int SyncCFDLevel=-50; //you can change this
    int InputCFDZeroCross[2]; //you can change this
    int InputCFDLevel[2]; //you can change this
    
    //These settings will apply for TimeHarp 260 N boards
    int SyncTiggerEdge=1; //you can change this
    int SyncTriggerLevel=-50; //you can change this
    int InputTriggerEdge=1; //you can change this
    int InputTriggerLevel[MAXDEVNUM]; 
    
    int SyncChannelOffset=0;
    int InputChannelOffset[MAXDEVNUM];
    
    InputCFDZeroCross[0] = -5;
    InputCFDZeroCross[1] = -5;
    InputCFDLevel[0] = -50;
    InputCFDLevel[1] = -50;
    InputTriggerLevel[0] = -50;
    InputTriggerLevel[1] = -50;
    InputChannelOffset[0] = 0;
    InputChannelOffset[1] = 0;
    
    /* Check for proper number of arguments. */
    if(nrhs!=3) {
        mexErrMsgIdAndTxt( "MATLAB:PQC_getDeviceInfo:invalidNumInputs",
                "Three inputs required.");
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
    
    input2 = mxGetPr(prhs[2]);
    debug = (int)input2[0];
    
    nfields = mxGetNumberOfFields(prhs[1]);
    NStructElems = mxGetNumberOfElements(prhs[1]);
    fnames = mxCalloc(nfields, sizeof(*fnames));
    /* get field name pointers */
    for (ifield=0; ifield< nfields; ifield++)
    {
        fnames[ifield] = mxGetFieldNameByNumber(prhs[1],ifield);
        
        fin = mxGetFieldByNumber(prhs[1],0, ifield);
        n_elements = mxGetNumberOfElements(fin);
        n_dims = mxGetNumberOfDimensions(fin);
        dims = mxGetDimensions(fin);
        vin = mxGetPr(fin);
        if (n_elements <= MAXDEVNUM)
            ncols = n_elements;
        else
            ncols = MAXDEVNUM;
        
        if (strcmp(fnames[ifield], "binning") == 0)
            Binning = (int) vin[0];
        else if (strcmp(fnames[ifield], "sync_offset") == 0)
            SyncChannelOffset = (int) vin[0];
        else if (strcmp(fnames[ifield], "sync_channel_offset") == 0)
            Offset = (int) vin[0];
        else if (strcmp(fnames[ifield], "sync_freq_div") == 0)
            SyncDivider = (int) vin[0];
        else if (strcmp(fnames[ifield], "sync_trigger_level") == 0)
        {
            SyncTriggerLevel = (int) vin[0];
            SyncCFDLevel = (int) vin[0];
        }
        else if (strcmp(fnames[ifield], "input_trigger_level") == 0)
        {
            for (i=0; i<ncols; i++) {
                InputCFDLevel[i] = (int) vin[i];
                InputTriggerLevel[i] = (int) vin[i];
            }
        }
        else if (strcmp(fnames[ifield], "input_zc_level") == 0)
        {
            for (i=0; i<ncols; i++) {
                InputCFDZeroCross[i] = (int) vin[i];
            }
        }
        else if (strcmp(fnames[ifield], "input_offset") == 0)
        {
            for (i=0; i<ncols; i++) {
                InputChannelOffset[i] = (int) vin[i];
            }
        }
        //for (j = 0; j< n_elements; j++)
        
    }
    

    
//// GET PARAMETERS ///////////////////////////
    if (retcode>=0)
    {
        retcode = TH260_GetHardwareInfo(device,HW_Model,HW_Partno,HW_Version);
        if(retcode<0)
        {
            TH260_GetErrorString(Errorstring, retcode);
            mexPrintf("\nTH260_GetHardwareInfo error %d (%s). \n",retcode,Errorstring);
        }
    }
    
    if (retcode>=0)
    {
        retcode = TH260_GetNumOfInputChannels(device, &NumChannels);
        if(retcode<0)
        {
            TH260_GetErrorString(Errorstring, retcode);
            mexPrintf("\nTH260_GetNumOfInputChannels error %d (%s).\n",retcode,Errorstring);
        }
    }
    
//////////
    if (debug == 1)
    {
        printf("\n\nUsing the following settings:\n");

        printf("Binning           : %ld\n",Binning);
        printf("Offset            : %ld\n",Offset);
        printf("SyncDivider       : %ld\n",SyncDivider);

        if(strcmp(HW_Model,"TimeHarp 260 P")==0)
        {
            printf("SyncCFDZeroCross  : %ld\n",SyncCFDZeroCross);
            printf("SyncCFDLevel      : %ld\n",SyncCFDLevel);
            printf("InputCFDZeroCross-1 : %ld\n",InputCFDZeroCross[0]);
            printf("InputCFDLevel-1     : %ld\n",InputCFDLevel[0]);
            printf("InputCFDZeroCross-2 : %ld\n",InputCFDZeroCross[1]);
            printf("InputCFDLevel-2     : %ld\n",InputCFDLevel[1]);
        }
        else if(strcmp(HW_Model,"TimeHarp 260 N")==0)
        {
            printf("SyncTiggerEdge      : %ld\n",SyncTiggerEdge);
            printf("SyncTriggerLevel    : %ld\n",SyncTriggerLevel);
            printf("InputTriggerEdge    : %ld\n",InputTriggerEdge);
            printf("InputTriggerLevel-1 : %ld\n",InputTriggerLevel[0]);
            printf("InputTriggerLevel-2 : %ld\n",InputTriggerLevel[1]);
        }
        printf ("InputChannelOffset-1 : %ld\n", InputChannelOffset[0]);
        printf ("InputChannelOffset-2 : %ld\n", InputChannelOffset[1]);
        printf ("SyncChannelOffset    : %ld\n", SyncChannelOffset);
    }
    
//// SET PARAMETERS /////////////////////////
    if (retcode>=0)
    {
        retcode = TH260_SetSyncDiv(device,SyncDivider);
        if(retcode<0)
        {
            TH260_GetErrorString(Errorstring, retcode);
            printf("\nTH_SetSyncDiv error %d (%s). .\n",retcode,Errorstring);
            goto ex;
        }
        
        
        if(strcmp(HW_Model,"TimeHarp 260 P")==0)  //Picosecond resolving board
        {
            retcode=TH260_SetSyncCFD(device,SyncCFDLevel,SyncCFDZeroCross);
            if(retcode<0)
            {
                TH260_GetErrorString(Errorstring, retcode);
                printf("\nTH260_SetSyncCFD error %d (%s).\n",retcode,Errorstring);
            }
            
            for(i=0;i<NumChannels;i++) // we use the same input settings for all channels
            {
                retcode=TH260_SetInputCFD(device,i,InputCFDLevel[i],InputCFDZeroCross[i]);
                if(retcode<0)
                {
                    TH260_GetErrorString(Errorstring, retcode);
                    printf("\nTH260_SetInputCFD error %d (%s).\n",retcode,Errorstring);
                    goto ex;
                }
            }
        }
        
        if(strcmp(HW_Model,"TimeHarp 260 N")==0)  //Nanosecond resolving board
        {
            retcode=TH260_SetSyncEdgeTrg(device,SyncTriggerLevel,SyncTiggerEdge);
            if(retcode<0)
            {
                TH260_GetErrorString(Errorstring, retcode);
                printf("\nTH260_SetSyncEdgeTrg error %d (%s).\n",retcode,Errorstring);
                goto ex;
            }
            
            for(i=0;i<NumChannels;i++) // we use the same input settings for all channels
            {
                retcode=TH260_SetInputEdgeTrg(device,i,InputTriggerLevel[i],InputTriggerEdge);
                if(retcode<0)
                {
                    TH260_GetErrorString(Errorstring, retcode);
                    printf("\nTH260_SetInputEdgeTrg error %d (%s).\n",retcode,Errorstring);
                    goto ex;
                }
            }
        }
        
        retcode = TH260_SetSyncChannelOffset(device,SyncChannelOffset);
        if(retcode<0)
        {
            TH260_GetErrorString(Errorstring, retcode);
            printf("\nTH260_SetSyncChannelOffset error %d (%s).\n",retcode,Errorstring);
            goto ex;
        }
        
        for(i=0;i<NumChannels;i++) // we use the same input offset for all channels
        {
            retcode = TH260_SetInputChannelOffset(device,i,InputChannelOffset[i]);
            if(retcode<0)
            {
                TH260_GetErrorString(Errorstring, retcode);
                printf("\nTH260_SetInputChannelOffset error %d (%s).\n",retcode,Errorstring);
                goto ex;
            }
        }
        
        retcode = TH260_SetBinning(device,Binning);
        if(retcode<0)
        {
            TH260_GetErrorString(Errorstring, retcode);
            printf("\nTH260_SetBinning error %d (%s).\n",retcode,Errorstring);
            goto ex;
        }
        
        retcode = TH260_SetOffset(device,Offset);
        if(retcode<0)
        {
            TH260_GetErrorString(Errorstring, retcode);
            printf("\nTH260_SetOffset error %d (%s).\n",retcode,Errorstring);
            goto ex;
        }
    }
    
//// GET RESOLUTION /////////////////////////
    if (retcode>=0)
    {
        retcode = TH260_GetResolution(device, &Resolution);
        if(retcode<0)
        {
            TH260_GetErrorString(Errorstring, retcode);
            mexPrintf("\nTH260_GetResolution error %d (%s). \n",retcode,Errorstring);
        }
        else
            if (debug == 1)
                 mexPrintf("\nResolution is %1.0lfps\n", Resolution);
    }
    
//// OUTPUT /////////////////////////  
    ex:
        
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
                fout = mxCreateDoubleMatrix(1, n_elements,mxREAL);
                vout = mxGetPr(fout);
                for (j = 0; j< n_elements; j++)
                    vout[j] = (double)vin[j];
            }
            
            mxSetFieldByNumber(plhs[0], 0, ifield, fout);
        }
        mxFree((void *)fnames);
    }
}