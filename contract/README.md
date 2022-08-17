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
    - 