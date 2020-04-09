/*
 *  Public key-based signature verification program
 *
 *  Copyright (C) 2006-2015, ARM Limited, All Rights Reserved
 *  SPDX-License-Identifier: GPL-2.0
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program; if not, write to the Free Software Foundation, Inc.,
 *  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 *
 *  This file is part of mbed TLS (https://tls.mbed.org)
 */

#if !defined(MBEDTLS_CONFIG_FILE)
#include "mbedtls/config.h"
#else
#include MBEDTLS_CONFIG_FILE
#endif

#if defined(MBEDTLS_PLATFORM_C)
#include "mbedtls/platform.h"
#else
#include <stdio.h>
#include <stdlib.h>
#define mbedtls_snprintf        snprintf
#define mbedtls_printf          printf
#define mbedtls_exit            exit
#define MBEDTLS_EXIT_SUCCESS    EXIT_SUCCESS
#define MBEDTLS_EXIT_FAILURE    EXIT_FAILURE
#endif /* MBEDTLS_PLATFORM_C */

#if !defined(MBEDTLS_BIGNUM_C) || !defined(MBEDTLS_MD_C) || \
    !defined(MBEDTLS_SHA256_C) || !defined(MBEDTLS_PK_PARSE_C) ||   \
    !defined(MBEDTLS_FS_IO)
int main( void )
{
    mbedtls_printf("MBEDTLS_BIGNUM_C and/or MBEDTLS_MD_C and/or "
           "MBEDTLS_SHA256_C and/or MBEDTLS_PK_PARSE_C and/or "
           "MBEDTLS_FS_IO not defined.\n");
    return( 0 );
}
#else

#include "mbedtls/error.h"
#include "mbedtls/md.h"
#include "mbedtls/pk.h"
#include "mbedtls/base64.h"

#include <stdio.h>
#include <string.h>


int main( int argc, char *argv[] )
{
    FILE *f;
    int ret = 1;
    int exit_code = MBEDTLS_EXIT_FAILURE;
    size_t i, j;
    mbedtls_pk_context pk;
    unsigned char hash[32];
    unsigned char buffer[MBEDTLS_MPI_MAX_SIZE];
    unsigned char buf[512];
    char filename[512];

    mbedtls_pk_init( &pk );

    if( argc != 3 )
        goto exit;

    if( ( ret = mbedtls_pk_parse_public_keyfile( &pk, argv[1] ) ) != 0 )
        goto exit;

    /*
     * Extract the signature from the file
     */
    mbedtls_snprintf( filename, sizeof(filename), "%s.sig", argv[2] );

    if( ( f = fopen( filename, "rb" ) ) == NULL )
        goto exit;

    i = fread( buf, 1, sizeof(buf), f );

    fclose( f );

    // convert from base64
    if( mbedtls_base64_decode( buffer, sizeof( buffer ), &j, buf, i ) != 0 )
        goto exit;       

    /*
     * Compute the SHA-256 hash of the input file and
     * verify the signature
     */
    if( ( ret = mbedtls_md_file(
                    mbedtls_md_info_from_type( MBEDTLS_MD_SHA256 ),
                    argv[2], hash ) ) != 0 )
        goto exit;

    if( ( ret = mbedtls_pk_verify( &pk, MBEDTLS_MD_SHA256, hash, 0,
                           buffer, j ) ) != 0 )
        goto exit;

    mbedtls_printf( "OK\n" );

    exit_code = MBEDTLS_EXIT_SUCCESS;

exit:
    mbedtls_pk_free( &pk );

    if( exit_code != MBEDTLS_EXIT_SUCCESS )
        mbedtls_printf("FAIL\n");

    return( exit_code );
}
#endif /* MBEDTLS_BIGNUM_C && MBEDTLS_SHA256_C &&
          MBEDTLS_PK_PARSE_C && MBEDTLS_FS_IO */
