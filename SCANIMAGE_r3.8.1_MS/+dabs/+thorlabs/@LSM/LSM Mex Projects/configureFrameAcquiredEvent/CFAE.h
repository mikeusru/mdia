#pragma once

#include <windows.h>
#include <map>

//#define CONSOLEDEBUG

#ifdef CONSOLEDEBUG
// Might be able to simplify this, the only reason this isn't a function is wrapping cprintf.
#define CONSOLEPRINT(...)					   \
  do {                                                             \
    ThorMexDebugger::getInstance()->preConsolePrint();		   \
    _cprintf(__VA_ARGS__);					   \
    ThorMexDebugger::getInstance()->postConsolePrint();	   \
  } while (0)
#define CONSOLETRACE(...) CONSOLEPRINT("CFAE. %s: line %d\n",__FUNCTION__,__LINE__)
#define CFAEASSERT(tf,...)			\
  if (!(tf)) {					\
    CONSOLEPRINT(__VA_ARGS__);			\
  }
#else
#define CONSOLETRACE(...)
#define CONSOLEPRINT(...)
#define CFAEASSERT(tf,...) { assert(tf); }
#endif

/*
  ThorMexDebugger
  
  Singleton class for debugging.

 */
class ThorMexDebugger
{
 public:
  
  static ThorMexDebugger *getInstance(void);

  // Sets console text attributes for the calling thread.
  void setConsoleAttribsForThread(WORD wAttribs);

  // See CONSOLEPRINT() Macro, these are public only b/c I don't want
  // to figure out how to wrap _cprintf.
  void preConsolePrint(void);
  void postConsolePrint(void);  

 private:

  ThorMexDebugger(void);

  ~ThorMexDebugger(void);

  WORD getConsoleAttribsForThread(DWORD threadID);

 private:
   std::map<DWORD,WORD> fThreadID2ConsoleAttribs;
   CRITICAL_SECTION fConsoleWriteCS;
   HANDLE fConsoleScreenBuffer;
};

namespace CFAEMisc 
{
  void requestLockMutex(HANDLE h);
  void releaseLockMutex(HANDLE h);

  // Get a scalar-integer-valued property off a scalar object.
  int getIntScalarPropFromMX(const mxArray *obj,const char *propname);

  // Assertion using mexErrMsgTxt.
  void mexAssert(bool cond,const char *msg);

  void closeHandleAndSetToNULL(HANDLE &h);
}
  

/*
  #define REGISTERLSMEVENT_DEBUG
  #define REGISTERLSMEVENT_DEBUG_L2
  #define AsyncMex_errorMsg(...) // printf(__VA_ARGS__)

  #ifdef REGISTERLSMEVENT_DEBUG
  #pragma message("REGISTERANDOREVENT_DEBUG - Compiling in debug mode.")
  // standard debug messages
  // NOTE: DO NOT USE printf() here - it is redefined as mexPrintf and will cause crashes! (if used from the async thread)
  #define RegLSMEvent_DebugMsg(...) if(debugMessagesFlag && errorFile != NULL)  { fprintf(errorFile, __VA_ARGS__); fflush(errorFile); }
  #else
  #define RegLSMEvent_DebugMsg(...)
  #endif

  #ifdef REGISTERLSMEVENT_DEBUG_L2
  // higher level debug messages (for CopyAcquistion/getdata events)
  #define RegLSMEvent_L2_DebugMsg(...) if(debugMessagesFlag && errorFile != NULL)  { fprintf(errorFile, __VA_ARGS__); fflush(errorFile); }
  #else
  #define RegLSMEvent_L2_DebugMsg(...)
  #endif
*/
