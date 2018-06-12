/* Copyright 2018 by Multy.io
 * Licensed under Multy.io license.
 *
 * See LICENSE for details
 */

#ifndef MULTY_CORE_BLOCKCHAIN_H
#define MULTY_CORE_BLOCKCHAIN_H

#include "api.h"

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

struct Error;

// See: https://github.com/satoshilabs/slips/blob/master/slip-0044.md
// TODO: rename Blockchain to BlockchainType
enum Blockchain
{
    BLOCKCHAIN_BITCOIN =            0x00,
    BLOCKCHAIN_LITECOIN =           0x02,
    BLOCKCHAIN_DASH =               0x05,
    BLOCKCHAIN_ETHEREUM =           0x3c,
    BLOCKCHAIN_ETHEREUM_CLASSIC =   0x3d,
    BLOCKCHAIN_STEEM =              0x87,
    BLOCKCHAIN_BITCOIN_CASH =       0x99,
    BLOCKCHAIN_GOLOS =              0x060105,
    
    //not available in bip44
    BLOCKCHAIN_BITCOIN_LIGHTNING =  0x9900,
    BLOCKCHAIN_BITSHARES =          0x9902,
    BLOCKCHAIN_ERC20 =              0x9903
};

// TODO: rename BlockchainType to BlockchainSpec
struct BlockchainType
{
    enum Blockchain blockchain;
    size_t net_type; // blockchain-specific net type, 0 for MAINNET.
};

/** Validate an address for given blockchain
 *  @param address - address
 *  @param blockchain_type - Blockchain to use address for.
 *  @return null ptr if address is valid, Error if it is not.
 */
MULTY_CORE_API struct Error* validate_address(
        struct BlockchainType blockchain,
        const char* address);

#ifdef __cplusplus
} // extern "C"
#endif

#endif // MULTY_CORE_BLOCKCHAIN_H
