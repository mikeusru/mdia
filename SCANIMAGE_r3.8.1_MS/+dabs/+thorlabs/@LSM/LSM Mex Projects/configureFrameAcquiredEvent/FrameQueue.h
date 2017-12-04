#pragma once

#include <vector>
#include <windows.h>
#include "AbstractConsumerQueue.h"

// The queue is threadsafe except as noted in the comments. The
// typical/envisioned usage involves up to three threads: a producer who
// pushes records, a consumer who uses and pops records, and a
// controller who initializes/configures/clears.
// 
// Overflow pushes are dropped, but noted. Overflow pushes are dropped
// in order to maintain the relative temporal ordering of records as
// seen by the consumer.
class FrameQueue : public AbstractConsumerQueue {

 public:
  
  FrameQueue(void);
  
  ~FrameQueue(void);

  // Allocates memory and prepares queue for use. init() can be called
  // repeatedly at runtime to reset/clear and resize a FrameQueue. 
  void init(size_t recordSz, unsigned long capacity, 
	    unsigned long droppedPushCapacity);

  // Like init(), but uses existing parameters. Simply resets/clears the queue.
  void reinit(void);

  // Called by producer. Attempt to push a record onto the back of the queue. If
  // the queue is full, this will fail and a dropped push will be recorded.
  // 
  // Return value is true if push was successful, false otherwise.
  bool push_back(const void *src);

  // Return number of calls to push_back since last init().
  unsigned long total_num_push_back(void) const;

  // Return number of push_back calls that were dropped since last init().
  unsigned long num_dropped_push_back(void) const;

  // Return pointer to array of indices (one-based, of size
  // num_dropped_push_back, up to a maximum of droppedPushCapacity) of
  // dropped push_backs.
  //
  // WARNING: This call is inherently thread-unsafe if eg called during a
  // concurrent push.
  const std::vector<unsigned long> & dropped_push_back(void) const;

  bool isEmpty(void) const;

  // Return number of elements currently in queue.
  unsigned long size(void) const;

  // Called by consumer. Return address i) points to queue front. 
  // Returns NULL if size()==0.
  //
  // WARNING: this is thread-unsafe, eg with respect to a
  // concurrent pop_front or init. (A concurrent push_back is okay at
  // the moment since the push drops if the queue is full.)
  const void* front_unsafe(void) const;

  // Thread-safe way to peek at front. Call front_checkin when done peeking.
  const void* front_checkout(void);

  // If this is called without a preceding front_checkout call, the
  // results are indeterminate.
  void front_checkin(void);

  // Asserts that the queue is nonempty.
  void pop_front(void);

  unsigned long capacity(void) const;

  // Max number of elements to store in dropped_push_back().
  unsigned long dropped_push_capacity(void) const;

  std::size_t recordSize(void) const;

  // Append debug info to s.
  void debugString(std::string &s) const;

 private:
  void deleteBufs(void);

 private:
  size_t fRecordSize; // in bytes
  unsigned long fCapacity; // max num records in queue
  unsigned long fDroppedPushCapacity;
  unsigned long fNumPushBacks;
  unsigned long fNumDroppedPushBacks;
  std::vector<unsigned long> fDroppedPushBackIdxs;

  // impl note: fQBegin, fQSize are idxs into fQ. if fQSize>0, then 
  // fQ[fQBegin] has the front of the queue. (fQBegin+fQSize) % fCapacity points
  // immediately after the end of the queue.
  char *fQ;
  unsigned long fQBegin;
  unsigned long fQSize; // number of records in Q
  
  mutable CRITICAL_SECTION fCS;
};
