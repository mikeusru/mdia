#pragma once

#include <deque>
#include "StateModelObject.h"
#include "AbstractConsumerQueue.h"
#include "TifWriter.h"
#include "ThorLSM.h"

class LogFileNote {

 public:  
  
  LogFileNote(void) : frameIdx(1) { }
  
  LogFileNote(const char *fname, const char *modestr, unsigned long frmidx) :
  filename(fname), modeStr(modestr), frameIdx(frmidx) { }
  
  std::string filename;
  std::string modeStr;
  std::string imageDesc;
  unsigned long frameIdx;
};

/*
  FrameLogger

  FrameLogger is a model FrameActor. It polls an input FrameQueue and
  processes frames as they show up. This is done in a separate
  processing thread.

  Responsibilities.
  * Logging-level averaging
  * Streaming to disk

  Thread-safety.  
  The threading model is similar to ThorFrameCopier. The usage model
  involves three threads:
  * Controller thread. This thread calls init/configuration methods,
    starts/stops processing, etc. There should only be one such
    thread, ie only one thread should make calls to the FrameLogger
    public API.
  * Processing thread. FrameLogger spawns this thread to perform its
    duties. Averaging and streaming to TIF files is done in this thread.
  * Input-Queue-Producer thread. In general, another thread acts as the
    producer for the input queue.

  State model.
  The state model here is the same as for ThorFrameCopier, except that 
  there currently is no PAUSED state. While pausing the logger is reasonable 
  in theory, at the moment doing so will quickly result in dropped logging 
  frames.  
*/
class FrameLogger : public StateModelObject {
  
 public:
  
  FrameLogger(void);

  ~FrameLogger(void);


  /// Initialization methods (setup/config)
  /// These methods cannot be called on a FrameLogger at state ARMED
  /// or above.

  void setInputQueue(AbstractConsumerQueue *q);

  bool getFrameTagEnable();

  void setFrameTagProps(bool frameTagEnable,bool frameTagOneBased);

  // Configure image parameters.
  void configureImage(const ImageParameters &ip,
		      unsigned int averagingFactor,
		      const char *imageDesc);

  // Set the filename/modestr for the logging file. Note that this
  // call resets the current queue of LogFileNotes. 
  void configureFile(const char *filename,const char *modestr);

  // not implemented
  // void setHeaderString(const char *str);


  /// Arm

  // Precondition: CONSTRUCTED or ARMED (double-arming has no effect)
  // Postcondition: ARMED if successful, CONSTRUCTED otherwise.
  //
  // Return value is true on success, false otherwise.
  bool arm(void);

  // Precondition: ARMED or STOPPED.
  // Postcondition: CONSTRUCTED
  void disarm(void);


  /// Start/stop logging. 
  
  // Resets counters and logging will begin when data is put into
  // frame queue.
  // 
  // Precondition: ARMED 
  // Postcondition: RUNNING
  void startLogging(int frameDelay);

  // Equivalent to state==RUNNING.
  bool isLogging(void) const;

  // Stop logging as soon as the input queue is emptied. This blocks
  // until logging is stopped.
  // 
  // Precondition: RUNNING 
  // Postcondition: STOPPED
  //
  // Note that to start logging again from a STOPPED state requires
  // calls to disarm() and then arm() before startLogging() can be called
  // again. This ensures clean initialization of all necessary state.
  void stopLogging(void);

  // Stop logging asap (input queue is not necessarily emptied). This
  // blocks until logging is stopped.
  //
  // Precondition: RUNNING
  // Postcondition: STOPPED
  void stopLoggingImmediately(void);


  /// Runtime adjustment

  // Add a note to the back of the rolloverNote queue. The frameIdxs
  // in the queue should be monotically increasing.
  //
  // Precondition: ARMED or RUNNING or STOPPED
  // Postcondition: state unaffected
  void addLogfileRolloverNote(const LogFileNote &lfn);

  
  /// Run metadata

  // This can be called in any state.
  unsigned long getFramesLogged(void) const;

  
  /// Misc

  // Append debug info to s.
  void debugString(std::string &s) const;

 private:

  static unsigned int WINAPI loggingThreadFcn(LPVOID);

  void zeroAveragingBuffers(void);
  // add fPixelsPerFrame pixels, each of size fBytesPerPixel, to fAveragingBuf
  void addToAveragingBuffer(const void *p);
  // compute average of fAveragingBuf; place result in fAveragingResultBuf
  void computeAverageResult(void);
  void deleteAveragingBuffers(void);

  bool updateFrameTag(const char *framePtr);
  
 private:
  static const DWORD STOP_LOGGING_TIMEOUT_MILLISECONDS = 5000; // 5 seconds
  static const char* FRAME_TAG_FORMAT_STRING; //Allow up to 10 million
  static const unsigned int FRAME_TAG_STRING_LENGTH = 8 + 13; //Allow for 'Frame Tag = \n' at start
  static const unsigned int IMAGE_DESC_DEFAULT_PADDING = 100;
  
  HANDLE fThread;
  
  // FrameQueue has mutable state, so calls to it probably won't be
  // optimized away. In particular for example we want isEmpty() not
  // to be cached.
  AbstractConsumerQueue *fFrameQueue;
  TifWriter *fTifWriter;

  ImageParameters fImageParams;
  unsigned int fAverageFactor;
  double *fAveragingBuf; // one double for every pixel in a frame
  char *fAveragingResultBuf; // one byte/char for every byte in a frame

  // runtime state
  bool volatile fKillLoggingFlag;
  bool volatile fHaltLoggingFlag;

  CRITICAL_SECTION fLogfileRolloverCS;
  std::deque<LogFileNote> fLogfileNotes;
  unsigned long fFramesLogged;

  bool fFrameTagEnable; // if true, an extra long word is copied with each source Thor frame, indicating the frame's index value. This value will be appended to ImageDescription.
  bool fFrameTagOneBased; // if true, frame tag values are converted to one-based indexing before being logged
  int fFrameDelay; // number of frames to require in fFrameQueue before logging and removing frames from queue. serves as a delay of the logging thread relative to any other processing. 

  unsigned int fConfiguredImageDescLength; // length of image description specified at last configureImage()

};
