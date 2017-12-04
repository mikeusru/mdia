// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently, but
// are changed infrequently
//

#pragma once

#include "targetver.h"

#define WIN32_LEAN_AND_MEAN             // Exclude rarely-used stuff from Windows headers
// Windows Header Files:
#include <windows.h>
#include <conio.h>

// TODO: reference additional headers your program requires here
#include "mex.h"
#include "LSM_SDK.h"
#include "CFAE.h"
#include <wchar.h>
#include <share.h>  // for fsopen constants _SHARE_XXX
#include <assert.h> // used for ASSERT
#include <vector>
#include <string>
#include <matrix.h> // only for fwd declare mxArray *
