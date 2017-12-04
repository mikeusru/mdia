// [ret, correction, nLine, Data] = ...
// PQC_readBuffer_intoFrame(device, correction_parameters, pixelTime, isize, lineID, flag);
//

#include <windows.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <time.h>
#include "mex.h"
#include "th260defin.h"
#include "th260lib.h"
#include "errorcodes.h"

//GLOBALS?
// const int    lineID = 2; //bit


double time_per_unit; // = 12.4612e-9; //seconds.

long long oflcorrection;
long long truensync, truetime, truetime_sync;
int delta_t, chnnl;

int lineCorrection = 0;
int lineID = 2;
long long event_time;
bool photon, marker, line, sync;


void ProcessHHT3(unsigned int TTTRRecord, int HHVersion)
{
    const int T3WRAPAROUND = 1024;
    union {
        DWORD allbits;
        struct  {
            unsigned nsync    :10;  // numer of sync period
            unsigned dtime    :15;    // delay from last sync in units of chosen resolution
            unsigned channel  :6;
            unsigned special  :1;
        } bits;
    } T3Rec;
    
    T3Rec.allbits = TTTRRecord;
    marker = false;
    photon = false;
    line = false;
    if(T3Rec.bits.special==1)
    {
        if(T3Rec.bits.channel==0x3F) //overflow
        {
            //number of overflows is stored in nsync
            if((T3Rec.bits.nsync==0) || (HHVersion==1)) //if it is zero or old version it is an old style single oferflow
            {
                oflcorrection += (unsigned __int64)T3WRAPAROUND;
//         GotOverflow(1); //should never happen with new Firmware!
            }
            else
            {
                oflcorrection += (unsigned __int64)T3WRAPAROUND * T3Rec.bits.nsync;
//         GotOverflow(T3Rec.bits.nsync);
            }
        }
        if((T3Rec.bits.channel>=1)&&(T3Rec.bits.channel<=15)) //markers
        {
            
            
            //the time unit depends on sync period which can be obtained from the file header
            chnnl = T3Rec.bits.channel;
            if ((chnnl >> lineID) & 1)
            {
                line = true;
                oflcorrection = 0;
                lineCorrection = T3Rec.bits.nsync;
                
            }
            else
                line = false;
            
            marker = true;
            truensync = oflcorrection + T3Rec.bits.nsync - lineCorrection;
            
//       GotMarker(truensync, chnnl);
        }
    }
    else //regular input channel
    {
        truensync = oflcorrection + T3Rec.bits.nsync;
        //the nsync time unit depends on sync period which can be obtained from the file header
        //the dtime unit depends on the resolution and can also be obtained from the file header
        chnnl = T3Rec.bits.channel;
        delta_t = T3Rec.bits.dtime;
        photon = true;
//       GotPhoton(truensync, chnnl, delta_t);
    }
}

void ProcessHHT2(unsigned int TTTRRecord, int HHVersion)
{
    const int T2WRAPAROUND_V1 = 33552000;
    const int T2WRAPAROUND_V2 = 33554432;
    union{
        DWORD   allbits;
        struct{ unsigned timetag  :25;
        unsigned channel  :6;
        unsigned special  :1; // or sync, if channel==0
        } bits;
    } T2Rec;
    T2Rec.allbits = TTTRRecord;
    marker = false;
    photon = false;
    line = false;
    sync = false;
    if(T2Rec.bits.special==1)
    {
        if(T2Rec.bits.channel==0x3F) //an overflow record
        {
            if(HHVersion == 1)
            {
                oflcorrection += (unsigned __int64)T2WRAPAROUND_V1;
//                 GotOverflow(1);
            }
            else
            {
                //number of overflows is stored in timetag
                if(T2Rec.bits.timetag==0) //if it is zero it is an old style single overflow
                {
                    oflcorrection += (unsigned __int64)T2WRAPAROUND_V2;  //should never happen with new Firmware!
                }
                else
                {
                    oflcorrection += (unsigned __int64)T2WRAPAROUND_V2 * T2Rec.bits.timetag;
                }
            }
        }
        
        if((T2Rec.bits.channel>=1)&&(T2Rec.bits.channel<=15)) //markers
        {
            
            chnnl = T2Rec.bits.channel;
            
            if ((chnnl >> lineID) & 1)
            {
                line = true;
                oflcorrection = 0;
                lineCorrection = T2Rec.bits.timetag;
            }
            else
                line = false;
            
            marker = true;
            truetime = oflcorrection + T2Rec.bits.timetag - lineCorrection;
            truensync = truetime;
        }
        
        if(T2Rec.bits.channel==0) //sync
        {
            truetime = oflcorrection + T2Rec.bits.timetag - lineCorrection;
            truensync = truetime;
            truetime_sync = truetime;
            sync = true;
        }
    }
    else //regular input channel
    {
        truetime = oflcorrection + T2Rec.bits.timetag - lineCorrection;
        truensync = truetime;
        delta_t = (int)(truetime - truetime_sync);
        chnnl = T2Rec.bits.channel + 1;
        photon = true;
    }
}



void mexFunction( int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[] )
{
    
//     TTREADMAX 131072
    char    Errorstring[40];
    int     flags, nRecords, retcode;
    int     ctcstatus;
    int     acq_mode;
    int     i, j, k, iter;
    int     n_photons = 0;
    int     n_events = 0;
    int     linesum = 0;
    int     n_pixels, n_lines, n_lines_array, save_n_lines, n_dtime;
    int     pixel, pos;
    double  pixel_time, pixel_count;
    int     *frame0, *frame1;
    bool    first_event, last_event, takeFLIM, count_event;
    
    clock_t  tstart, tend, lstart, lend;
    
    mwSize  ndim;
    mwSize  dims[2];
    size_t  mrows, ncols;
    double  *dev, *input1, *input2, *input3, *input4, *input5;
    double *ret, *ret1, *ret2, *ret3;
    uint32_t buffer[TTREADMAX];

    uint32_t *buf;
    
    /* Check for proper number of arguments. */
    if(nrhs!=6) {
        mexErrMsgIdAndTxt( "MATLAB:PQC_readBuffer:invalidNumInputs",
                "Six input required.");
    } else if(nlhs>4) {
        mexErrMsgIdAndTxt( "MATLAB:PQC_readBuffer:maxlhs",
                "Too many output arguments.");
    }
    
    mrows = mxGetM(prhs[1]);
    ncols = mxGetN(prhs[1]);
    if( !mxIsDouble(prhs[1]) || mxIsComplex(prhs[1]) ||
            !(mrows*ncols==2) ) {
        mexErrMsgIdAndTxt( "MATLAB:PQC_getDeviceInfo:inputNotRealScalarDouble",
                "Input 2 must be a noncomplex 1 x 2 double.");
    }
    
    mrows = mxGetM(prhs[3]);
    ncols = mxGetN(prhs[3]);
    if( !mxIsDouble(prhs[3]) || mxIsComplex(prhs[3]) ||
            !(mrows*ncols==3) ) {
        mexErrMsgIdAndTxt( "MATLAB:PQC_getDeviceInfo:inputNotRealScalarDouble",
                "Input 3 must be a noncomplex 1 x 3 double.");
    }

    mrows = mxGetM(prhs[5]);
    ncols = mxGetN(prhs[5]);
    if( !mxIsDouble(prhs[5]) || mxIsComplex(prhs[5]) ||
            !(mrows*ncols==2) ) {
        mexErrMsgIdAndTxt( "MATLAB:PQC_getDeviceInfo:inputNotRealScalarDouble",
                "Input 5 must be a noncomplex 1 x 2 double.");
    }

    dev = mxGetPr(prhs[0]);
    input1 = mxGetPr(prhs[1]);
    input2 = mxGetPr(prhs[2]);
    input3 = mxGetPr(prhs[3]);
    input4 = mxGetPr(prhs[4]);
    input5 = mxGetPr(prhs[5]);
    
    oflcorrection = (long long) input1[0];
    lineCorrection = (int) input1[1];
    
    pixel_time = input2[0];
    pixel_count = pixel_time / time_per_unit;
    n_dtime = (int)input3[0];
    n_pixels = (int) input3[1];
    n_lines = (int) input3[2];
    n_lines_array = n_lines + 1; // Size of the reserved array.

    lineID = (int)input4[0];
    
    if ((int)input5[0] == 1)
    {
        first_event = true;
        last_event = false;
//         mexPrintf("First!\n");
    }
    else if ((int)input5[0] == 2)
    {
        first_event = false;
        last_event = true;
    }
    else
    {
        first_event = false;
        last_event = false;
    }
    
    if ((int)input5[1] == 0)
        takeFLIM = false;
    else
        takeFLIM = true;
    
    if (!takeFLIM)
        n_dtime = 1;   
    
    acq_mode = 3;
    
    if (acq_mode == 3)
        time_per_unit = 1.246117e-08;
    else
        time_per_unit = 2.5e-10;
            
    frame0 = mxCalloc(n_dtime*n_lines_array*n_pixels, sizeof(int));
    frame1 = mxCalloc(n_dtime*n_lines_array*n_pixels, sizeof(int));

    n_photons = 0;
    n_events = 0;

    iter = 0;
    tstart = clock();
    
    while(1)
    {
        retcode = TH260_GetFlags((int)dev[0], &flags);
        if(retcode<0)
        {
            TH260_GetErrorString(Errorstring, retcode);
            printf("\nTH260_GetFlags error %d (%s). \n",retcode,Errorstring);
            goto ex;
        }
        
        if (flags&FLAG_FIFOFULL)
        {
            printf("\nFiFo Overrun!\n");
            retcode = -100;
            goto ex;
        }
        
        retcode = TH260_ReadFiFo((int)dev[0],buffer,TTREADMAX,&nRecords);	//may return less!
        
        if(retcode<0)
        {
            TH260_GetErrorString(Errorstring, retcode);
            printf("\nTH260_ReadFiFo error %d (%s). \n",retcode,Errorstring);
            goto ex;
        }
        
        /////
        
        if(nRecords > 0)
        {
            retcode = 0; 
//             mexPrintf("Repeat %d\n", n_events);
            for (i=0; i<nRecords; i++)
            {
                if (acq_mode == 3)
                    ProcessHHT3(buffer[i], 2);
                else if (acq_mode == 2)
                    ProcessHHT2(buffer[i], 2);
                else
                {
                    retcode = -101;
                    goto ex;
                }   
                
                if (photon && !first_event)
                {
                    pixel = (int)((double)truensync /(double) pixel_count - 0.5);
                    
                    if (takeFLIM)
                        count_event = delta_t < n_dtime;
                    else
                        count_event = true;
                    
                    
                    if (pixel < n_pixels && count_event)
                    {
//                         if (n_events == 0 && pixel < 5)
//                             mexPrintf("Photon %d, %d, %d / %d, %d\n", delta_t, pixel, n_events, n_lines, (int)first_event);
                        
                        n_photons = n_photons + 1;
                        
                        if (takeFLIM)
                            pos = delta_t + n_dtime*(pixel + n_events * n_pixels);
                        else
                            pos = (pixel + n_events * n_pixels);
                        
                        if (chnnl == 0)
                            frame0[pos] = frame0[pos] + 1;
                        else if (chnnl == 1)
                            frame1[pos] = frame1[pos] + 1;
                        else
                            mexPrintf("Unknown channel %d\n", chnnl);
                        
                    }  else if (n_lines > n_events){
//                         mexPrintf("Photon %d, %d, %d / %d\n", delta_t, pixel, n_events, n_lines);
                    }
                }
                else if (line)
                {
                    lstart = clock();
                    if (first_event)
                    {
                        n_events = 0;
                        first_event = false; //Trigger!
//                         mexPrintf("Triggered\n");
                    }
                    else
                    {
                        n_events = n_events + 1;
                        if (n_events >= n_lines_array)
                        {
                            save_n_lines = n_lines_array;
                            n_lines_array = n_lines_array + 10;
                            frame0 = mxRealloc(frame0, n_dtime*n_lines_array*n_pixels*sizeof(int));
                            frame1 = mxRealloc(frame1, n_dtime*n_lines_array*n_pixels*sizeof(int));
//                             mexPrintf("Photon %d, p=%d/%d, l=%d / %d\n", delta_t, pixel, n_pixels, n_events, n_lines_array);
                            for (j = n_dtime*save_n_lines*n_pixels; j < n_dtime*n_lines_array*n_pixels; j++)
                            {
                                frame0[j] = 0;
                                frame1[j] = 0;
                            }
                        }
                                
                    }
                }
//                 else if (photon)
//                     mexPrintf("wasted photon\n");
            }
        }
        else
        {
            retcode = TH260_CTCStatus((int)dev[0], &ctcstatus);
            if(retcode<0)
            {
                TH260_GetErrorString(Errorstring, retcode);
                printf("\nTH260_CTCStatus error %d (%s). \n",retcode,Errorstring);
                goto ex;
            }
            if (ctcstatus)
            {
                goto stoptttr; 
            }
        }
        
        iter = iter + 1;
        tend = clock() - tstart;
        
        if (last_event && n_events == n_lines)
        {
            pixel = (int)((double)truensync /(double) pixel_count - 0.5);
            lend = clock() - lstart;
            if ((pixel > n_pixels) || ((float)lend/CLOCKS_PER_SEC > n_pixels * pixel_time))
            {
//                 mexPrintf("Time: %f, %f\n", n_pixels * pixel_time, (float)lend/CLOCKS_PER_SEC);
                goto stoptttr;
            }
        } else if (n_events >= n_lines)
           goto stoptttr;
                
        if (((float)tend)/CLOCKS_PER_SEC > 1.0)
        {
            mexPrintf("ERROR: Time out: %f, line: %d (/%d)\n", ((float)tend)/CLOCKS_PER_SEC, n_events, n_lines);
            goto stoptttr;
        }
    }
    
    
    stoptttr:
        plhs[0] = mxCreateDoubleMatrix((mwSize)1, (mwSize)1, mxREAL);
        ret = mxGetPr(plhs[0]);
        ret[0] = (double)retcode;
        
        plhs[1] = mxCreateDoubleMatrix((mwSize)1, (mwSize)2, mxREAL);
        ret1 = mxGetPr(plhs[1]);
        ret1[0] = (double)oflcorrection;
        ret1[1] = (double)lineCorrection;
        
        plhs[2] = mxCreateDoubleMatrix((mwSize)1, (mwSize)1, mxREAL);
        ret2 = mxGetPr(plhs[2]);
        ret2[0] = (double)n_events;
        
        plhs[3] = mxCreateDoubleMatrix((mwSize)n_dtime, (mwSize)n_pixels*(n_events+1)*2, mxREAL);
        ret3 = mxGetPr(plhs[3]);
        for (i=0; i<(n_events+1)*n_pixels*n_dtime; i++)
            ret3[i] = (double)frame0[i];
        for (i=0; i<(n_events+1)*n_pixels*n_dtime; i++)
            ret3[i + (n_events+1)*n_pixels*n_dtime] = (double)frame1[i];
        
        mxFree(frame0);
        mxFree(frame1);
        return ;
        
    ex:
        mxFree(frame0);
        mxFree(frame1);
//         if (retcode < 0 || nRecords == 0)
//         {
            plhs[0] = mxCreateDoubleMatrix((mwSize)1, (mwSize)1, mxREAL);
            ret = mxGetPr(plhs[0]);
            ret[0] = (double)retcode;
            plhs[1] = mxCreateDoubleMatrix((mwSize)1, (mwSize)2, mxREAL);
            plhs[2] = mxCreateDoubleMatrix((mwSize)1, (mwSize)1, mxREAL);
            plhs[3] = mxCreateDoubleMatrix((mwSize)1, (mwSize)1, mxREAL);
            for (i=1;i<4;i++){
                ret = mxGetPr(plhs[i]);
                ret[0] = 0; //within this loop you can also read the count rates if needed.
                if (i==1)
                    ret[1] = 0;
            }
//         }
        
        return ;
}