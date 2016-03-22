contract escrow { 
  mapping (int => Holding) holdings;
  int numHoldings;

  struct Holding {
    uint amount;
    address receiver;
    bool unSpent;
    int8 numSigners;
    mapping (int => Signer) signers;
  }

  struct Signer {
    address userAddress;
    bool hasSigned;
  }

  function escrow() {
  }

  function holdCoin(address receiver, address thirdPartySigner) returns(int id) {
    if (coinBalanceOf[msg.sender] < msg.value) return 0;
    coinBalanceOf[msg.sender] -= msg.value;
    numHoldings++;
    holdings[numHoldings] = Holding(msg.value, receiver, true, 2);
    holdings[numHoldings].signers[1] = Signer(msg.sender, false);
    holdings[numHoldings].signers[2] = Signer(thirdPartySigner, false);
    
    return numHoldings;
  }

  function signRelease(int holdingID) returns(bool released) {
    for(int i = 0; i <= holdings[holdingID].numSigners; i++){ 
        if(holdings[holdingID].signers[i].userAddress == msg.sender){
            holdings[holdingID].signers[i].hasSigned = true;
        }
    }
    bool releasable = true;
    for(int j = 1; j <= holdings[holdingID].numSigners; j++){
      if(!holdings[holdingID].signers[j].hasSigned) releasable = false;
    }
    if(releasable){
      coinBalanceOf[holdings[holdingID].receiver] += holdings[holdingID].amount;
      holdings[holdingID].amount = 0;
      holdings[holdingID].unSpent = false;
    }
    return true;
  }
}


var source = 'contract escrow { mapping (address => uint) public coinBalanceOf; mapping (int => Holding) holdings; int numHoldings; event CoinTransfer(address sender, address receiver, uint amount); struct Holding { uint amount; address receiver; bool unSpent; int8 numSigners; mapping (int => Signer) signers; } struct Signer { address userAddress; bool hasSigned; } function escrow() { coinBalanceOf[msg.sender] = 20000; } function sendCoin(address receiver, uint amount) returns(bool sufficient) { if (coinBalanceOf[msg.sender] < amount) return false; coinBalanceOf[msg.sender] -= amount; coinBalanceOf[receiver] += amount; CoinTransfer(msg.sender, receiver, amount); return true; } function holdCoin(address receiver, address thirdPartySigner, uint amount) returns(int id) { if (coinBalanceOf[msg.sender] < amount) return 0; coinBalanceOf[msg.sender] -= amount; numHoldings++; holdings[numHoldings] = Holding(amount, receiver, true, 2); holdings[numHoldings].signers[1] = Signer(msg.sender, false); holdings[numHoldings].signers[2] = Signer(thirdPartySigner, false); return numHoldings; } function signRelease(int holdingID) returns(bool released) { for(int i = 0; i <= holdings[holdingID].numSigners; i++){ if(holdings[holdingID].signers[i].userAddress == msg.sender){ holdings[holdingID].signers[i].hasSigned = true; } } bool releasable = true; for(int j = 0; j < holdings[holdingID].numSigners; j++){ if(!holdings[holdingID].signers[j].hasSigned) releasable = false; } if(releasable){ coinBalanceOf[holdings[holdingID].receiver] += holdings[holdingID].amount; holdings[holdingID].amount = 0; holdings[holdingID].unSpent = false; } return true; } }'

var compiled = eth.compile.solidity(source)

var contract = web3.eth.contract(compiled.escrow.info.abiDefinition);


