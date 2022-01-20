// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

library GluwacoinModels {   
    /**
     * @dev Enum of the different domains of signature.
     */
    enum SigDomain {
        /*0*/
        Nothing,
        /*1*/
        Burn,
        /*2*/
        Mint,
        /*3*/
        Transfer,
        /*4*/
        Reserve
    }
}
