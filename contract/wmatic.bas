/**

*/
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


Function Initialize() Uint64
    01 IF EXISTS("initialized") == 0 THEN GOTO 10
    02 RETURN 1

    10 STORE("_name", "Wrapped ETH")
    20 STORE("_decimals", 8)
    30 STORE("_symbol", "WETH")
    40 STORE("_capped", 2100000000000000)
    50 STORE("_totalSupply", 0)
    60 STORE("owner", SIGNER())
    70 STORE("initialized", 1)
    
    80 SEND_ASSET_TO_ADDRESS(SIGNER(), 10000000000, SCID())

    999 RETURN 0;

End Function

Function TotalSupply() Uint64
    10 RETURN LOAD("_totalSupply");
End Function

Function Capped() Uint64
    10 RETURN LOAD("_capped")
End Function

Function Decimals() Uint64
    10 RETURN LOAD("_decimals")
End Function

Function Symbol() Uint64
    10 RETURN LOAD("_symbol")
End Function

Function Name() Uint64
    10 RETURN LOAD("_name")
End Function

Function Mint(wallet String, amount Uint64) Uint64 
    01 IF SIGNER() == LOAD("owner") THEN GOTO 10
    02 RETURN Error("You are not authorized to use this function")

    10 IF IS_ADDRESS_VALID(wallet) == 1 THEN GOTO 30
    20 RETURN Error("Invalid dero address")
    30 IF amount > 0 THEN GOTO 50
    40 RETURN Error("Amount must be greater than 0")
    50 IF capped() < 1 THEN GOTO 80
    60 IF totalSupply() + amount <= capped() THEN GOTO 80
    70 RETURN Error("Full supply is in circulation")
    80 SEND_ASSET_TO_ADDRESS(wallet, amount, SCID())

    999 RETURN 0
End Function

// owner is an string form of address
Function TransferOwnership(newowner String) Uint64
    10  IF LOAD("owner") == SIGNER() THEN GOTO 30
    20  RETURN 1
    30  STORE("tmpowner",ADDRESS_RAW(newowner))
    
    999  RETURN 0
End Function

// Until the new owner claims ownership, existing owner remains owner
Function ClaimOwnership() Uint64
    10  IF LOAD("tmpowner") == SIGNER() THEN GOTO 30
    20  RETURN 1
    30  STORE("owner",SIGNER()) // ownership claim successful
    
    999  RETURN 0
End Function

// if signer is owner, provide him rights to update code anytime
// make sure update is always available to SC
Function UpdateCode( code String) Uint64
    10  IF LOAD("owner") == SIGNER() THEN GOTO 30
    20  RETURN 1
    30  UPDATE_SC_CODE(code)
    
    999  RETURN 0
End Function