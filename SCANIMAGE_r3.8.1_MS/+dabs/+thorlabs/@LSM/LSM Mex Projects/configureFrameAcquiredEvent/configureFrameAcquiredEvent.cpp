#include "stdafx.h"
#include <process.h>    /* _beginthread, _endthread */
#include "TifWriter.h"
#include <string>
#include <map>

#include "CFAE.h"
#include "ThorLSM.h"
#include "FrameLogger.h"
#include "FrameQueue.h"
#include "ThorFrameCopier.h"

// LTTODO: thread priorities?

#define MAXSCANNERID 4096

namespace scannerMap
{
  // map of all currently known scanners.
  std::map<int,ThorLSM*> *scannerID2ThorLSMObj = NULL;
  
  // Create/Initialize ThorLSM object for a given M-object and put it
  // into the scanner map. Return the new ThorLSM object (owned by map).
  // 
  // Call this when an LSM M-object is first constructed (its deviceID
  // must be properly set).
  ThorLSM * createAndInitializeThorLSM(const mxArray* lsmObj) 
  {
    assert(lsmObj!=NULL);
    
    int scannerID = CFAEMisc::getIntScalarPropFromMX(lsmObj,"deviceID");
    assert(scannerID>=0 && scannerID<MAXSCANNERID);
    assert(scannerID2ThorLSMObj->find(scannerID)==scannerID2ThorLSMObj->end());
    
    ThorLSM *tlsm = new ThorLSM();
    tlsm->init(lsmObj);
    scannerID2ThorLSMObj->insert(std::pair<int,ThorLSM*>(scannerID,tlsm));
    return tlsm;
  }

  // Get the ThorLSM for the given LSM M-object. Returns NULL if the
  // M-object has no corresponding ThorLSM.
  ThorLSM * getThorLSM(const mxArray *lsmObj)
  {
    assert(lsmObj!=NULL);
    int scannerID = CFAEMisc::getIntScalarPropFromMX(lsmObj,"deviceID");
    std::map<int,ThorLSM*>::iterator it = scannerID2ThorLSMObj->find(scannerID);    
    return (it==scannerID2ThorLSMObj->end()) ? NULL : it->second;
  }
  
  // Destroy the ThorLSM object for a given M-object and remove from the
  // scanner map.
  //
  // Call this when an LSM M-object is being destroyed.
  void destroyThorLSM(const mxArray* lsmObj)
  {
    assert(lsmObj!=NULL);
    
    int scannerID = CFAEMisc::getIntScalarPropFromMX(lsmObj,"deviceID");
    std::map<int,ThorLSM*>::iterator it = scannerID2ThorLSMObj->find(scannerID);
    assert(it!=scannerID2ThorLSMObj->end());
    
    ThorLSM *tlsm = it->second;
    delete tlsm;
    scannerID2ThorLSMObj->erase(it);
  }

  void destroyAllThorLSMs(void)
  {
    std::map<int,ThorLSM*>::iterator it, itend;
    for (it=scannerID2ThorLSMObj->begin(),itend=scannerID2ThorLSMObj->end();
	 it!=itend;it++) {
      ThorLSM *tlsm = it->second;
      delete tlsm;
    }
    scannerID2ThorLSMObj->clear();
  }
}

#define MAX_LSM_COMMAND_LEN 32

enum LSMCommandType { INITIALIZE = 0,
		      CONFIG_BUFFERS, 
		      CONFIG_FILE,
		      CONFIG_CALLBACK, 
			  CONFIG_CALLBACK_DECIMATION,
		      //		      DEBUG_MESSAGES, 
		      PREFLIGHT, 
		      POSTFLIGHT, 
		      SETUP, 
		      NEWACQ,
		      START,
		      START_LOGGING,
		      START_ALREADY_RUNNING,
		      //START_DIRECT,
		      PAUSE,
		      RESUME,
		      FINISH,
		      STOP,
		      ADD_LOGFILE_ROLLOVER_NOTE,
		      IS_ACQUIRING,
		      GETDATA, 
		      GET,
		      FINISH_LOG,
		      FLUSH,
		      DESTROY,
		      TEST,
		      DEBUG_SHOW_STATUS,
		      UNKNOWN_CMD };
 
LSMCommandType getLSMCommand(const char* str) {
  CONSOLEPRINT("configureFrameAcquiredEvent: %s\n", str);
 
  if     (strcmp(str, "getdata") == 0) { return GETDATA; } 
  else if(strcmp(str, "flush") == 0) { return FLUSH; } 
  else if(strcmp(str, "finishLogging") == 0) { return FINISH_LOG; }
  else if(strcmp(str, "setup") == 0) { return SETUP; } 
  else if(strcmp(str, "isAcquiring") == 0) { return IS_ACQUIRING; } 
  else if(strcmp(str, "start") == 0) { return START; } 
  else if(strcmp(str, "startAlreadyRunning") == 0) { return START_ALREADY_RUNNING; } 
  else if(strcmp(str, "startLogger") == 0) { return START_LOGGING; }
  //else if(strcmp(str, "startDirect") == 0) { return START_DIRECT; } 
  else if(strcmp(str, "get") == 0) { return GET; } 
  else if(strcmp(str, "newacq") == 0) { return NEWACQ; } 
  else if(strcmp(str, "pause") == 0) { return PAUSE; } 
  else if(strcmp(str, "resume") == 0) { return RESUME; } //   } /else if(strcmp(str, "debugmessages") == 0) { return DEBUG_MESSAGES;
  else if(strcmp(str, "configBuffers") == 0) { return CONFIG_BUFFERS; } 
  else if(strcmp(str, "configLogFile") == 0) { return CONFIG_FILE; }
  else if(strcmp(str, "addLogfileRolloverNote") == 0) { return ADD_LOGFILE_ROLLOVER_NOTE; }
  else if(strcmp(str, "configCallback") == 0) { return CONFIG_CALLBACK; } 
  else if(strcmp(str, "configCallbackDecimationFactor") == 0) { return CONFIG_CALLBACK_DECIMATION; }
  else if(strcmp(str, "preflight") == 0) { return PREFLIGHT; } 
  else if(strcmp(str, "postflight") == 0) { return POSTFLIGHT; } 
  else if(strcmp(str, "stop") == 0) { return STOP; } 
  else if(strcmp(str, "finish") == 0) { return FINISH; } 
  else if(strcmp(str, "initialize") == 0) { return INITIALIZE; } 
  else if(strcmp(str, "destroy") == 0) { return DESTROY; } 
  else if(strcmp(str, "test") == 0) { return TEST; } 
  else if(strcmp(str, "debugShowStatus") == 0) { return DEBUG_SHOW_STATUS; }

  return UNKNOWN_CMD;
}

static bool mexInitted = false;

// Called at mex unload/exit
void uninitMEX(void) 
{
  CONSOLETRACE();
  scannerMap::destroyAllThorLSMs();
  if (scannerMap::scannerID2ThorLSMObj!=NULL) {
    delete scannerMap::scannerID2ThorLSMObj;
    scannerMap::scannerID2ThorLSMObj = NULL;
  }
  mexUnlock();
  mexInitted = false;
}

void initMEX(void) {
#ifdef CONSOLEDEBUG
  ThorMexDebugger::getInstance()->setConsoleAttribsForThread(FOREGROUND_BLUE|FOREGROUND_GREEN|FOREGROUND_INTENSITY);
  CONSOLETRACE();
#endif

  scannerMap::scannerID2ThorLSMObj = new std::map<int,ThorLSM*>;
  assert(scannerMap::scannerID2ThorLSMObj!=NULL);
  mexLock();
  mexAtExit(uninitMEX);
  mexInitted = true;
}

mxArray* getAttrib(ThorLSM*, const mxArray*);

// status = configureFrameAcquiredEvent(lsmObj,cmdString,varargin)
// lsmObj: dabs.thorlabs.LSM scalar object
// cmdString: LSM command (see getLSMCommand)
// varargin: addnl arguments depending on LSM command
// status: return code dependent on cmdString
void
mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

  if(!mexInitted) {
    initMEX();
  }

  if(nrhs < 2) {
    mexErrMsgTxt("No command specified.");
  }
  char cmdStr[MAX_LSM_COMMAND_LEN];
  mxGetString(prhs[1],cmdStr,MAX_LSM_COMMAND_LEN);

  LSMCommandType lsmCmd = getLSMCommand(cmdStr);
  if(lsmCmd == UNKNOWN_CMD) {
    char errMsg[256];
    sprintf_s(errMsg,256,"\nconfigureFrameAcquiredEvent: Unrecognized command '%s'.",cmdStr);
    mexErrMsgTxt(errMsg);
  }

  const mxArray* lsmObj = prhs[0];
  ThorLSM *tlsm = scannerMap::getThorLSM(lsmObj);

  // most commands require that scanner data has been initialized, so perform this check first
  switch(lsmCmd) {
  case INITIALIZE :
  case TEST : 
    //case DEBUG_MESSAGES :
    // these commands DO NOT require a scanner has been initialized
    break;
  default :
    CFAEMisc::mexAssert(tlsm!=NULL,
			"\nconfigureFrameAcquiredEvent: scanner not found or not initialized - call 'initialize' first");
    break;
  }

//   // these commands require that 'configBuffers' has been called 
//   switch(lsmCmd) {
//   case PREFLIGHT : 
//     if(scannerData->singleFrameBuffer == NULL)
//       mexErrMsgTxt("\nconfigureFrameAcquiredEvent: buffers not initialized - call 'configBuffers' first.");
//     break;
//   case POSTFLIGHT : case SETUP : case START : case START_DIRECT : case GETDATA : case NEWACQ : 
//     if(scannerData->singleFrameBuffer == NULL)
//       mexErrMsgTxt("\ncLSM: An expected frame buffer was found not initialized. Most likely, preflightAcquisition() call is required.");
//     break;
//   }

  int status = -13; // return value
  
  switch (lsmCmd) {

  case INITIALIZE : 
    scannerMap::createAndInitializeThorLSM(lsmObj);
    break;

  case CONFIG_CALLBACK : 
    tlsm->configureCallback(); 
    break;

  case CONFIG_CALLBACK_DECIMATION : 
    tlsm->configureCallbackDecimationFactor(); 
    break;

  case CONFIG_BUFFERS : 
    tlsm->configureImageBuffers(); 
    break; 

  case CONFIG_FILE :
    tlsm->configureLogFile();
    break; 

  case ADD_LOGFILE_ROLLOVER_NOTE :
    {
      assert(nrhs==3);
      int frameToStart = (int)mxGetScalar(prhs[2]);
      tlsm->addLogfileRolloverNote(frameToStart);
    }
    break;

   //  case DEBUG_MESSAGES :     
   //debugScanner(); break;

  case GET : 
    CFAEMisc::mexAssert(nrhs>=3,"Attribute not specified.");
    if (nlhs>=1) {
      plhs[0] = getAttrib(tlsm,prhs[2]); 
    }
    break;

  case PREFLIGHT : 
    status = tlsm->thorPreflightAcquisition();
    break;

  case POSTFLIGHT :
    status = tlsm->thorPostflightAcquisition();
    break; 

  case SETUP :
    status = tlsm->thorSetupAcquisition();
    break;

  case NEWACQ : 
    tlsm->arm();
    break;

  case PAUSE :
    tlsm->pauseAcquisition();
    break;

  case RESUME :
    tlsm->resumeAcquisition();
    break;

  case START_LOGGING :
    {
      assert(nrhs==3);
      int frameDelay = (int)mxGetScalar(prhs[2]);
      tlsm->startLogging(frameDelay);      
    }
    break;

  case START : 		
    {
      assert(nrhs==3);
      bool allowLogging = static_cast<bool>(mxGetScalar(prhs[2]));
      tlsm->startAcquisition(allowLogging);
    }
    break; 

  case START_ALREADY_RUNNING :
    tlsm->startAlreadyRunning();
    break;

  //case START_DIRECT :
  //  status = tlsm->startAcquisitionDirect();
  //  break;

  case STOP :
  case FINISH:
    tlsm->stopAcquisition();
    break;

  case IS_ACQUIRING : 
    status = tlsm->isAcquiring() ? 1 : 0;
    break;

  case GETDATA : 
    {
      int numFrames = (nrhs>=3) ? (int)mxGetScalar(prhs[2]) : 0; // 0 indicates return all avail frames
      assert(numFrames>=0);
      if (nlhs>=1) {
        mxArray *data = tlsm->getProcessedFrames(numFrames);
        plhs[0] = data;
      }

      // used to be that data could be NULL if eg you requested frames when there were none.
      //       if(data == NULL) {
      // 	data = mxCreateNumericMatrix(1, 0, RETURNED_IMAGE_DATATYPE, mxREAL);
      //       }
    }
    break; 

  case FLUSH : 
    mexPrintf("Flush: this command currently doesn't do anything.\n");
    break;

  case FINISH_LOG :
    mexPrintf("FinishLogging: this command currently doesn't do anything.\n");
    break;

  case DESTROY :
    scannerMap::destroyThorLSM(lsmObj); 
    break;

  case TEST : 
    CONSOLEPRINT("\n\n\n"); //wouldn't mind clearing console, but with WinAPI only this doesn't seem easy
    mexPrintf("\nLSM test successful!\n"); 
    break;

  case DEBUG_SHOW_STATUS :
    {
      std::string s;
      tlsm->debugString(s);
      mexPrintf("\n\n");
      mexPrintf(s.c_str());
      mexPrintf("\n\n");
    }
    break;

  default: 
    break;
  }

  // return status unless the command is getdata or get, which return different values
  if(nlhs > 0 && lsmCmd != GETDATA  && lsmCmd != GET) {
    assert(nlhs==1);
    assert(sizeof(int)==4);
    plhs[0] = mxCreateNumericMatrix(1,1,mxINT32_CLASS,mxREAL);
    int *ptr = (int*)mxGetData(plhs[0]);
    ptr[0] = status;
  }	
}

mxArray* getAttrib(ThorLSM *tlsm, const mxArray *attribName) {
  assert(attribName!=NULL);

  char attribStr[64];
  mxGetString(attribName,attribStr,64);

  CONSOLEPRINT("getAttrib '%s'\n",attribStr);

  int val = -1;

  if (!strcmp(attribStr, "framesAvailable")) {
    val = (int)tlsm->getNumProcessedFramesAvailable();
  } else if (!strcmp(attribStr, "droppedFramesLast")) {
    val = (int)tlsm->getNumThorFramesDropped();
  } else if (!strcmp(attribStr, "frameCount")) {
    val = (int)tlsm->getNumThorFramesSeen();
  } else if (!strcmp(attribStr, "droppedProcessedFramesLast")) {
    val = (int)tlsm->getNumDroppedProcessedFrames();
  } else if (!strcmp(attribStr, "droppedLogFramesLast")) {
    val = (int)tlsm->getNumDroppedLogFrames();
  } else if (!strcmp(attribStr, "droppedFramesTotal")) {
    mexPrintf("getAttrib, droppedFramesTotal is no longer supported.\n");
    val = 0;
  } else if (!strcmp(attribStr, "droppedLogFramesTotal")) {
    mexPrintf("getAttrib, droppedLogFramesTotal is no longer supported.\n");
    val = 0;
  }

  mxArray* mxVal = mxCreateNumericMatrix(1,1,mxINT32_CLASS,mxREAL);
  int *intPr = (int*)(mxGetData(mxVal));
  intPr[0] = val;

  return mxVal;
}
