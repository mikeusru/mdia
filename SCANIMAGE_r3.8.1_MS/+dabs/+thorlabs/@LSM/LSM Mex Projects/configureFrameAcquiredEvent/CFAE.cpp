#include "stdafx.h"
#include <windows.h>
#include "mex.h"
#include "CFAE.h"

ThorMexDebugger * ThorMexDebugger::getInstance(void)
{
  static ThorMexDebugger *tmd = NULL;
  if (tmd==NULL) {
    tmd = new ThorMexDebugger();
    assert(tmd!=NULL);
  }
  return tmd;
}

void
ThorMexDebugger::setConsoleAttribsForThread(WORD wAttribs)
{
  DWORD threadID = GetCurrentThreadId();
  fThreadID2ConsoleAttribs[threadID] = wAttribs;
}

void
ThorMexDebugger::preConsolePrint(void)
{
  DWORD threadID = GetCurrentThreadId();
  WORD attribs = getConsoleAttribsForThread(threadID);
  EnterCriticalSection(&fConsoleWriteCS);
  SetConsoleTextAttribute(fConsoleScreenBuffer,attribs); 
}

void
ThorMexDebugger::postConsolePrint(void)
{
  LeaveCriticalSection(&fConsoleWriteCS);
}

ThorMexDebugger::ThorMexDebugger(void) 
{
  BOOL ret = AllocConsole();
  assert(ret);
  fConsoleScreenBuffer = GetStdHandle(STD_OUTPUT_HANDLE);
  InitializeCriticalSection(&fConsoleWriteCS);
}

ThorMexDebugger::~ThorMexDebugger(void)
{
  DeleteCriticalSection(&fConsoleWriteCS);
  CloseHandle(fConsoleScreenBuffer);
}

WORD 
ThorMexDebugger::getConsoleAttribsForThread(DWORD threadID)
{
  std::map<DWORD,WORD>::iterator it = 
    fThreadID2ConsoleAttribs.find(threadID);
  if (it!=fThreadID2ConsoleAttribs.end()) {
    return it->second;
  } else {
    return FOREGROUND_RED|FOREGROUND_INTENSITY; // default attribs
  } 
}


void
CFAEMisc::requestLockMutex(HANDLE h) 
{
  WaitForSingleObject(h, INFINITE);
}

void 
CFAEMisc::releaseLockMutex(HANDLE h) 
{
  ReleaseMutex(h);
}

int 
CFAEMisc::getIntScalarPropFromMX(const mxArray *a,const char *pname)
{
  assert(a!=NULL);
  mxArray *tmp = mxGetProperty(a,0,pname);
  assert(tmp!=NULL);
  int retval = (int)mxGetScalar(tmp);
  mxDestroyArray(tmp);
  return retval;
}

void 
CFAEMisc::mexAssert(bool cond,const char *msg)
{
  if (!cond) {
    mexErrMsgTxt(msg);
  }
}

void
CFAEMisc::closeHandleAndSetToNULL(HANDLE& h)
{
  if (h!=NULL) {
    CloseHandle(h);
    h = NULL;
  }
}

 
