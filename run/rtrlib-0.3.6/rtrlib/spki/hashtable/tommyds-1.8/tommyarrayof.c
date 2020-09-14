/*
 * Copyright 2013 Andrea Mazzoleni. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY ANDREA MAZZOLENI AND CONTRIBUTORS ``AS IS''
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL ANDREA MAZZOLENI OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#include "tommyarrayof.h"

#include <string.h> /* for memset */

/******************************************************************************/
/* array */

void tommy_arrayof_init(tommy_arrayof* array, unsigned element_size)
{
	/* fixed initial size */
	array->element_size = element_size;
	array->bucket_bit = TOMMY_ARRAYOF_BIT;
	array->bucket_max = 1 << array->bucket_bit;
	array->bucket[0] = tommy_malloc(array->bucket_max * array->element_size);

	/* initializes it with zeros */
	memset(array->bucket[0], 0, array->bucket_max * array->element_size);

	array->bucket_mac = 1;
	array->size = 0;
}

void tommy_arrayof_done(tommy_arrayof* array)
{
	unsigned i;
	for(i=0;i<array->bucket_mac;++i)
		tommy_free(array->bucket[i]);
}

void tommy_arrayof_grow(tommy_arrayof* array, unsigned size)
{
	while (size > array->bucket_max) {
		/* allocate one more bucket */
		array->bucket[array->bucket_mac] = tommy_malloc(array->bucket_max * array->element_size);

		/* initializes it with zeros */
		memset(array->bucket[array->bucket_mac], 0, array->bucket_max * array->element_size);

		++array->bucket_mac;
		++array->bucket_bit;
		array->bucket_max = 1 << array->bucket_bit;
	}

	if (array->size < size)
		array->size = size;
}

tommy_size_t tommy_arrayof_memory_usage(tommy_arrayof* array)
{
	return array->bucket_max * (tommy_size_t)array->element_size;
}

