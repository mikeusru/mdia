#pragma once

#include <cstddef>

class AbstractConsumerQueue {

 public:
  
  virtual std::size_t recordSize(void) const = 0;

  virtual bool isEmpty(void) const = 0;

  // Returns the number of records currently in the queue.
  virtual unsigned long size(void) const = 0;

  // Return front of queue (thread unsafe)
  virtual const void* front_unsafe(void) const = 0;

  // Return front of queue, and lock queue until
  // front_checkin. Remember to call front_checkin when you are done!
  virtual const void* front_checkout(void) = 0;

  virtual void front_checkin(void) = 0;

  // Pop first record.
  virtual void pop_front(void) = 0;

};
