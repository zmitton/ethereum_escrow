contract token { 
  mapping (address => uint) public coinBalanceOf;
  mapping (address => uint) public heldBalanceOf;

  event CoinTransfer(address sender, address receiver, uint amount);

  function token() {
    coinBalanceOf[msg.sender] = 20000;
  }

  function sendCoin(address receiver, uint amount) returns(bool sufficient) {
    if (coinBalanceOf[msg.sender] < amount) return false;
    coinBalanceOf[msg.sender] -= amount;
    coinBalanceOf[receiver] += amount;
    CoinTransfer(msg.sender, receiver, amount);
    return true;
  }

  function holdCoin(address receiver, uint amount) returns(bool sufficient) {
    if (coinBalanceOf[msg.sender] < amount) return false;
    coinBalanceOf[msg.sender] -= amount;
    heldBalanceOf[receiver] += amount;
    CoinTransfer(msg.sender, receiver, amount);
    return true;
  }

  function releaseCoin() returns(bool sufficient) {
    coinBalanceOf[msg.sender] += heldBalanceOf[msg.sender];
    heldBalanceOf[msg.sender] = 0;
    return true;
  }
}


var source = 'contract token { mapping (address => uint) public coinBalanceOf; mapping (address => uint) public heldBalanceOf; event CoinTransfer(address sender, address receiver, uint amount); function token() { coinBalanceOf[msg.sender] = 20000; } function sendCoin(address receiver, uint amount) returns(bool sufficient) { if (coinBalanceOf[msg.sender] < amount) return false; coinBalanceOf[msg.sender] -= amount; coinBalanceOf[receiver] += amount; CoinTransfer(msg.sender, receiver, amount); return true; } function holdCoin(address receiver, uint amount) returns(bool sufficient) { if (coinBalanceOf[msg.sender] < amount) return false; coinBalanceOf[msg.sender] -= amount; heldBalanceOf[receiver] += amount; CoinTransfer(msg.sender, receiver, amount); return true; } function releaseCoin() returns(bool sufficient) { coinBalanceOf[msg.sender] += heldBalanceOf[msg.sender]; heldBalanceOf[msg.sender] = 0; return true; } }'


var compiled = eth.compile.solidity(source)


var contract = web3.eth.contract(compiled.token.info.abiDefinition);


var token = contract.new(
  {
    from:web3.eth.accounts[0], 
    data:compiled.token.code, 
    gas: 1000000
  }, function(e, contract){
    if(!e) {
      if(!contract.address) {
        console.log("Contract transaction send: TransactionHash: " + contract.transactionHash + " waiting to be mined...");
      } else {
        console.log("Contract mined! Address: " + contract.address);
        console.log(contract);
      }

    }
})


address:  0x25c5aa0d63cfc10a32ce5d593ff2a0d0526e9e41

WORKS!!!!
