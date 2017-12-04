#include "util.h"
#include "FrameActor.h"

unsigned int WINAPI FrameActorThreadFcn(void*)
{


}

FrameActor::FrameActor(void)
{
  assertNotNULL(this->ntfyNewFrame = CreateEvent(NULL, // default security attr
						 FALSE, // autoreset
						 FALSE, // initially unsignalled
						 NULL));
  assertNotNULL(this->ntfyStopWhenFinished = CreateEvent(NULL,TRUE,FALSE,NULL)); // manual reset
  assertNotNULL(this->ntfyKill = CreateEvent(NULL,TRUE,FALSE,NULL)); // manual reset
  assertNotNULL(this->ntfyPause = CreateEvent(NULL,TRUE,TRUE,NULL)); // manual reset, initially signalled

  fThread = (HANDLE)_beginthreadex(NULL, // default security
				   0, // default stacksize
				   FrameActorThreadFcn, 
				   (void*) this, // ThreadFcn arg
				   0, // thread starts running
				   NULL); // no thread ID
  assert(fThread!=0);
}

FrameActor::~FrameActor(void)
{
  
  if (this->isLive()) {
    this->kill();
  }
  
  closeHandleAndSetToNULL(&this->ntfyNewFrame);
  closeHandleAndSetToNULL(&this->ntfyStopWhenFinished);
  closeHandleAndSetToNULL(&this->ntfyKill);  
}

bool
FrameActor::isLive(void) const
{
  return fThread!=0;
}

FrameActor::start(void)
{
  assert(this->isLive());
  
  DWORD ret = ResumeThread(fThread);
  assert(ret!=(DWORD)(-1));
}

FrameActor::isRunning(void)
{
  

}
