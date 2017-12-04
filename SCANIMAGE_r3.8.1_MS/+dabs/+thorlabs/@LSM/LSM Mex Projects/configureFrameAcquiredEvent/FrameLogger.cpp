#include "stdafx.h"
#include "FrameLogger.h"
#include <sstream>
#include <process.h>

const char *FrameLogger::FRAME_TAG_FORMAT_STRING = "Frame Tag = %08d\n";

FrameLogger::FrameLogger(void) : 
fThread(0),
fFrameQueue(NULL),
fTifWriter(new TifWriter()),
fAverageFactor(1),
fAveragingBuf(NULL),
fAveragingResultBuf(NULL),
fKillLoggingFlag(false),
fHaltLoggingFlag(false),
fFramesLogged(0),
fFrameTagEnable(false),
fFrameDelay(0)
{
  assert(fTifWriter!=NULL);

  InitializeCriticalSection(&fLogfileRolloverCS);
}

FrameLogger::~FrameLogger(void)
{
  if (fThread!=0) {
    stopLoggingImmediately();
    // Could go stronger and use something like TerminateThread here.
  }

  fFrameQueue = NULL; // FrameQueue not owned by this obj  
  if (fTifWriter!=NULL) {
    delete fTifWriter;
    fTifWriter = NULL;
  }

  deleteAveragingBuffers();

  DeleteCriticalSection(&fLogfileRolloverCS); // no way to check if this has been initted
}

bool
FrameLogger::getFrameTagEnable()
{
  return fFrameTagEnable;
}

void
FrameLogger::setFrameTagProps(bool frameTagEnable,bool frameTagOneBased)
{
  assert(fState<ARMED);
  fFrameTagEnable = frameTagEnable;
  fFrameTagOneBased = frameTagOneBased;
}

void
FrameLogger::setInputQueue(AbstractConsumerQueue *q)
{
  assert(fState<ARMED);

  fFrameQueue = q;
}

void 
FrameLogger::configureImage(const ImageParameters &ip,
                            unsigned int averagingFactor,
                            const char *imageDesc)
{
  CONSOLETRACE();
  assert(fState<ARMED);
  assert(averagingFactor>0);

  fImageParams = ip;
  // ip.numChannelsAvailable, ip.numChannelsActive are not used in FrameLogger.
  assert(!fTifWriter->isTifFileOpen());

  //Handle frame tag case, if applicable -- prepend frame tag, pad image description
  std::string imageDescStr = imageDesc;
  if (fFrameTagEnable) {
    //Prepend frame tag
    char frameTagStr[FRAME_TAG_STRING_LENGTH+1]="0";
    sprintf(frameTagStr,FRAME_TAG_FORMAT_STRING,0); 
    imageDescStr.insert(0,frameTagStr);

    //Pad image description (allows for ease of modifying description contents without recomputing IFDs etc)
    imageDescStr.append(IMAGE_DESC_DEFAULT_PADDING,' ');
  }

  fTifWriter->configureImage(ip.imageWidth,ip.imageHeight,ip.bytesPerPixel,
    ip.numLoggingChannels,ip.signedData,imageDescStr.c_str());
  fConfiguredImageDescLength = imageDescStr.length();

  fAverageFactor = averagingFactor;
  this->deleteAveragingBuffers();

  if (fAverageFactor > 1) {
    //CONSOLEPRINT("fImP.fnp: %d. faB: %p. sizeof fab: %d\n",fImageParams.frameNumPixels,fAveragingBuf,(sizeof fAveragingBuf));
    fAveragingBuf = new double[ip.frameNumPixels * ip.numLoggingChannels]();
    fAveragingResultBuf = new char[ip.frameSizePerChannel * ip.numLoggingChannels](); 
    assert(fAveragingBuf!=NULL);
    assert(fAveragingResultBuf!=NULL);
    zeroAveragingBuffers();
  }


  return;
}

void 
FrameLogger::configureFile(const char *filename, const char *fileModeStr)
{
  CONSOLETRACE();
  assert(fState<ARMED);

  assert(filename!=NULL);
  assert(fileModeStr!=NULL);

  // To configure the file before the acq, we put a single logfileNote
  // in the logfileNotes with frameidx of 1.
  //
  // We treat this call as a reset of the logfilenotes.
  fLogfileNotes.clear();
  LogFileNote lfn(filename,fileModeStr,1);
  fLogfileNotes.push_front(lfn);
}  

// void 
// FrameLogger::setHeaderString(const char *str)
// {
// }

// arm ensures that all configuration-related state is set
// properly. runtime state is not initialized until startLogging().
bool
FrameLogger::arm(void)
{
  // As in ThorFrameCopier, we perform verifications, but do not
  // modify any state here.

  assert(fState==CONSTRUCTED || fState==ARMED);
  assert(fThread==0);

  bool tfSuccess = true;

  if (fFrameQueue==NULL) { tfSuccess = false; }
  if (fTifWriter==NULL) { tfSuccess = false; }
  assert(!fTifWriter->isTifFileOpen());
  if (fFrameQueue->recordSize()!=fImageParams.frameSize) { tfSuccess = false; }
  // assume fImageParams and fTifWriter agree
  if (fAverageFactor>1 && (fAveragingBuf==NULL || fAveragingResultBuf==NULL)) {
    tfSuccess = false;
  }
  if ( !(fLogfileNotes.size()==1 && fLogfileNotes.front().frameIdx==1) ) { 
    // Initial file not configured
    tfSuccess = false; 
  }

  fState = (tfSuccess) ? ARMED : CONSTRUCTED;

  return tfSuccess;  
}

void
FrameLogger::disarm(void)
{
  assert(fState==ARMED || fState==STOPPED);
  assert(fThread==0);
  fState = CONSTRUCTED;
}

void
FrameLogger::startLogging(int frameDelay)
{
  CONSOLETRACE();
  assert(fState==ARMED);
  assert(fThread==0);  

  // pre-start state initializations
  fFrameDelay = frameDelay;
  fKillLoggingFlag = false;
  fHaltLoggingFlag = false;
  fFramesLogged = 0; 

  if (fAverageFactor > 1) {    
    zeroAveragingBuffers();
  }

  // If fFrameQueue is nonempty, that is bizzaro. Throw a msgbox
  if (!fFrameQueue->isEmpty()) {

    // xxx this comes up in testing b/c of the
    // "start-logger-after-acq-started" thing, the messagebox might be
    // modal or something

    CONSOLEPRINT("FrameLogger: Input queue is nonempty, has size %d.\n",
      fFrameQueue->size());

    // char str[256];
    // sprintf_s(str,256,"FrameLogger: Input queue is nonempty, has size %d.\n",
    // 	    fFrameQueue->size());
    // MessageBox(NULL,str,"Warning",MB_OK);
  }

  fThread = (HANDLE)_beginthreadex(NULL,0,FrameLogger::loggingThreadFcn,
    (LPVOID)this,0,NULL);
  assert(fThread!=0);

  fState = RUNNING;
}

bool 
FrameLogger::isLogging(void) const 
{
  return fState==RUNNING;
}

void 
FrameLogger::stopLogging(void) 
{
  CONSOLETRACE();
  assert(fState==RUNNING);
  assert(fThread!=0);

  fHaltLoggingFlag = true; 

  // Stop signal sent. Now wait for logging thread to terminate.

  DWORD retval = WaitForSingleObject(fThread,STOP_LOGGING_TIMEOUT_MILLISECONDS);
  switch (retval) {
  case WAIT_OBJECT_0:
    // logging thread completed.
    {
      BOOL b = CloseHandle(fThread);
      assert(b!=0);
      fThread = 0;
      // other runtime state can remain as-is in STOPPED state. to start,
      // will have to disarm + arm + startLogging.
    }
    fState = STOPPED;
    break;

  case WAIT_TIMEOUT:
  case WAIT_ABANDONED:
  case WAIT_FAILED:
  default:
    // Try harder to stop logging.
    stopLoggingImmediately(); 

    assert(fState==STOPPED || fState==KILLED);

    if (fState==STOPPED) {
      // stopImmediately succeeded, which means everything is okay, but
      // that we didn't finish logging.
      char str[256];
      sprintf_s(str,256,"FrameLogger: Logger could not finish processing. %d frames were unlogged.\n",
        fFrameQueue->size());
      MessageBox(NULL,str,"Warning",MB_OK);
    }

    break;
  }
}


void
FrameLogger::stopLoggingImmediately(void)
{
  CONSOLETRACE();
  assert(fState==RUNNING);
  assert(fThread!=0);

  fKillLoggingFlag = true; 

  DWORD retval = WaitForSingleObject(fThread,
    STOP_LOGGING_TIMEOUT_MILLISECONDS);
  switch (retval) {
  case WAIT_OBJECT_0:
    // logging thread stopped.
    {
      BOOL b = CloseHandle(fThread);
      assert(b!=0);
      fThread = 0;
    }
    fState = STOPPED;
    break;

  case WAIT_TIMEOUT:
  case WAIT_ABANDONED:
  case WAIT_FAILED:
  default:
    // stop immediately failed; we are hosed
    {
      char str[256];
      sprintf_s(str,256,"FrameLogger: Unable to stop logger. Please report this error to the ScanImage team.\n");
      MessageBox(NULL,str,"Error",MB_OK);
    }
    fState = KILLED; // FrameLogger will be unusable in this state
    break;
  }
}

void
FrameLogger::addLogfileRolloverNote(const LogFileNote &lfn)
{
  assert(fState==ARMED || fState==RUNNING || fState == STOPPED);

  EnterCriticalSection(&fLogfileRolloverCS);

  if (!fLogfileNotes.empty()) {
    // enforce strict monotonicity
    assert(fLogfileNotes.back().frameIdx < lfn.frameIdx);
  }
  fLogfileNotes.push_back(lfn);

  LeaveCriticalSection(&fLogfileRolloverCS);
}

unsigned long
FrameLogger::getFramesLogged(void) const
{
  return fFramesLogged;
}

void
FrameLogger::debugString(std::string &s) const
{
  std::ostringstream oss;
  oss << "--FrameLogger--" << std::endl;
  oss << "State Thread TifWriterFileOpen fAvFactor: " 
    << fState << " " << fThread << " " 
    << fTifWriter->isTifFileOpen() << " " 
    << fAverageFactor << std::endl;
  oss << "KillLoggingFlag HaltLoggingFlag FramesLogged: "
    << fKillLoggingFlag << " "
    << fHaltLoggingFlag << " " 
    << fFramesLogged << std::endl;

  s.append(oss.str());  
  fImageParams.debugString(s);

  oss.str("");
  std::size_t numNotes = fLogfileNotes.size();
  for (std::size_t i=0;i<numNotes;i++) {
    oss << "LogfileNote " << i << ": " << "fname modestr frmIdx: " 
      << fLogfileNotes[i].filename << " " 
      << fLogfileNotes[i].modeStr << " " 
      << fLogfileNotes[i].frameIdx << std::endl;
  }
  s.append(oss.str());
}

unsigned int 
WINAPI FrameLogger::loggingThreadFcn(LPVOID userData)
{
  FrameLogger *obj = static_cast<FrameLogger*>(userData);

  while (1) {
    if (obj->fKillLoggingFlag) {
      break;
    }
    if (obj->fHaltLoggingFlag && obj->fFrameQueue->isEmpty()) {
      break;
    }

    /// Roll over file if appropriate
    EnterCriticalSection(&obj->fLogfileRolloverCS);

    if (!obj->fLogfileNotes.empty()) {
      const LogFileNote &lfn = obj->fLogfileNotes.front();
      unsigned long framesLoggedPlus1 = obj->fFramesLogged+1; //fFramesLogged is 0-based
      if (framesLoggedPlus1 > lfn.frameIdx) { 
        // already beyond first logfilenote; ignore
        CONSOLEPRINT("FrameLogger: ignoring log file note (fname frameidx %s %d), already at frameIdx+1==%d.\n",
          lfn.filename.c_str(),lfn.frameIdx,framesLoggedPlus1);
        // TODO do a mexprintf here, maybe redef CONSOLEPRINT macro.
        obj->fLogfileNotes.pop_front();

      } else if (framesLoggedPlus1 == lfn.frameIdx) { 
        CONSOLEPRINT("FrameLogger: rolling over file (fname frameIdx %s %d).\n",
          lfn.filename.c_str(),lfn.frameIdx);
        if (obj->fTifWriter->isTifFileOpen()) {
          obj->fTifWriter->closeTifFile();
        }
        if (!obj->fTifWriter->openTifFile(lfn.filename.c_str(),lfn.modeStr.c_str())) {
          char str[256];
          sprintf_s(str,256,"FrameLogger: Error opening file %s. Aborting logging.\n",
            lfn.filename.c_str());
          MessageBox(NULL,str,"Error",MB_OK);

          // This break will exit loggingThreadFcn. Subsequent calls
          // to stopLogging or stopLoggingImmediately will "succeed".
          break; 
        }        

        //Handle image description update, if supplied
        std::string imd = lfn.imageDesc;       
        if (!imd.empty()) {
          if (obj->fFrameTagEnable) {
            int padLength = obj->fConfiguredImageDescLength - imd.length();
            if (padLength > 0) {
              imd.append(padLength,' ');
            } else if (padLength < 0) { //New header is longer than (previous header + IMAGE_DESC_DEFAULT_PADDING)
              char str[256];
              sprintf_s(str,256,"FrameLogger: Header string modified to length larger than logging stream was configured to handle.");
              MessageBox(NULL,str,"Error",MB_OK);

              // This break will exit loggingThreadFcn. Subsequent calls
              // to stopLogging or stopLoggingImmediately will "succeed".
              break; 
            }
            obj->fTifWriter->modifyImageDescription(FRAME_TAG_STRING_LENGTH,imd.c_str(),obj->fConfiguredImageDescLength+1);
          } else {
            obj->fTifWriter->replaceImageDescription(lfn.imageDesc.c_str());
          }          
        }

        obj->fLogfileNotes.pop_front();

      } else {
        // Haven't reached lfn.frameIdx yet
      }
    }

    LeaveCriticalSection(&obj->fLogfileRolloverCS);

    // Write frame to TIF file
    if (obj->fFrameQueue->size() >= (obj->fFrameDelay + 1) || (obj->fHaltLoggingFlag && !obj->fFrameQueue->isEmpty())) {
      CONSOLETRACE();
      assert(obj->fTifWriter->isTifFileOpen());

      // Three threads access fFrameQueue: this thread (the logging
      // thread), the ThorFrameCopier thread (doing pushes only), and
      // the MATLAB exec thread (acting as the controller). Use
      // front_checkout/checkin to protect against controller eg
      // initting the queue while we read (unlikely but conceivable).

      const void *framePtr = obj->fFrameQueue->front_checkout();
      const char *charFramePtr = static_cast<const char*>(framePtr);

      if (obj->fAverageFactor==1) {
        // no averaging.

        if (obj->fFrameTagEnable) {
          CONSOLETRACE();

          if (!obj->updateFrameTag(charFramePtr)) {
            CONSOLETRACE();

            // This break will exit loggingThreadFcn. Subsequent calls
            // to stopLogging or stopLoggingImmediately will "succeed".
            break; 
          }          
        }
        CONSOLETRACE();


        // If this hangs/throws, front_checkin will never be called
        // and we will lock up.
        obj->fTifWriter->writeFramesForAllChannels(charFramePtr,obj->fImageParams.frameSizePerChannel * obj->fImageParams.numLoggingChannels);

        obj->fFrameQueue->front_checkin();
      } else {

        int modVal = obj->fFramesLogged % obj->fAverageFactor;
        if (modVal == 0) {
          obj->zeroAveragingBuffers();
        }
        bool computeAverageTF = (modVal + 1 == obj->fAverageFactor);

        obj->addToAveragingBuffer(framePtr);

        if (obj->fFrameTagEnable && computeAverageTF) {
          if (!obj->updateFrameTag(charFramePtr)) {
            // This break will exit loggingThreadFcn. Subsequent calls
            // to stopLogging or stopLoggingImmediately will "succeed".
            break; 
          }      
        }

        obj->fFrameQueue->front_checkin();
        framePtr = NULL;

        if (computeAverageTF) {
          obj->computeAverageResult();

          obj->fTifWriter->writeFramesForAllChannels(obj->fAveragingResultBuf,
            obj->fImageParams.frameSizePerChannel * obj->fImageParams.numLoggingChannels);
        }
      }

      obj->fFrameQueue->pop_front();
      obj->fFramesLogged++;
    }

    Sleep(0); //relinquish thread
  }

  CONSOLEPRINT("FrameLogger: exiting logging thread.\n");

  if (obj->fTifWriter->isTifFileOpen()) {
    obj->fTifWriter->closeTifFile();
  }

  return 0;
}

bool
FrameLogger::updateFrameTag(const char *framePtr)
{
  CONSOLETRACE();
  const long *frameTagPtr =  reinterpret_cast<const long*>(framePtr + fImageParams.numLoggingChannels * fImageParams.frameSizePerChannel);
  long frameTag = *frameTagPtr;
  if (fFrameTagOneBased) {
    frameTag++;
  }

  char frameTagStr[FRAME_TAG_STRING_LENGTH+1] = "0";
  int numWritten = sprintf(frameTagStr,FRAME_TAG_FORMAT_STRING,frameTag);
  //int numWritten = sprintf_s(frameTagStr,FRAME_TAG_STRING_LENGTH+1,"Frame Tag = %08d",frameTag);  

  if (numWritten == FRAME_TAG_STRING_LENGTH) {
    fTifWriter->modifyImageDescription(0,frameTagStr,FRAME_TAG_STRING_LENGTH);
    return true;
  } else {
    char str[256];
    sprintf_s(str,256,"FrameLogger: Error writing frame tag. Wrote %d chars to make string: %s. (should have written %d). Aborting logging.\n",numWritten,frameTagStr,FRAME_TAG_STRING_LENGTH);
    MessageBox(NULL,str,"Error",MB_OK);
    return false;
  }
}

void FrameLogger::zeroAveragingBuffers(void)
{
  assert(fAveragingBuf!=NULL);
  for (size_t i=0;i<(fImageParams.frameNumPixels * fImageParams.numLoggingChannels);i++) {
    fAveragingBuf[i] = 0.0;
  }
  assert(fAveragingResultBuf!=NULL);
  for (size_t i=0;i<(fImageParams.frameSizePerChannel * fImageParams.numLoggingChannels);i++) {
    fAveragingResultBuf[i] = 0; // unnnecessary, defensive programming
  }
}

void FrameLogger::addToAveragingBuffer(const void *p)
{
  assert(fAveragingBuf!=NULL);
  assert(sizeof(short)==2);
  assert(sizeof(long)==4);

  for (int i=0;i<(fImageParams.frameNumPixels*fImageParams.numLoggingChannels);i++) {
    switch (fImageParams.bytesPerPixel) {
    case 1:
      fAveragingBuf[i] += (double) (*((char*)p + i)); // ((char*)p)[i]
      break;
    case 2:
      fAveragingBuf[i] += (double) (*((short*)p + i)); // etc
      break;
    case 4:
      fAveragingBuf[i] += (double) (*((long*)p + i));
      break;
    default:
      assert(false);
    }
  }
}

void FrameLogger::computeAverageResult(void)
{
  for (int i=0;i<(fImageParams.frameNumPixels * fImageParams.numLoggingChannels);++i) {
    double avVal = fAveragingBuf[i] / (double)fAverageFactor;
    switch (fImageParams.bytesPerPixel) {
    case 1:
      ((char *)fAveragingResultBuf)[i] = (char)avVal;
      break;
    case 2:				
      ((short *)fAveragingResultBuf)[i] = (short)avVal;
      break;
    case 4:
      ((long *)fAveragingResultBuf)[i] = (long)avVal;
      break;
    default:
      assert(false);
    }
  }
}

void
FrameLogger::deleteAveragingBuffers(void) 
{
  if (fAveragingBuf!=NULL) {
    delete[] fAveragingBuf;
    fAveragingBuf = NULL;
  }
  if (fAveragingResultBuf!=NULL) {
    delete[] fAveragingResultBuf;
    fAveragingResultBuf = NULL;
  }

}
