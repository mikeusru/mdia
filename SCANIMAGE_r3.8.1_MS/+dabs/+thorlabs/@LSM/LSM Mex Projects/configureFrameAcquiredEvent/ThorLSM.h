#pragma once

#include <string>
#include <matrix.h> // only for fwd declare mxArray *

#include "AsyncMex.h" // only for fwd declare
#include "StateModelObject.h"
#include "FrameQueue.h"

class FrameLogger;
class ThorFrameCopier;

struct AsyncMexMATLABCallbackArgs {

  static const unsigned int CALLBACK_EVENT_DATA_NUM_FIELDS = 5;
  static const char *CALLBACK_EVENT_DATA_FIELD_NAMES[];

  mxArray *rhs[3];
  mxArray *evtData;
  mxArray *framesAvailableArray;
  mxArray *droppedFramesArray;
  mxArray *droppedLogFramesArray;
  mxArray *droppedMLCallbackFramesArray;
  mxArray *frameCountArray;

  AsyncMexMATLABCallbackArgs(void);

  ~AsyncMexMATLABCallbackArgs(void);
};

struct ImageParameters {
  int imageHeight;
  int imageWidth;
  int bytesPerPixel;
  bool signedData;
  int numChannelsAvailable;
  int numProcessedDataChannels;
  int numLoggingChannels;

  int processedDataFirstChan; //First channel (starting with 1) designated to be included in data retrieved by getProcessedData()
  int loggingFirstChan; //First channel (starting with 1) designated to be included in frames logged to disk
  bool processedDataContiguousChans; //true if processed data channels are contiguous, e.g. 1-3, 2-4, not 1,3,4
  bool loggingContiguousChans; //true if processed data channels are contiguous, e.g. 1-3, 2-4, not 1,3,4

  std::vector<int> processedDataChanVec; //Vector of booleans, of size numChannelsAvailable, indicating which channels are designated to be included in data retrieved by getProcessedData()
  std::vector<int> loggingChanVec; //Vector of booleans, of size numChannelsAvailable, indicating which channels are designated to be included in frames logged to disk
  std::vector<int> chansToCopyVec; //Vector of booleans, of size numChannelsAvailable, containing the union of processedDataChanVec & loggingChanVec -- all the channels that are to be copied, for one purpose or another.
  bool singleChanVec; //true if processedDataChanVec=loggingChanVec

  bool subtractOffsetEnable;  //Boolean value true when one or more channel offset values should be subtracted
  std::vector<int> channelOffsets; //Vector of short integers representing last-measured offset value for each input channel. Value of 0 indicates no measured offset for a channel, or to disable subtraction for that channel.
  
  int frameNumChannels; // number of channels acquired by Thor API
  int frameNumPixels;
  int frameSize; // size of frame in bytes, including all of the frameNumChannels
  int frameSizePerChannel; //size of frame in bytes, for each channel

  ImageParameters(void) : 
    imageHeight(0), 
    imageWidth(0), 
    bytesPerPixel(0),
    signedData(0),
    numChannelsAvailable(0),
    numProcessedDataChannels(0),
    numLoggingChannels(0),
    processedDataFirstChan(-1),
    loggingFirstChan(-1),
    processedDataContiguousChans(false),
    loggingContiguousChans(false),
    singleChanVec(false),
	subtractOffsetEnable(0),
    frameNumChannels(0), //Can be either 1 or 4, given ThorAPI 
    frameNumPixels(0),
    frameSize(0),
    frameSizePerChannel(0)
  { 
  }

  // initialize values based on lsm M-object.
  void init(const mxArray *lsmObj);

  // Append debug info to s.
  void debugString(std::string &s) const;
};

//
// ThorLSM is a C++ interface to the Thorlabs LSM.
//
// State model:
// CONSTRUCTED: A freshly constructed ThorLSM is not usable.
// INITTED: A ThorLSM is initted only once. An initted ThorLSM is not usable.
// CONFIGURED: A Configured ThorLSM has had its configureImage() method called, which allocates
// memory for frame buffers and queues, etc.
// ARMED/RUNNING/PAUSED: These have the usual meaning.
class ThorLSM : public StateModelObject {

public:

  static const long DEFAULT_BYTES_PER_PIXEL = 2;
  static const char *DEFAULT_LSM_FILENAME;

  // MATLAB LSM property names (I started const-ifying string literals but didn't finish, no biggie.)
  static const char *LSM_MATLAB_PROPERTY_CALLBACK_DECIMATION;
  static const char *LSM_MATLAB_PROPERTY_PIXELS_PER_LINE;
  static const char *LSM_MATLAB_PROPERTY_LINES_PER_FRAME;

  static const unsigned int MAXFILENAMESIZE = 256;
  static const unsigned int MAXIMAGEHEADERSIZE = 8194; 

  ThorLSM(void);

  ~ThorLSM(void);

  // PreState: CONSTRUCTED
  // PostState: INITTED
  // 
  // Do not init a ThorLSM object twice.
  void init(const mxArray *lsmObj);

  int getScannerID(void) const;


  /// Config/setup

  // PreState: INITTED or CONFIGURED
  // PostState: CONFIGURED
  //
  // Configure image-related state based on lsm M-object. This
  // allocates buffers, queues, etc.
  void configureImageBuffers(void);

  // PreState: Any state where the logger is not running
  // PostState: unchanged
  // 
  // Configure logging state based on image parameters and lsm
  // M-object. M-object parameters read: loggingAverageFactor
  // filename, filemode, headerString
  void configureLogFile(void);

  // PreState: INITTED or CONFIGURED
  //
  // Configure frame-acquired MATLAB callback based on lsm M-object.
  // Can be called multiple times, but cannot be called during a running acq.
  void configureCallback(void);

  // PreState: INITTED or CONFIGURED
  //
  // Configure frame decimation factor to use for frame-acquired MATLAB callbacks, based on lsm M-object.
  // Can be called multiple times, but cannot be called during a running acq.
  void configureCallbackDecimationFactor(void);


  /// Arm

  /// LTTODO it doesn't really make sense to expose these as public API;
  // it doesn't make sense to call Thor::PostFlight outside of the
  // context of stopping an acq.
  long thorPreflightAcquisition(void);

  long thorSetupAcquisition(void);

  void arm(void);

private:
  // thorlabs.LSM has a flushData() call, but this is not used by
  // anybody and I can't see why it is needed at the moment.
  void reinitQueues(void);

public:

  /// Start/stop

  // Ordinarily this would be rolled into startAcquisition(). I believe we separated 
  // this method out so that the Logger can be configured after acquisition has already 
  // started (eg to note the first frame clock time etc).
  //
  // Note: There is no stopLogging() method, the logger is stopped (if running)
  // in stopAcquisition.
  void startLogging(int frameDelay);

  void startAcquisition(bool allowLogging);

  // Prestate: RUNNING
  //
  // This call should be used when running in FOCUS mode and an LSM
  // parameter is changed "on-the-fly." Examples include the acqDelay,
  // zoom, etc. In this situation, one should precede the call to
  // startAlreadyRunning() with calls to ThorLSM::SetParam() as
  // appropriate to set the desired LSM properties. (In practice this
  // is done in the LSM M-class.)
  //
  // Again, this call is only expected during FOCUS mode. Acquisition
  // counters (framesSeen, etc) are reset by this call. 
  void startAlreadyRunning(void);

  //// LTTODO Don't know why this exists.
  //// Return: Thor status code
  //long startAcquisitionDirect(void);

  // Notes: 
  // * If the object is not running, no action is taken.
  // * If the object is running:
  // ** Postcondition is CONFIGURED. 
  // ** Thor::PostFlightAcq is not called.
  // ** Logger finishes its Q.
  void stopAcquisition(void);

  // Pause/resume are specialized for SI stack use case. 
  void pauseAcquisition(void);

  // Pause/resume are specialized for SI stack use case. 
  void resumeAcquisition(void);

  bool isAcquiring(void) const;

  long thorPostflightAcquisition(void);


  /// Runtime adjustment

  // Precondition: RUNNING or PAUSED
  //
  // Read filename, modestr off M-object to createLogFileNote.
  void addLogfileRolloverNote(unsigned long frameToStart);


  /// Data/Metadata access

  // Get/pop frames from the processedDataQueue. Returns a newly
  // allocated mxArray (not mex-persistent).
  //
  // Set numFrames==0 to indicate "get all frames".
  mxArray * getProcessedFrames(int numFrames); 

  // Acquisition metadata/attributes
  unsigned int getNumProcessedFramesAvailable(void) const;
  unsigned int getNumThorFramesSeen(void) const;
  unsigned int getNumThorFramesDropped(void) const;
  unsigned int getNumDroppedLogFrames(void) const;
  unsigned int getNumDroppedProcessedFrames(void) const;

  /// Other

  static void asyncMexMATLABCallback(LPARAM scannerID, void *thorLSMObj);

  // Append debug info to s.
  void debugString(std::string &s) const;

private:
  void readLogfileStateOffMObject(int &loggingAverageFactor,
    std::string &fname,
    std::string &modestr,
    std::string &headerstr) const;

private:

  int fScannerID; // might be unnec
  mxArray *fScannerObjHandle; // mxArray containing handle to LSM object 

  // Future, consider moving these into MATLAB-callback frameactor
  AsyncMex *fAsyncMex;
  mxArray *fCallbackFuncHandle; 
  AsyncMexMATLABCallbackArgs fAsyncMexCbkArgs;

  ImageParameters fImageParams; // partially redundant with logger etc.
  char *fSingleFrameBuffer; // a single frame buffer used to hold the currently acquiring frame from the ThorLSM

  bool fFrameTagEnable; // if true, ThorAPI tags each frame (final long word at end of each frame copied from driver)

  FrameQueue fProcessedDataQueue;
  FrameQueue fLoggerQueue;
  ThorFrameCopier *fThorFrameCopier;		
  FrameLogger *fLogger;
};
