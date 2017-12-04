#pragma once

// XXX AL
/* 
Originally I thought this Actor class could apply to either i)
something which takes an action every time it is notified that a frame
has arrived, eg the Thor Single-frame copied, and ii) something which
processes an input FrameQueue. In fact I am not sure these are really
the same thing. For example, "stop when finished processing" concept
applies to the first but not the second. Also, in the second, you
query persistent state whether "frameavail", whereas in the first an
event gets signaled, which si different in the case when events stack
up before you are done processing. (For example if the event gets
signaled twice in rapid succession, depending on the timing you may
have no way of differentiating that from a single event). So now I am
not really sure these things are the same thing. I think just factor
the Thor-frame-copier out separately as a one-off. Note also that
fundamentally, the Thor thing of using a single frame buffer is unsafe
to dropped frames and not a good idea. Maybe they are buffering now or
whatever.
*/


/* 
   
STATE MODEL


   Cted  --init/set Qs
           subclass init methods ---> Initted ---arm--->  Stopped 
                                                          Processing
		   	                                  Paused
			                                  Stopping
               			                          Killed

Constructed: raw object.
Initted: initInputQueue called, subclass-specific init methods called.
Stopped: thread is live, but not processing frames. If input frames
are pushed on, they will build up in the queue. To get here, one had to arm().
Running: thread is live, processing frames in input queue.
Paused: identical to stopped, except when resuming, counters are not affected.
Stopping: thread is live and processing frames, but the moment the
queue is emptied, the state transitions to stopped.
Killed: it is over for this actor.

THREAD SAFETY 

This class is intended to work under the following model. There are
two threads:
* The config/control thread, which calls the various initialization
methods, arm(), start/stop/etc. At the moment this is assumed to be a
single thread.
* The actor thread, which is owned by this object, and which polls the
  input queue, calls processFrameHook to process frames, etc.

All non-virtual methods in FrameActor are called by the config/control
thread and are threadsafe in the sense that they adhere to the state
model above. It is not permitted to call initInputQueue in the
Processing state for example. armHook and disarmHook are called
by the config/control thread at the documented times.

processFrameHook is called by the actor thread.

ON-THE-FLY CONFIG
I did not put in general on-the-fly config b/c it is not clear what
the usage is besides for logging. For logging, do the following in the FrameActor subclass:

* add a method queueFileRolloverChangeinfo(rolloverInfo) that adds a
  new file rollover spec to a queue. Accessing the queue should be
  protected by mutexes since it will be accessed by the actor thread
  (via processFrameHook).
* In processFrameHook, read the queue (again, protected by mutexes)
  and roll over the file if appropriate.

Note that this means that file rollover can only occur (immediately
before) when a frame arrives. But that works fine for logging so we
won't overthink this for now.
*/


class FrameActor {

 protected :

  /// pure virtuals

  virtual void processFrameHook(const void *framePtr, unsigned long frameSz) = 0;
 
  virtual void armHook(void) = 0;

  virtual void disarmHook(void) = 0;

 public :

  enum State {
    CONSTRUCTED = 0,
    INITTED,
    STOPPED,
    PROCESSING,
    PAUSED,
    STOPPING,
    KILLED,
    NUM_STATES
  };

  FrameActor(void);

  ~FrameActor(void);


  /// init/configure

  void initInputQueue(size_t recordSz, unsigned long capacity, unsigned long droppedPushCapacity);
  
  // haven't needed to impl outputs yet
  // void FrameActor::setOutputQueues(const std::vector<FrameQueue*> &output);


  /// arm/disarm

  void arm(void);

  bool isArmed(void) const;

  void disarm(void);


  /// start/stop/pause/unpause

  // If the input queue is already nonempty, processing begins
  // immediately. If not, processing begins when the first frame arrives.
  // 
  // Counters are reset at every fresh start.
  void startProcessing(void);

  // A started actor is processing independent of the state of the
  // input queue (eg the input queue might happen to be empty at the moment).
  bool isProcessing(void) const;

  // A paused actor is not processing, but counters are maintained for the unpause.
  void pauseProcessing(void);

  void unpauseProcessing(void);

  // Stop processing the first moment that the input queue becomes empty.
  void stopProcessingWhenDone(void);

  void stopProcessingWhenDoneBlocking(void);

  // Stop processing as soon as possible. Any frames remaining in the input queue are untouched.
  void killProcessing(void);

 private:
  static unsigned int WINAPI threadFcn(LPVOID userData);

 private:
  State fState;

  HANDLE fThread;
  HANDLE fStartEvt;
  HANDLE fStopEvt;
  HANDLE fPauseEvt;
  HANDLE fKillEvt;

  FrameQueue *fInputQueue;  
};
