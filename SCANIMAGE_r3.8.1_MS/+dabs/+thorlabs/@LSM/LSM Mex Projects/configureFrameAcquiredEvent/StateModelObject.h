#pragma once

// StateModelObject defines a state model used by Thor-related C++
// classes. Subclasses currently have a free hand in defining which
// states are used and for defining/implementing available state
// changes.
//
//
// *Initialization/Configuration/Arming.*
// In general, subclasses may have multiple setup/configuration
// methods that prepare an object for running. In general, these
// methods may be called in arbitrary order. The purpose of the ARMED
// state is to provide a checkpoint beyond which an object is
// guaranteed to be correctly setup/configured. Typically, an object's
// arm() method (or whatever method leads to the ARMED state) will
// performs checks and validations, but perform no actual actions on
// the object.
// 
// The typical init/config/arm workflow is:
//   obj = new MyObject(...); // subclass of StateModelObject
//   obj.init(...);
//   obj.configure1(...);
//   obj.configure2(...);
//   obj.arm();
//   // object is now ready to run
//
// If a class has only one configuration/setup operation, then the
// following is possible:
//   obj = new MyObject(...);
//   obj.init(...);
//   obj.arm(...); // does all configuration/setup
//
class StateModelObject 
{
 public :

  enum State
  {
    // Freshly constructed objects are assigned this state.
    CONSTRUCTED = 0,

    // Typically, an object is only initted once.
    INITTED,

    // This state exists because some objects require an explicit
    // two-stage configuration before arming. For simpler objects,
    // this state can be omitted, with objects going straight from
    // INITTED to ARMED.
    CONFIGURED, 

    // Typically, arming an object performs checks and validations to
    // ensure that an object has been correctly
    // initted/configured. Arming need not perform any actual action on an
    // object (besides changing its state to ARMED).
    ARMED,

    // The STOPPED state exists primarily because it may be interesting for
    // a subclass to know that a run has occurred. For example, objects
    // may record metadata about the run, which can be available to
    // clients. However, the STOPPED state may also be omitted. In
    // general, after stopping a run, it is plausible that an object could
    // transition to any one of CONSTRUCTED, INITTED, CONFIGURED, ARMED, or
    // STOPPED.
    STOPPED,

    RUNNING,

    PAUSED,

    // An object that is killed typically is irrecoverably doomed.
    KILLED,

    NUMSTATES
  };

  State getState(void) const { return fState; }

  StateModelObject(void) : fState(CONSTRUCTED) { }

 protected:
  State fState;
};


