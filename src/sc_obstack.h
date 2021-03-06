/*
  This file is part of the SC Library.
  The SC Library provides support for parallel scientific applications.

  Copyright (C) 2010 The University of Texas System

  The SC Library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  The SC Library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with the SC Library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  02110-1301, USA.
*/

#ifndef SC_OBSTACK_H
#define SC_OBSTACK_H

#include <sc.h>

#ifdef SC_PROVIDE_OBSTACK
#ifdef _OBSTACK_H
#error "obstack.h is included.  Include sc.h first or use --without-obstack".
#endif
#include "sc_builtin/obstack.h"
#else
#include <obstack.h>
#endif

#endif /* !SC_OBSTACK_H */
