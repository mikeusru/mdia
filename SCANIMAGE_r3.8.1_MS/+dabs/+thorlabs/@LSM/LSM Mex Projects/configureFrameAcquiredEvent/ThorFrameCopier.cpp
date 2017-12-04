#pragma once

#include "stdafx.h"
#include "ThorFrameCopier.h"
#include <sstream>
#include <process.h>
#include "StateModelObject.h"
#include "FrameQueue.h"
#include "ThorLSM.h"
/* 
Note on startThorAcq.

ThorFrameCopier is in the spirit of FrameActor and as such is a
frame processor, not an acquisition controller. In this light, the
inclusion of fStartAcqEvent and the call to
ThorAPI/StartAcquisition is out of place. The reason
acquisition-starting is included in ThorFrameCopier is that
(apparently) ThorAPI/StartAcquistion is blocking and in practice
can wait a long time eg waiting for an external trigger. In this
situation, it is preferable to have this blocking occur on a thread
that is not the MATLAB exec thread. The TFC processing thread
happens to be around and is a relatively convenient place to wait.
*/

ThorFrameCopier::ThorFrameCopier(void) : 
fProcessing(0),
fFramesSeen(0),
fFramesMissed(0),
fLastFrameTagCopied(0),
fInputBuffer(NULL),
fProcessedDataFilteredInputBuf(NULL),
fOutputDataFilteredInputBuf(NULL),
fFrameTagEnable(true),
fProcessedDataQ(NULL),
fProcessedDataDecimationFactor(1)

{
  fNewFrameEvent = CreateEvent(NULL,FALSE,FALSE,NULL);
  assert(fNewFrameEvent!=NULL);
  fStartAcqEvent = CreateEvent(NULL,FALSE,FALSE,NULL);
  assert(fStartAcqEvent!=NULL);
  fKillEvent = CreateEvent(NULL,FALSE,FALSE,NULL);
  assert(fKillEvent!=NULL);

  InitializeCriticalSection(&fProcessFrameCS);

  fThread = (HANDLE) _beginthreadex(NULL,
    0,
    ThorFrameCopier::threadFcn,
    (LPVOID)this,
    0,
    NULL);
  assert(fThread!=0);
  //if (!SetThreadPriority(fThread,THREAD_PRIORITY_TIME_CRITICAL)) {
  //  CONSOLEPRINT("Failed to boost thread priority of ThorFrameCopier\n");
  //}
  //CONSOLEPRINT("TFC Thread Priority: %d\n",GetThreadPriority(fThread));

  fMATLABCallbackInfo.asyncMex = NULL;
  fMATLABCallbackInfo.scannerID = -1;
  fMATLABCallbackInfo.enable = false;
}

ThorFrameCopier::~ThorFrameCopier(void)
{
  if (fThread!=0) {
    kill();
  }
  CFAEMisc::closeHandleAndSetToNULL(fNewFrameEvent);
  CFAEMisc::closeHandleAndSetToNULL(fStartAcqEvent);
  CFAEMisc::closeHandleAndSetToNULL(fKillEvent);

  DeleteCriticalSection(&fProcessFrameCS);

  // fInputBuffer, fOutputQs, fMATLABCallbackInfo.asyncMex not owned
  // by TFC.
}

HANDLE
ThorFrameCopier::getNewFrameEvent(void) const
{
  return fNewFrameEvent;
}

void
ThorFrameCopier::updateInputBuffers(void *buf, const ImageParameters &ip)                                           
{
  CONSOLETRACE();
  assert(fState==CONSTRUCTED);

  fInputBuffer = static_cast<char*>(buf);
  fImageParams = ip;  

  //Allocate filtered input buffers
  if (fProcessedDataFilteredInputBuf != NULL){  
    delete[] fProcessedDataFilteredInputBuf;
    fProcessedDataFilteredInputBuf = NULL;
  }

  if (fOutputDataFilteredInputBuf != NULL) {
    delete[] fOutputDataFilteredInputBuf;
    fOutputDataFilteredInputBuf = NULL;
  }  

  fProcessedDataFilteredInputBuf = new char[fImageParams.frameSizePerChannel * fImageParams.numProcessedDataChannels + FRAME_TAG_SIZE_BYTES]();
  fOutputDataFilteredInputBuf = new char[fImageParams.frameSizePerChannel * fImageParams.numLoggingChannels + FRAME_TAG_SIZE_BYTES]();
}


void
ThorFrameCopier::configureMATLABCallback(AsyncMex *asyncMex,int scannerID)
{
  assert(fState==CONSTRUCTED);

  assert(asyncMex!=NULL);
  fMATLABCallbackInfo.asyncMex = asyncMex;
  fMATLABCallbackInfo.scannerID = scannerID;
}

void
ThorFrameCopier::setMATLABCallbackEnable(bool enable)
{
  assert(fState==CONSTRUCTED);

  fMATLABCallbackInfo.enable = enable;
}

void
ThorFrameCopier::setProcessedDataDecimationFactor(unsigned int fac)
{
  assert(fState==CONSTRUCTED);

  if (fac==0) {
    fac = 1;
  }
  fProcessedDataDecimationFactor = fac;
}

void
ThorFrameCopier::setOutputQueues(const std::vector<FrameQueue*> &outputQs)
{
  assert(fState==CONSTRUCTED);

  fOutputQs = outputQs;
}

void
ThorFrameCopier::setProcessedDataQueue(FrameQueue *q)
{
  assert(fState==CONSTRUCTED);

  fProcessedDataQ = q;
}


bool
ThorFrameCopier::arm(void)
{
  assert(fState<=ARMED);

  bool tfSuccess = true;

  /// perform verifications, but don't change any state (clear
  /// queues), etc.

  //TODO - put in more array size verifications, taking frameTag into account

  if (fInputBuffer==NULL) { 
    CONSOLETRACE();
    tfSuccess = false; 
  }
  if (fProcessedDataQ==NULL) { 
    CONSOLETRACE();
    tfSuccess = false; 
  }
  //if (fInputImageSize!=fProcessedDataQ->recordSize()) { 
  //  CONSOLETRACE();
  //  tfSuccess = false; 
  //}
  if (fOutputQs.empty()) { 
    CONSOLETRACE();
    tfSuccess = false; 
  }
  //std::size_t numQs = fOutputQs.size();
  //for (std::size_t i=0;i<numQs;i++) {
  //  if (fInputImageSize!=fOutputQs[i]->recordSize()) { 
  //    CONSOLETRACE();
  //    tfSuccess = false; 
  //  }
  //}

  if (fMATLABCallbackInfo.asyncMex==NULL) {
    CONSOLETRACE();
    tfSuccess = false; 
  }
  if (fMATLABCallbackInfo.scannerID<0) { 
    CONSOLETRACE();
    tfSuccess = false; 
  }
  assert(fThread!=0);
  assert(fProcessing==0);

  if (tfSuccess) {
    fState = ARMED;
  }

  return tfSuccess;
}

void 
ThorFrameCopier::disarm(void)
{
  assert(fState==ARMED || fState==STOPPED);
  assert(fThread!=0);
  assert(fProcessing==0);

  fState = CONSTRUCTED;
}

void
ThorFrameCopier::startThorAcq(void)
{
  SetEvent(fStartAcqEvent);
}

void
ThorFrameCopier::startProcessing(const std::vector<int> &outputQsEnabled)
{
  assert(fState==ARMED || fState==STOPPED);

  fOutputQsEnabled = outputQsEnabled; 

  // If processed data or output Q is not empty, that is unexpected. Throw up a MsgBox.
  if (!fProcessedDataQ->isEmpty()) {
    char str[256];
    sprintf_s(str,256,"ThorFrameCopier: Processed data queue has size %d!\n",fProcessedDataQ->size());
    MessageBox(NULL,str,"Warning",MB_OK);
  }
  std::size_t numQs = fOutputQs.size();
  for (std::size_t i=0;i<numQs;i++) {
    FrameQueue *queue = fOutputQs[i];
    if (!queue->isEmpty()) {
      char str[256];
      sprintf_s(str,256,"ThorFrameCopier: Output queue idx %d not empty, has size %d!\n",
        i,queue->size());
      MessageBox(NULL,str,"Warning",MB_OK);
    }
  }

  ResetEvent(fStartAcqEvent);
  ResetEvent(fNewFrameEvent);
  ResetEvent(fKillEvent);

  safeStartProcessing();

  fState = RUNNING;
}

void
ThorFrameCopier::stopProcessing(void)
{
  assert(fState==RUNNING || fState==STOPPED || fState==PAUSED);

  safeStopProcessing();

  fState = STOPPED;
}

bool
ThorFrameCopier::isProcessing(void) const
{
  return fProcessing!=0;
}

void
ThorFrameCopier::pauseProcessing(void)
{
  assert(fState==RUNNING || fState==PAUSED);

  safeStopProcessing();

  fState = PAUSED;
}

void
ThorFrameCopier::resumeProcessing(void)
{
  assert(fState==PAUSED);

  safeStartProcessing();

  fState = RUNNING;
}

unsigned int
ThorFrameCopier::getFramesSeen(void) const
{
  return fFramesSeen;  
}

unsigned int
ThorFrameCopier::getFramesMissed(void) const
{
  return fFramesMissed;  
}


void
ThorFrameCopier::kill(void)
{  
  SetEvent(fKillEvent); // nonblocking termination of processing thread
  CloseHandle(fThread); // Does not forcibly terminate thread, only
  // releases handle. Thread will terminate
  // when threadFcn exits.
  fThread = 0;
  fState = KILLED;
}

void
ThorFrameCopier::debugString(std::string &s) const
{
  std::ostringstream oss;
  oss << "--ThorFrameCopier--" << std::endl;
  oss << "State Processing FramesSeen FramesMissed: " 
    << fState << " " << fProcessing << " " << fFramesSeen << " " 
    << fFramesMissed << std::endl;
  oss << "MLCBI.scannerID MLCBI.enable ProcessedDataDecimationFactor: "
    << fMATLABCallbackInfo.scannerID <<  " "
    << fMATLABCallbackInfo.enable << " " 
    << fProcessedDataDecimationFactor << std::endl;
  s.append(oss.str());
}

void
ThorFrameCopier::safeStartProcessing(void)
{
  EnterCriticalSection(&fProcessFrameCS); 
  fFramesSeen = 0;
  fFramesMissed = 0;
  fLastFrameTagCopied = -1;
  fProcessing = 1;
  LeaveCriticalSection(&fProcessFrameCS);
}

void
ThorFrameCopier::safeStopProcessing(void)
{
  EnterCriticalSection(&fProcessFrameCS); 
  fProcessing = 0;
  LeaveCriticalSection(&fProcessFrameCS);
}

// Threading impl notes.  
//
// Some TFC state accessed by the processing thread cannot change
// while threadFcn (or downstream calls) accesses it, due to
// constraints provided by the state model. Examples are fInputBuffer, fOutputQs.
// 
// The only TFC state that is truly shared by the processing thread
// and controller thread are the Events, fProcessing, fFramesSeen,
// fFramesMissed. These are protected with fProcessFrameCS.
//
// At the moment, no state changes (changes to fState) can originate
// in the processing thread (within threadFcn). For example, if
// something bad happens, the processing thread cannot call
// obj->stopProcessing() to put obj's state into STOPPED. The reason
// is that stopProcessing() and other state-change methods are not
// thread-safe with respect to each other, as explained in header.
//
// If in the future there is the need to enable this sort of state
// change, all state-change methods (ALL interactions involving
// potential modification to fState) will need to be protected with
// critical_sections or the like.

unsigned int 
WINAPI ThorFrameCopier::threadFcn(LPVOID userData)
{
#ifdef CONSOLEDEBUG
  ThorMexDebugger::getInstance()->setConsoleAttribsForThread(FOREGROUND_GREEN|FOREGROUND_INTENSITY);
#endif
  CONSOLETRACE();

  ThorFrameCopier *obj = static_cast<ThorFrameCopier*>(userData);

  HANDLE evtArray[3];
  evtArray[0] = obj->fKillEvent;
  evtArray[1] = obj->fStartAcqEvent;
  evtArray[2] = obj->fNewFrameEvent;

  while (1) {

    DWORD response = WaitForMultipleObjects(3,evtArray,FALSE,ThorFrameCopier::THREADFCN_WAIT_TIMEOUT);    		

    switch (response) {

    case WAIT_OBJECT_0: // kill evt
      return 0; // normal exit

    case WAIT_OBJECT_0+1: // start acq evt
      {
        CONSOLETRACE();
        // This can block until acquisition starts, or timeout occurs
        // waiting for external trigger. See note at top of file.
        long status = StartAcquisition(obj->fInputBuffer); 
        if (status==0) {
          // Thor start failed. We report the error, but we do not
          // change obj->fState (currently there is no safe way of
          // doing so within this thread).
          reportThorError();
        }
      }
      break;

    case WAIT_OBJECT_0+2: // new frame evt
      CONSOLETRACE();

      EnterCriticalSection(&obj->fProcessFrameCS);
      if (obj->fProcessing!=0) {

        bool tfErr;

        if (obj->fFrameTagEnable == true)
          tfErr = obj->processAvailableTaggedFramesCaveman();
        else
          tfErr = obj->processAvailableUntaggedFrames();

        if (tfErr) {
          // We report the error, but we do not change obj->fState
          // (currently there is no safe way of doing so within this
          // thread).
          reportThorError();
        }
      }
      LeaveCriticalSection(&obj->fProcessFrameCS);
      break;

    case WAIT_TIMEOUT:
      // none
      break;

    case WAIT_ABANDONED_0:
    case WAIT_ABANDONED_0+1:
    case WAIT_FAILED:
    default:
      MessageBoxW(NULL,L"ThorFrameCopier: Wait abandoned or failed in threadFcn.",NULL,MB_OK);
      // This is a fatal error that is going to hose the app. Since we
      // are exiting the threadFcn, the state of obj (the TFC) is
      // hosed-- fState will not be consistent with fThread, etc. We
      // could try to modify fState here, but that is not a safe
      // operation without protecting a bunch of other places (eg
      // control/configuration calls) where fState is modified.
      //
      // Hopefully this doesn't ever occur, but if it does it should
      // be clearly diagnosable given the MessageBox.
      return 1; // abnormal exit
    }

    //Sleep(0); //VVV: Not clear whether this may be beneficial (or harmful).
  }


}


// Note1: The call to this helper method from threadFcn is
// protected by fProcessFrameCS.
// Note2: If the processing thread is executing within
// processAvailableFrames, then the TFC must have fState==RUNNING.
bool
ThorFrameCopier::processAvailableTaggedFrames(void)
{
  while (true) {
    long statusRet = -13;
    long status = -13;
    long indexOfLastCompletedFrame = -13;

    statusRet = StatusAcquisitionEx(status,indexOfLastCompletedFrame);    

    if (statusRet==0 || status==STATUS_ERROR) {
      return true;

    } else if (status==STATUS_BUSY) {
      // No (more) frames available; all available frames processed successfully.
      return false;

    } else { // STATUS_READY
      // 1+ frames available to be processed.

      long statusRet = CopyAcquisition(fInputBuffer);
      if (statusRet==0) {
        return true;
      }

      long *frameTagPtr =  reinterpret_cast<long*>(fInputBuffer + fImageParams.frameSize);
      long frameTag = *frameTagPtr;

      if (frameTag<fLastFrameTagCopied) {
        assert(false);
        break;
      } else if (frameTag==fLastFrameTagCopied) {
        CONSOLETRACE();
        break;
      } else {
        long deltaTag = frameTag - fLastFrameTagCopied;
        fFramesSeen += deltaTag;
        fFramesMissed += deltaTag-1;

        CONSOLEPRINT("IKE: %d\n", frameTag);
        if (deltaTag > 1) {
          CONSOLEPRINT("ThorFrameCopier: WARNING - Dropped frames! Frame tag jumped by %d frames. Total missed frame tags: %d!!\n",deltaTag,fFramesMissed);
        }

        fLastFrameTagCopied = frameTag;

        char *inputBufTmp = NULL;
        ImageParameters *ip = &fImageParams;

        // Push to processed data Q; signal MATLAB callback
        // XXX UPDATE THIS LOGIC, fFRAMESSEEN MIGHT JUMP AROUND
        if (fFramesSeen % fProcessedDataDecimationFactor==0) {        
          inputBufTmp = filterInputBufferChannels(fProcessedDataFilteredInputBuf,
            ip->processedDataChanVec,ip->numProcessedDataChannels,
            ip->processedDataContiguousChans, ip->processedDataFirstChan,frameTag);

          bool tfSuccess = fProcessedDataQ->push_back(inputBufTmp);
          if (tfSuccess && fMATLABCallbackInfo.enable) {
            AsyncMex_postEventMessage(fMATLABCallbackInfo.asyncMex,fMATLABCallbackInfo.scannerID);
          }
        }

        // Push onto remaining output Qs (VVV: only the logging Q supported at this time)
        if (!ip->singleChanVec || inputBufTmp == NULL) { //Can reuse processed-data filtered input buffer, if channel specs are the same          
          inputBufTmp = filterInputBufferChannels(fOutputDataFilteredInputBuf,
            ip->loggingChanVec,ip->numLoggingChannels,
            ip->loggingContiguousChans,ip->loggingFirstChan,frameTag);
        }

        std::size_t NQ = fOutputQs.size();
        for (std::size_t i=0;i<NQ;++i) {
          FrameQueue *fq = fOutputQs[i];
          fq->push_back(inputBufTmp);
        }
      }
    }
  }

  return false;
}



// Note1: The call to this helper method from threadFcn is
// protected by fProcessFrameCS.
// Note2: If the processing thread is executing within
// processAvailableFrames, then the TFC must have fState==RUNNING.
bool
ThorFrameCopier::processAvailableTaggedFramesCaveman(void)
{
  while (true) {

    // first time through, new acq
    //if (fLastFrameTagCopied==-1) {
    //  long status = -13;
    //  long indexOfLastCompletedFrame = -13;      
    //  long statusRet = StatusAcquisitionEx(status,indexOfLastCompletedFrame);    

    //  if (statusRet==0 || status==STATUS_ERROR) {
    //    CONSOLETRACE();
    //    return true;
    //  } else if (status==STATUS_BUSY) {
    //    // none
    //    // CONSOLEPRINT("IKE: iolcf %d\n",indexOfLastCompletedFrame);
    //    // return false;
    //  }
    //}

    long status = CopyAcquisition(fInputBuffer);
    //CONSOLEPRINT("CopyAcquisition at %d ms\n",GetTickCount());
    long *frameTagPtr =  reinterpret_cast<long*>(fInputBuffer + fImageParams.frameSize);
    long frameTag = *frameTagPtr;

    if (frameTag<fLastFrameTagCopied) {
      CONSOLEPRINT("frameTag: %d lastFrameTagCopied:%d\n",frameTag,fLastFrameTagCopied);
      assert(false);
      break;
    } else if (frameTag==fLastFrameTagCopied) {
      CONSOLEPRINT("Same frame tag as lastFrameTagCopied: %d %d\n",frameTag,fLastFrameTagCopied);
      break;
    } else {
      long deltaTag = frameTag - fLastFrameTagCopied;
      fFramesSeen += deltaTag;
      fFramesMissed += deltaTag-1;

      CONSOLEPRINT("IKE: %d\n", frameTag);
      if (deltaTag > 1) {
        CONSOLEPRINT("ThorFrameCopier: WARNING - Dropped frames! Frame tag jumped by %d frames. Total missed frame tags: %d!!\n",deltaTag,fFramesMissed);
      }

      fLastFrameTagCopied = frameTag;

      char *inputBufTmp = NULL;
      ImageParameters *ip = &fImageParams;

	  //Apply offset subtraction, if specified
	

      // Push to processed data Q; signal MATLAB callback
      // XXX UPDATE THIS LOGIC, fFRAMESSEEN MIGHT JUMP AROUND
      if ((fFramesSeen % fProcessedDataDecimationFactor == 0) && ip->numProcessedDataChannels > 0) {        
        inputBufTmp = filterInputBufferChannels(fProcessedDataFilteredInputBuf,
          ip->processedDataChanVec,ip->numProcessedDataChannels,
          ip->processedDataContiguousChans, ip->processedDataFirstChan,frameTag);

		if (ip->subtractOffsetEnable) {
		  subtractInputOffsets(inputBufTmp,ip->processedDataChanVec);
		}	

        bool tfSuccess = fProcessedDataQ->push_back(inputBufTmp);
        if (tfSuccess && fMATLABCallbackInfo.enable) {
          AsyncMex_postEventMessage(fMATLABCallbackInfo.asyncMex,fMATLABCallbackInfo.scannerID);
        }
      }

      // Push onto remaining output Qs (VVV: Only 1 output Q, for logging, is supported at this time)

      std::size_t NQ = fOutputQs.size();

      for (std::size_t i=0;i<NQ;++i) {

        if (fOutputQsEnabled[i]) {

          //Extract logging channels (TODO: Generalize/vectorize this operation to apply for possible other output Qs)

          if (!ip->singleChanVec || inputBufTmp == NULL) { //Can reuse processed-data filtered input buffer, if channel specs are the same          
            inputBufTmp = filterInputBufferChannels(fOutputDataFilteredInputBuf,
              ip->loggingChanVec,ip->numLoggingChannels,
			  ip->loggingContiguousChans,ip->loggingFirstChan,frameTag);

			if (ip->subtractOffsetEnable) {
				subtractInputOffsets(inputBufTmp,ip->loggingChanVec);
			}	
          }

          FrameQueue *fq = fOutputQs[i];
          fq->push_back(inputBufTmp);
        }
      }
    }
  }

  return false;
}

//Subtracts input offset values from channels specified in chanActiveVec, if fImageParams.subtractOffsetEnable=true
//Note that any channels for which offset subtraction is individually disabled, the fImageParams.channelsOffsets value is 0.
void 
ThorFrameCopier::subtractInputOffsets(char *filteredInputBuf, std::vector<int> &chanActiveVec)
{
	CONSOLETRACE();
	int bytesPerPixel = fImageParams.bytesPerPixel;
	int channelSize = fImageParams.frameSizePerChannel; //size in bytes
	bool signedData = fImageParams.signedData;

	assert(bytePerPixel == 2);
	int channelSizeShort = channelSize / bytesPerPixel; //size in shorts (unsigned or not)

	short *inputBufShort;
	unsigned short *inputBufUShort;
		
	if (signedData) {
		inputBufShort = reinterpret_cast<short*> (filteredInputBuf);
	} else {
		inputBufUShort = reinterpret_cast<unsigned short*> (filteredInputBuf);
	}

	//Do the offset subtraction
	int activeChanCount = -1;
	for (int i=0; i<fImageParams.numChannelsAvailable;++i) {
		int channelOffsetVal = fImageParams.channelOffsets[i];

		if (chanActiveVec[i] > 0) {
			activeChanCount += 1;
		} else {
			continue;
		}

		if (fImageParams.subtractOffsetEnable > 0 && channelOffsetVal != 0) {
			CONSOLEPRINT("Subtracting offset from channel %d\n",i+1);
			for (int j=0; j<(channelSizeShort);++j) {
				int idx = channelSizeShort*activeChanCount + j;
				if (signedData) {
					*(inputBufShort + idx) = *(inputBufShort + idx) - static_cast<short>(channelOffsetVal); 
				} else {
					*(inputBufUShort + idx) = *(inputBufUShort + idx) - static_cast<unsigned short>(channelOffsetVal); 
				}


				//if (signedData) {
				//} else {
				//	*(inputBufUShort + idx) = *(inputBufUShort + idx) - dynamic_cast<channelOffsets[i];
				//}
			}
		}
	}		

}

char *
ThorFrameCopier::filterInputBufferChannels(char *filteredInputBuffer, std::vector<int> &chanVec, 
                                           int numChans, bool contiguousChans, int firstChan, long frameTag)
{ 
  //filteredInputBuffer should be pre-allocated to correct size

  CONSOLETRACE();

  //If selected channels match the number of channels in source input buffer, just use it directly 
  if (numChans == fImageParams.frameNumChannels) {
    return fInputBuffer; 
  }

  int channelSize = fImageParams.frameSizePerChannel; //size in bytes

  //Copy data from input buffer to 'filtered' input buffer
  if (contiguousChans) { 
    //Single copy in case of contiguous channels
    memcpy(filteredInputBuffer,fInputBuffer + firstChan*channelSize,numChans*channelSize);
  } else {
    //Copy channel contents one-at-a-time if channels are not contiguous
    int chanCount = 0;
    for (int i=0;i<fImageParams.numChannelsAvailable;++i)  {    
      if (chanVec[i] > 0) {
        memcpy(filteredInputBuffer + chanCount*channelSize, fInputBuffer + i*channelSize, channelSize);    
        chanCount++;
      }
    }
  }

  //Append frame tag to the returned 'filtered' input buffer, if supplied. 
  //In case of contiguous channels -- this may overwrite some data in the input buffer!
  if (frameTag != -1) { 
    long *frameTagPtr = reinterpret_cast<long *>(filteredInputBuffer + numChans*channelSize);
    *frameTagPtr = frameTag;
  }

  return filteredInputBuffer;
}





//     //For some reason, indexOfLastCompletedFrame starts at -1 -- it's more like indexOfLastCopiedFrame??
//     long statusRet = StatusAcquisitionEx(status,indexOfLastCompletedFrame); 

//     CONSOLEPRINT("IKE: status iolcf %d %d \n",status,indexOfLastCompletedFrame);

//     //_cprintf("StatusAE. status %d frameCount iolcf %d %d\n",status,scData->frameCount,indexOfLastCompletedFrame);

//     if (statusRet==0 || status==STATUS_ERROR) {
//       return true; //error
//     }

//     if (status == STATUS_BUSY) {
//       return false; // can't copy now
//     }

//     if (indexOfLastCompletedFrame == -1) {
//       return false; //don't copy yet
//     }

//     long additionalFramesAvailable = 0;
//     statusRet = CopyAcquisitionEx(fInputBuffer,additionalFramesAvailable); //Call will wait for status to be 'ready', if it's currently 'busy'
//     if (statusRet==0) {
//       return true; //error
//     }

//     long *frameTagPtr =  reinterpret_cast<long*>(fInputBuffer + fInputImageSize); 
//     long frameTag = *frameTagPtr + 1;

//     CONSOLEPRINT("IKE: ft afa: %d %d\n",frameTag-1,additionalFramesAvailable);

//     //Checks for redundant copies -- don't count these as new frames, don't copy to output Qs, etc
//     if (frameTag <= fLastFrameTagCopied) { 
//       CONSOLEPRINT("ThorFrameCopier: WARNING - Copied same or earlier frame!");	
//     } else {
//       fFramesSeen++;
//       numFramesCopied++;

//       if (numFramesCopied > 1) {
//         CONSOLEPRINT("Catching up! Copy #%d of unique frame on single frame acquired event\n", numFramesCopied);
//       }   



//       fLastFrameTagCopied = frameTag;    

//       // Push to processed data Q; signal MATLAB callback
//       if (fFramesSeen % fProcessedDataDecimationFactor==0) {
//         bool tfSuccess = fProcessedDataQ->push_back(fInputBuffer);
//         if (tfSuccess && fMATLABCallbackInfo.enable) {
//           AsyncMex_postEventMessage(fMATLABCallbackInfo.asyncMex,fMATLABCallbackInfo.scannerID);
//         }
//       }

//       // Push onto remaining output Qs
//       std::size_t NQ = fOutputQs.size();
//       for (std::size_t i=0;i<NQ;++i) {
//         FrameQueue *fq = fOutputQs[i];
//         fq->push_back(fInputBuffer);
//       }
//     }

//     //Break from loop if no further frames are available
//     if (additionalFramesAvailable == 0) {
//       CONSOLEPRINT("Done copying for this event!\n");
//       break;     
//     }
//   }

//   return false; //success
// }

// Note1: The call to this helper method from threadFcn is
// protected by fProcessFrameCS.
// Note2: If the processing thread is executing within
// processAvailableFrames, then the TFC must have fState==RUNNING.
bool
ThorFrameCopier::processAvailableUntaggedFrames(void)
{
  while (true) {
    long statusRet = -13;
    long status = -13;
    long indexOfLastCompletedFrame = -13;

    statusRet = StatusAcquisitionEx(status,indexOfLastCompletedFrame);    

    if (statusRet==0 || status==STATUS_ERROR) {
      return true;

    } else if (status==STATUS_BUSY) {
      // No (more) frames available; all available frames processed successfully.
      return false;

    } else { // STATUS_READY
      // 1+ frames available to be processed.

      long statusRet = CopyAcquisition(fInputBuffer);
      if (statusRet==0) {
        return true;
      }

      // update counters
      fFramesSeen++;
      if (indexOfLastCompletedFrame >= 0) {
        if (indexOfLastCompletedFrame+1 > fFramesSeen) {
          CONSOLEPRINT("ThorFrameCopier: Dropped frame on frame count %d, Thorlabs idx %d.\n",
            fFramesSeen,indexOfLastCompletedFrame);

          unsigned long missingFrameCount = indexOfLastCompletedFrame + 1 - fFramesSeen; 
          fFramesSeen += missingFrameCount;
          fFramesMissed += missingFrameCount;
        }
      }

      // Processed data Q and MATLAB callback
      if (fFramesSeen % fProcessedDataDecimationFactor==0) {
        bool tfSuccess = fProcessedDataQ->push_back(fInputBuffer);
        if (tfSuccess && fMATLABCallbackInfo.enable) {
          AsyncMex_postEventMessage(fMATLABCallbackInfo.asyncMex,fMATLABCallbackInfo.scannerID);
        }
      }

      // Push onto output Qs
      std::size_t NQ = fOutputQs.size();
      for (std::size_t i=0;i<NQ;++i) {
        FrameQueue *fq = fOutputQs[i];
        fq->push_back(fInputBuffer);
      }
    }
  }
}

void 
ThorFrameCopier::reportThorError(void)
{
  wchar_t errmsg[256];
  GetLastErrorMsg(errmsg,256);
  std::wstring msgboxstr(L"ThorFrameCopier fatal Thor err: ");
  msgboxstr += errmsg;
  MessageBoxW(NULL,msgboxstr.c_str(),NULL,MB_OK);
}
