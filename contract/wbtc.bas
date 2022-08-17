/**
    A Dero wrapped btc smart contract.
    It implements ERC20 standard 
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
    01 IF LOAD("initialized") != 1 THEN GOTO 10
    02 RETURN 1

    10 STORE("_name", "Wrapped BTC")
    20 STORE("_decimals", 8)
    30 STORE("_symbol", "WBTC")
    40 STORE("_capped", 2100000000000000)
    50 STORE("_totalSupply", 0)
    60 STORE("owner", SIGNER())
    70 STORE("initialized", 1)

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

Function BalanceOf(wallet String) Uint64
    10 DIM _wallet as String 
    20 LET _wallet = wallet+"_balance";
    30 IF EXIST(_wallet) == 1 THEN GOTO 999
    40 RETURN 0

    999 RETURN LOAD(_wallet);
End Function

Function Approve(spender String, amount Uint64) Uint64
    //TODO
    01 IF amount > 0 THEN GOTO 03
    02 RETURN Error("Amount must be greater than 0")
    03 IF IS_ADDRESS_VALID(spender) == 1 THEN GOTO 10
    04 RETURN Error("Spender is an invalid dero address")

    10 DIM _allowance as String
    20 LET _allowance = SIGNER()+"_"+spender+"_allowance"

    // Overrides existing allowance
    30 STORE(_allowance, amount)

    999 RETURN 0
End Function

Function Allowance(owner String, spender String) Uint64 
    10 DIM _allowance as String
    20 LET _allowance = owner+"_"+spender+"_allowance"
    30 IF EXIST(_allowance) == 1 THEN GOTO 999
    40 RETURN 0

    999 RETURN LOAD(_allowance)
End Function

Function transferFrom(sender String, receiver String , amount Uint64) Uint64
    01 IF amount > 0 THEN GOTO 10
    02 RETURN Error("Amount must be greater than 0")

    10 IF Allowance(spender, receiver) <= amount THEN GOTO 30
    20 RETURN Error("Allowance is not sufficient")
    30 IF amount <= BalanceOf(sender) THEN GOTO 90
    40 RETURN Error("Sender balance is not sufficient")
    50 STORE(sender+"_balance", BalanceOf(sender) - amount)
    60 STORE(receiver+"_balance", BalanceOf(receiver) + amount)

    999 RETURN 0
End Function 

Function Transfer(receiver String , amount Uint64) Uint64
    01 IF amount > 0 THEN GOTO 03
    02 RETURN Error("Amount must be greater than 0")
    03 IF IS_ADDRESS_VALID(receiver) == 1 THEN GOTO 10
    04 RETURN Error("Invalid receiver address")

    10 IF amount <= BalanceOf(SIGNER()) THEN GOTO 90
    20 RETURN Error("Sender balance is not sufficient")
    30 STORE(SIGNER()+"_balance", BalanceOf(sender) - amount)
    40 STORE(receiver+"_balance", BalanceOf(receiver) + amount)

    999 RETURN 0
End Function 

Function Mint(wallet String, amount Uint64) Uint64 
    01 IF SIGNER() == LOAD("owner") THEN GOTO 10
    02 RETURN Error("You are not authorized to use this function")

    10 IF IS_ADDRESS_VALID(wallet) == 1 THEN GOTO 30
    20 RETURN Error("Invalid dero address")
    30 IF amount > 0 THEN GOTO 50
    40 RETURN Error("Amount must be greater than 0")
    50 IF capped() < 1 THEN GOTO 80
    60 IF TotalSupply() + amount <= capped() THEN GOTO 80
    70 RETURN Error("Full supply is in circulation")
    80 STORE(wallet+"_balance", BalanceOf(wallet) + amount)
    90 STORE(_totalSupply, TotalSupply() + amount)

    999 RETURN 0
End Function

Function Burn(amount Uint64) Uint64
    10 IF amount <= BalanceOf(SIGNER()) THEN GOTO 30
    20 RETURN Error("Insufficient balance")
    30 STORE(SIGNER()+"_balance", BalanceOf(SIGNER) - amount);

    999 RETURN 0
End Function

// This function is used to change owner
// owner is an string form of address
Function TransferOwnership(newowner String) Uint64
    10  IF LOAD("owner") == SIGNER() THEN GOTO 30
    20  RETURN 1
    30  STORE("tmpowner",ADDRESS_RAW(newowner))
    40  RETURN 0
End Function

// Until the new owner claims ownership, existing owner remains owner
Function ClaimOwnership() Uint64
    10  IF LOAD("tmpowner") == SIGNER() THEN GOTO 30
    20  RETURN 1
    30  STORE("owner",SIGNER()) // ownership claim successful
    40  RETURN 0
End Function

// if signer is owner, provide him rights to update code anytime
// make sure update is always available to SC
Function UpdateCode( code String) Uint64
    10  IF LOAD("owner") == SIGNER() THEN GOTO 30
    20  RETURN 1
    30  UPDATE_SC_CODE(code)
    40  RETURN 0
End Function