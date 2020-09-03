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

#include "tommyarrayblk.h"

#include <string.h> /* for memset */

/******************************************************************************/
/* array */

void tommy_arrayblk_init(tommy_arrayblk* array)
{
	tommy_array_init(&array->block);

	array->size = 0;
}

void tommy_arrayblk_done(tommy_arrayblk* array)
{
	unsigned i;

	for(i=0;i<tommy_array_size(&array->block);++i)
		tommy_free(tommy_array_get(&array->block, i));

	tommy_array_done(&array->block);
}

void tommy_arrayblk_grow(tommy_arrayblk* array, unsigned size)
{
	unsigned block_max = (size + TOMMY_ARRAYBLK_SIZE - 1) / TOMMY_ARRAYBLK_SIZE;
	unsigned block_mac = tommy_array_size(&array->block);

	if (block_mac < block_max) {
		/* grow the block array */
		tommy_array_grow(&array->block, block_max);

		/* allocate new blocks */
		while (block_mac < block_max) {
			void* ptr = tommy_malloc(TOMMY_ARRAYBLK_SIZE * sizeof(void*));

			/* initializes it with zeros */
			memset(ptr, 0, TOMMY_ARRAYBLK_SIZE * sizeof(void*));

			/* set the new block */
			tommy_array_set(&array->block, block_mac, ptr);

			++block_mac;
		}
	}

	if (array->size < size)
		array->size = size;
}

tommy_size_t tommy_arrayblk_memory_usage(tommy_arrayblk* array)
{
	return tommy_array_memory_usage(&array->block) + tommy_array_size(&array->block) * TOMMY_ARRAYBLK_SIZE * sizeof(void*);
}

