/**
    on-chain DEX for dero
*/
Function Initialize() Uint64
    01 IF EXISTS("initialized") == 0 THEN GOTO 10
    02 RETURN 1

    10 STORE("name", "Dero Dex")
    20 STORE("owner", SIGNER())
    30 STORE("pair_count", 0)
    40 STORE("initialized", 1)
    50 STORE("fee", 1000)

    999 RETURN 0;

End Function

// Thanks to @plspro
Function Error(msg String) Uint64
    
    01 DIM txid as String
	02 LET txid = TXID()

	10  PRINTF "  +-----[ ERROR ]-----+  " 
	20  PRINTF "  |  DERO ERC20       |  " 
	30  PRINTF "  |                   |  " 
	40  PRINTF "  | %s" error_message
	50  PRINTF "  |                   |  " 
	60  PRINTF "  +-----[ ERROR ]-----+  " 
	70  PRINTF "  + TXID: %s" txid
	80  PRINTF "  +-------------------+  " 

    999 RETURN 1
End Function

Function GetLiquidity (baseAsset String, qouteAsset String) Uint64
    10 Dim pair as String
    20 LET pair = baseAsset+"_"+qouteAsset
    30 IF EXISTS(pair) == 1 THEN GOTO 50
    40 RETURN Error("Pair not listed")

    50 PRINTF "liquidity: %d" LOAD(baseAsset+"_"+qouteAsset+"_liquidity")

    999 RETURN 0
End Function

Function GetEstimatedToken( inputAsset String, inputAmount Uint64, inputReserve Uint64, outputReserve Uint64) Uint64
    01 DIM inputValueFee , inputValueWithoutFee, numerator, denomenator as Uint64
    10 LET inputValueFee = inputAmount * LOAD("fee") / 100000
    20 LET inputValueWithoutFee = inputAmount - inputValueFee
    30 LET numerator = inputValueWithoutFee * outputReserve
    40 LET denomenator = inputReserve + inputValueWithoutFee
    50 IF EXISTS("asset_"+inputAsset+"_fees") == 0 THEN GOTO 70
    60 DIM collectedFees as Uint64 
    62 LET collectedFees = LOAD("asset_"+inputAsset+"_fees")
    64 LET inputValueFee = collectedFees + inputValueFee
    70 STORE("asset_"+inputAsset+"_fees", inputValueFee )

    999 RETURN numerator / denomenator
End Function

// swap one token for another
Function Swap(fromAsset String, toAsset String) Uint64
    01 DIM pair, pair_reverse,fromAssetString ,toAssetString  as String
    02 DIM pair_count, toAssetReserve, fromAssetReserve,tokensBought as Uint64
    04 LET fromAssetString = HEX(fromAsset)
    05 LET toAssetString = HEX(toAsset)
    10 LET pair = fromAssetString +"_"+ toAssetString
    11 LET pair_reverse = toAssetString +"_"+ fromAssetString
    12 LET toAssetReserve = LOAD(pair+"_qouteReserve")
    13 LET fromAssetReserve = LOAD(pair+"_baseReserve")
    20 IF EXISTS(pair) == 1 THEN GOTO 40
    21 IF EXISTS(pair_reverse) == 1 THEN GOTO 30
    30 LET pair = pair_reverse
    32 LET toAssetReserve = LOAD(pair+"_baseReserve")
    33 LET fromAssetReserve = LOAD(pair+"_qouteReserve")

    40 LET tokensBought = GetEstimatedToken(fromAssetString, AssetValue(fromAsset), fromAssetReserve, toAssetReserve)
    50 IF toAssetReserve > tokensBought THEN GOTO 70
    60 RETURN Error("Insufficient: " +  ITOA(tokensBought) + "is more than available reserve")
    70 SEND_ASSET_TO_ADDRESS(SIGNER(), tokensBought, toAsset)

    999 RETURN 0
End Function

// add token pair liquidity
Function AddLiquidity(baseAsset String, qouteAsset String) Uint64
    
    01 DIM pair, pair_reverse, baseAssetString, qouteAssetString as String
    02 DIM pair_count as Uint64
    03 LET pair_count = LOAD("pair_count")
    04 LET baseAssetString = HEX(baseAsset)
    05 LET qouteAssetString = HEX(qouteAsset)
    10 LET pair = baseAssetString +"_"+ qouteAssetString
    11 LET pair_reverse = qouteAssetString+"_"+ baseAssetString
    20 IF EXISTS(pair) == 1 THEN GOTO 80
    21 IF EXISTS(pair_reverse) == 1 THEN GOTO 75
    30 STORE(pair, 1)
    40 STORE(pair+"_baseReserve", ASSETVALUE(baseAsset))
    50 STORE(pair+"_qouteReserve", AssetValue(qouteAsset))
    55 STORE("pair_base_"+ pair_count, baseAsset)
    56 STORE("pair_qoute_"+ pair_count, qouteAsset)
    60 STORE(pair+"_liquidity", AssetValue(baseAsset))
    65 STORE("pair_count", pair_count + 1)
    70 SEND_ASSET_TO_ADDRESS(SIGNER(), AssetValue(baseAsset), SCID())
    73 RETURN 0
    74 DIM cacheAsset as String
    75 LET cacheAsset = qouteAsset
    76 LET qouteAsset = baseAsset
    77 LET baseAsset = cacheAsset
    78 LET pair = pair_reverse

    // check to make sure the asset is provided per pair ratio
    80 DIM baseValueReserve , qouteValueReserve as Uint64
    90 LET baseValueReserve = LOAD(pair+"_baseReserve")
    100 LET qouteValueReserve = LOAD(pair+"_qouteReserve")
    // Check if the pairs provided are consistent with the reserve ratio
    110 IF AssetValue(baseAsset) >= (baseValueReserve * AssetValue(qouteAsset) / qouteValueReserve) THEN GOTO 130
    120 RETURN Error("Amount of tokens sent is less than the minimum tokens required")
    130 STORE(pair+"_baseReserve", AssetValue(baseAsset) + baseValueReserve)
    140 STORE(pair+"_qouteReserve", AssetValue(qouteAsset) + qouteValueReserve)
    // issue liquidity tokens
    150 DIM signerLiquidity, totalLiquidity as Uint64
    160 LET totalLiquidity = (LOAD(pair+"_liquidity") + AssetValue(baseAsset)) 
    170 LET signerLiquidity = totalLiquidity * AssetValue(baseAsset) / baseValueReserve
    180 STORE(pair+"_liquidity", totalLiquidity)
    190 SEND_ASSET_TO_ADDRESS(SIGNER(), signerLiquidity, SCID())
    

    999 RETURN 0
End Function

// remove token pair liquidity
Function RemoveLiquidity(baseAsset String, qouteAsset String) Uint64
    01 DIM pair,pair_reverse,baseAssetString, qouteAssetString as String
    02 LET baseAssetString = HEX(baseAsset)
    03 LET qouteAssetString = HEX(qouteAsset)
    10 LET pair = baseAssetString +"_"+ qouteAssetString
    15 LET pair_reverse = qouteAssetString+"_"+ baseAssetString
    20 IF EXISTS(pair) == 1 THEN GOTO 40
    25 IF EXISTS(pair_reverse) == 1 THEN GOTO 32
    30 RETURN Error("Unlisted pair")
    32 DIM cacheAsset as String
    34 LET cacheAsset = qouteAsset
    35 LET qouteAsset = baseAsset
    36 LET baseAsset = cacheAsset
    37 LET pair = pair_reverse

    40 DIM liquidity, totalLiquidity as Uint64
    50 LET liquidity = AssetValue(SCID())
    60 IF liquidity > 0 THEN GOTO 80
    70 RETURN Error("Liquidity tokens should be greater than zero")
    80 LET totalLiquidity = LOAD(pair+"_liquidity")
    90 DIM baseValue, qouteValue, baseReserve, qouteReserve as Uint64
    92 LET baseReserve = LOAD(pair+"_baseReserve")
    94 LET qouteReserve = LOAD(pair+"_qouteReserve")
    100 LET baseValue = baseReserve * liquidity / totalLiquidity
    110 LET qouteValue = qouteReserve * baseValue / baseReserve

    // handle bookkeeping
    120 STORE(pair+"_liquidity", totalLiquidity - liquidity)
    130 STORE(pair+"_baseReserve", baseReserve - baseValue)
    140 STORE(pair+"_qouteReserve", qouteReserve - qouteValue)

    // send both assets
    160 SEND_ASSET_TO_ADDRESS(SIGNER(), baseValue, baseAsset)
    170 SEND_ASSET_TO_ADDRESS(SIGNER(), qouteValue, qouteAsset)

    999 RETURN 0
End Function


// update swap fee 1000 = 1%
Function UpdateSwapFee(amount Uint64) Uint64 
    10 IF SIGNER() == LOAD("owner") THEN GOTO 30
    20 RETURN Error("You not authorized")
    30 STORE("fee", amount)

    999 RETURN 0
End Function

Function WithdrawAssetFees(asset String) Uint64
    10 IF SIGNER() == LOAD("owner") THEN GOTO 15
    11 RETURN Error("You are not authorized")
    15 DIM assetString as String
    16 LEt assetString = HEX(asset) 
    17 IF EXISTS("asset_"+assetString+"_fees") == 1 THEN GOTO 20
    18 RETURN Error("Unknow asset fee")
    20 DIM fees as Uint64 
    30 LET fees = LOAD("asset_"+assetString+"_fees")
    40 STORE("asset_"+assetString+"_fees", 0)
    50 SEND_ASSET_TO_ADDRESS(SIGNER(), fees, asset)

    999 RETURN 0
End Function
