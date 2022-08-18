## Onchain Dero DEX
This repo is a simple implementation of an onchain DEX on Dero (dex.bas) and a number wrapped tokens (w[TokenName].bas)

### Features (dex.bas)
    - AddLiquidity(baseAsset String, qouteAsset String) Uint64
    - RemoveLiquidity(baseAsset String, qouteAsset String) Uint64
    - Swap(fromAsset String, toAsset String) Uint64
    - UpdateSwapFee(amount Uint64) Uint64 // only owner
    - WithdrawAssetFees(asset String) Uint64 // only owner

### Installation and setup
    1. Download and setup dero. Follow [this instruction](https://git.dero.io/DeroProject/derosuite_stargate)
    2. Install wallet. Follow [this instruction](https://docs.dero.io/rtd_pages/stargate_wallet.html?highlight=install).
    You can use the simulator for testing. It is much faster
    3. Install all smart contracts (*.bas)


### RPC calls 

#### Setup RPC calls
    - Initialize wrapped tokens

#### dex rpc calls
- Add Liquidity
    
        ```
        {
            "jsonrpc": "2.0",
            "id": "1",
            "method": "transfer",
            "params": {
                "scid":"dex-scid",
                "ringsize":2,
                "sc_rpc":[
                    {
                        "name":"entrypoint",
                        "datatype":"S","value":
                        "AddLiquidity"
                    },
                    {
                        "name":"baseAsset",
                        "datatype":"H",
                        "value":"dero-wrapped-token-1-scid"
                    },
                    {
                        "name":"qouteAsset",
                        "datatype":"H",
                        "value":"dero-wrapped-token-2-scid"
                    }
                ],
                "transfers": [{
                        "scid": "dero-wrapped-token-1-scid",
                        "burn": amount-to-send-to-dex
                },
                {
                        "scid": "dero-wrapped-token-2-scid",
                        "burn": amount-to-send-to-dex
                }]
            }
        }

        ```

    Example used during test. Note that all contracts must be deployed on the dero network.

        ```
        {
            "jsonrpc": "2.0",
            "id": "1",
            "method": "transfer",
            "params": {
                "scid":"9f9770c3f15b28bc8b62718fb219b96b9ff50843d33b84b65b355fe8daae24ec",
                "ringsize":2,
                "sc_rpc":[
                    {
                        "name":"entrypoint",
                        "datatype":"S",
                        "value":"AddLiquidity"
                    },
                    {
                        "name":"baseAsset",
                        "datatype":"H",
                        "value":"d5cb7dcb6dfa70310053bb0ddebca65494471771d12ff133711f29792d17acae"
                    },
                    {
                        "name":"qouteAsset",
                        "datatype":"H",
                        "value":"95d78d5fe0158d527dcc8ce31ea8e97aab7f4ef7d7d7b37b55924dbebb31558d"
                    }
                ],
                "transfers": [
                {
                    "scid": "d5cb7dcb6dfa70310053bb0ddebca65494471771d12ff133711f29792d17acae",
                    "burn": 10000000
                },
                {
                    "scid": "95d78d5fe0158d527dcc8ce31ea8e97aab7f4ef7d7d7b37b55924dbebb31558d",
                    "burn": 10000000
                }]
            }
        }

        ```
    
- Remove Liquidity

        ```
            {
                "jsonrpc": "2.0",
                "id": "1",
                "method": "transfer",
                "params": {
                    "scid":"dex-scid",
                    "ringsize":2,
                    "sc_rpc":[
                        {
                            "name":"entrypoint",
                            "datatype":"S",
                            "value":"RemoveLiquidity"
                        },
                        {
                            "name":"baseAsset",
                            "datatype":"H",
                            "value":"dero-wrapped-token-1-scid"
                        },
                        {
                            "name":"qouteAsset",
                            "datatype":"H",
                            "value":"dero-wrapped-token-2-scid"
                        }
                    ],
                    "transfers": [{
                            "scid": "dex-scid",
                            "burn": amount-of-lp-to-convert
                    }]
                }
            }
        ```
    Example: 
    ```
        {
            "jsonrpc": "2.0",
            "id": "1",
            "method": "transfer",
            "params": {
                "scid":"db810c8caf03f5ec01276339b8ae5cb24e5033203119096a4f2dd7095894a6cb",
                "ringsize":2,
                "sc_rpc":[
                    {
                        "name":"entrypoint",
                        "datatype":"S",
                        "value":"RemoveLiquidity"
                    },
                    {
                        "name":"baseAsset",
                        "datatype":"H",
                        "value":"d5cb7dcb6dfa70310053bb0ddebca65494471771d12ff133711f29792d17acae"
                    },
                    {
                        "name":"qouteAsset",
                        "datatype":"H",
                        "value":"95d78d5fe0158d527dcc8ce31ea8e97aab7f4ef7d7d7b37b55924dbebb31558d"
                    }
                ],
                "transfers": [{
                    "scid": "db810c8caf03f5ec01276339b8ae5cb24e5033203119096a4f2dd7095894a6cb",
                    "burn": 1000
                }]
            }
        }
    ```
- Swap

    ```
        {
            "jsonrpc": "2.0",
            "id": "1",
            "method": "transfer",
            "params": {
                "scid":"dex-scid",
                "ringsize":2,
                "sc_rpc":[
                    {
                        "name":"entrypoint",
                        "datatype":"S",
                        "value":"Swap"
                    },
                    {
                        "name":"fromAsset",
                        "datatype":"H",
                        "value":"source-dero-wrapped-token-scid"
                    },
                    {
                        "name":"toAsset",
                        "datatype":"H",
                        "value":"target-dero-wrapped-token-scid"
                    }
                ],
                "transfers": [{
                    "scid": "dero-scid",
                    "burn": amount-to-swap
                }]
            }
        }
    ```
    Example: 
    
    ```
        {
            "jsonrpc": "2.0",
            "id": "1",
            "method": "transfer",
            "params": {
                "scid":"9f9770c3f15b28bc8b62718fb219b96b9ff50843d33b84b65b355fe8daae24ec",
                "ringsize":2,
                "sc_rpc":[
                    {
                        "name":"entrypoint",
                        "datatype":"S",
                        "value":"Swap"
                    },
                    {
                        "name":"fromAsset",
                        "datatype":"H",
                        "value":"d5cb7dcb6dfa70310053bb0ddebca65494471771d12ff133711f29792d17acae"
                    },
                    {
                        "name":"toAsset",
                        "datatype":"H",
                        "value":"95d78d5fe0158d527dcc8ce31ea8e97aab7f4ef7d7d7b37b55924dbebb31558d"
                    }
                ],
                "transfers": [{
                        "scid": "d5cb7dcb6dfa70310053bb0ddebca65494471771d12ff133711f29792d17acae",
                        "burn": 1000000
                }]
            }
        }
    ```

- Withdraw Asset Fees
    ```
        {
            "jsonrpc": "2.0",
            "id": "1",
            "method": "transfer",
            "params": {
                "scid":"dero-dex",
                "ringsize":2,
                "sc_rpc":[
                    {
                        "name":"entrypoint",
                        "datatype":"S",
                        "value":"WithdrawAssetFees"
                    },
                    {
                        "name":"asset",
                        "datatype":"H",
                        "value":"fee-for-dero-wrapped-token-scid"
                    }
                ]
            }
        }
    ```

    Example:
    ```
        {
            "jsonrpc": "2.0",
            "id": "1",
            "method": "transfer",
            "params": {
                "scid":"9f9770c3f15b28bc8b62718fb219b96b9ff50843d33b84b65b355fe8daae24ec",
                "ringsize":2,
                "sc_rpc":[
                    {
                        "name":"entrypoint",
                        "datatype":"S",
                        "value":"WithdrawAssetFees"
                    },
                    {
                        "name":"asset",
                        "datatype":"H",
                        "value":"d5cb7dcb6dfa70310053bb0ddebca65494471771d12ff133711f29792d17acae"
                    }
                ]
            }
        }
    ```

- Read Dex Variables
    ```
        {
            "jsonrpc": "2.0",
            "id": "1",
            "method": "DERO.GetSC",
            "params": {
                    "scid": "dex-scid",
                    "variables": true
            }
        }
    ```
    
    Example
    ```
        {
            "jsonrpc": "2.0",
            "id": "1",
            "method": "DERO.GetSC",
            "params": {
                "scid": "9f9770c3f15b28bc8b62718fb219b96b9ff50843d33b84b65b355fe8daae24ec",
                "variables": true
            }
        }
    ```

