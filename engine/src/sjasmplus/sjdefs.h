/*

  SjASMPlus Z80 Cross Compiler

  Copyright (c) 2004-2006 Aprisobal

  This software is provided 'as-is', without any express or implied warranty.
  In no event will the authors be held liable for any damages arising from the
  use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it freely,
  subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not claim
	 that you wrote the original software. If you use this software in a product,
	 an acknowledgment in the product documentation would be appreciated but is
	 not required.

  2. Altered source versions must be plainly marked as such, and must not be
	 misrepresented as being the original software.

  3. This notice may not be removed or altered from any source distribution.

*/

//sjdefs.h

#ifndef __SJDEFS
#define __SJDEFS

// not used
#define MAXPASSES 3

#define LASTPASS 3

// output
#define _COUT cout << 
#define _CMDL  << 
#define _ENDL << endl
#define _END ;

// standard libraries
#ifdef WIN32
#include <windows.h>
#endif

#include <stack>
#include <iostream>
using std::cout;
using std::cerr;
using std::endl;
using std::flush;
using std::stack;
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <math.h>

// global defines
#define LINEMAX 2048
#define LINEMAX2 LINEMAX*2
#ifdef DOS
#define LABMAX 32
#define LABTABSIZE 16384
#define FUNTABSIZE 2048
#else
#define LABMAX 64
#define LABTABSIZE 32768
#define FUNTABSIZE 4096
#endif
#define aint unsigned long

// include all headers
#include "devices.h"
#include "support.h"
#include "tables.h"
#include "reader.h"
#include "parser.h"
#include "z80.h"
#include "directives.h"
#include "sjio.h"
#include "io_snapshots.h"
#include "io_trd.h"
#include "sjasm.h"

#endif
//eof sjdefs.h
