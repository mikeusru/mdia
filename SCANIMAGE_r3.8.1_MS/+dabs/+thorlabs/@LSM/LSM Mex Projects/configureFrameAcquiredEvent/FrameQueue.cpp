#include "stdafx.h"
#include <assert.h>
#include <sstream>
#include "FrameQueue.h"
#include "CFAE.h"

FrameQueue::FrameQueue(void) :
  fRecordSize(0),
  fCapacity(0),
  fNumPushBacks(0),
  fNumDroppedPushBacks(0),
  fDroppedPushCapacity(0),
  fQ(NULL),
  fQBegin(0),
  fQSize(0)
{
  InitializeCriticalSection(&fCS);
}

FrameQueue::~FrameQueue(void) 
{
  this->deleteBufs();
  DeleteCriticalSection(&fCS);
}

void
FrameQueue::deleteBufs(void)
{
  fDroppedPushBackIdxs.clear();
  if (fQ!=NULL) {
    delete[] fQ;
    fQ = NULL;
  }
}

void
FrameQueue::init(size_t recordSz,
		 unsigned long capacity,
		 unsigned long droppedPushCapacity)
{
  CONSOLETRACE();

  assert(recordSz>0);
  assert(capacity>0);
  assert(droppedPushCapacity>0); // enhancement: allow droppedPushCapacity==0

  EnterCriticalSection(&fCS);

  fRecordSize = recordSz;
  fCapacity = capacity;
  fDroppedPushCapacity = droppedPushCapacity;
  fNumPushBacks = 0;
  fNumDroppedPushBacks = 0;
  
  this->deleteBufs();
  fDroppedPushBackIdxs.reserve(fDroppedPushCapacity);
  fQ = new char[fCapacity*fRecordSize]();
  fQBegin = 0;
  fQSize = 0;

  LeaveCriticalSection(&fCS);
}

void
FrameQueue::reinit(void)
{
  CONSOLETRACE();
  init(fRecordSize,fCapacity,fDroppedPushCapacity);
}

bool
FrameQueue::push_back(const void *src)
{
  CONSOLETRACE();

  bool retval = true;

  EnterCriticalSection(&fCS);
  fNumPushBacks++;
  if (fQSize==fCapacity) {
    // queue is full; push will be dropped
    if (fDroppedPushBackIdxs.size() < fDroppedPushCapacity) {
      fDroppedPushBackIdxs.push_back(fNumPushBacks);
    }
    fNumDroppedPushBacks++;
    retval = false;
  } else {
    // queue has room; do the push
    unsigned long onePastEnd = (fQBegin+fQSize) % fCapacity;
    memcpy(fQ+onePastEnd*fRecordSize,src,fRecordSize);
    fQSize++;
  }
  LeaveCriticalSection(&fCS);

  return retval;
}

unsigned long 
FrameQueue::total_num_push_back(void) const
{
  // Here and in other simple getters, using CriticalSection methods
  // might be overkill, but I'm not sure. It's not hurting for now.
  EnterCriticalSection(&fCS);
  unsigned long retval = fNumPushBacks;
  LeaveCriticalSection(&fCS);

  return retval;
}

unsigned long 
FrameQueue::num_dropped_push_back(void) const
{
  EnterCriticalSection(&fCS);
  unsigned long retval = fNumDroppedPushBacks;
  LeaveCriticalSection(&fCS);

  return retval;
}

const std::vector<unsigned long> &
FrameQueue::dropped_push_back(void) const
{
  return fDroppedPushBackIdxs;
}

unsigned long 
FrameQueue::capacity(void) const
{
  EnterCriticalSection(&fCS);
  unsigned long retval = fCapacity;
  LeaveCriticalSection(&fCS);

  return retval;
}

unsigned long 
FrameQueue::dropped_push_capacity(void) const
{
  EnterCriticalSection(&fCS);
  unsigned long retval = fDroppedPushCapacity;
  LeaveCriticalSection(&fCS);

  return retval;
}

std::size_t 
FrameQueue::recordSize(void) const
{
  EnterCriticalSection(&fCS);
  std::size_t retval = fRecordSize;
  LeaveCriticalSection(&fCS);
  
  return retval;
}

bool 
FrameQueue::isEmpty(void) const
{
  EnterCriticalSection(&fCS);
  bool retval = (fQSize==0);
  LeaveCriticalSection(&fCS);

  return retval;
}

unsigned long 
FrameQueue::size(void) const
{
  EnterCriticalSection(&fCS);
  unsigned long retval = fQSize;
  LeaveCriticalSection(&fCS);

  return retval;
}

const void* 
FrameQueue::front_unsafe(void) const
{
  EnterCriticalSection(&fCS);
  const void* retval = (fQSize==0) ? NULL : fQ+fQBegin*fRecordSize;
  LeaveCriticalSection(&fCS);
 
  return retval;
}

const void*
FrameQueue::front_checkout(void)
{
  EnterCriticalSection(&fCS);
  const void* retval = (fQSize==0) ? NULL : fQ+fQBegin*fRecordSize;
  return retval;
}

// consider protecting front_checkout/checkin to protect against an
// "unpaired" checkin
void
FrameQueue::front_checkin(void)
{
  LeaveCriticalSection(&fCS);
}

void 
FrameQueue::pop_front(void)
{
  CONSOLETRACE();

  EnterCriticalSection(&fCS);
  assert(fQSize>0);
  fQBegin = (fQBegin+1) % fCapacity;
  fQSize--;
  LeaveCriticalSection(&fCS);
}

void
FrameQueue::debugString(std::string &s) const
{
  std::ostringstream oss;
  oss << "--FrameQueue--" << std::endl;
  oss << "RecordSz Cap DroppedPushCap NumPushBacks NumDroppedPushBacks: ";

  EnterCriticalSection(&fCS);
  oss << fRecordSize << " " << fCapacity << " " << fDroppedPushCapacity << " "
      << fNumPushBacks << " " << fNumDroppedPushBacks << std::endl;
  oss << "Q Size: " << fQSize << " " 
      << "DroppedPushBackIdxs.size: " << fDroppedPushBackIdxs.size() << std::endl;
  LeaveCriticalSection(&fCS);

  s.append(oss.str());
}
