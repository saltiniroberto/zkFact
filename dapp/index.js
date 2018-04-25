//var web3 = require('web3')

var contractInstance
var web3js

function startApp() {
}

function submitProof() {
  abi = JSON.parse('[ { "anonymous": false, "inputs": [ { "indexed": false, "name": "", "type": "string" } ], "name": "PaidOut", "type": "event" }, { "inputs": [ { "name": "_fact_value", "type": "uint256" } ], "payable": true, "stateMutability": "payable", "type": "constructor" }, { "constant": false, "inputs": [ { "name": "a", "type": "uint256[2]" }, { "name": "a_p", "type": "uint256[2]" }, { "name": "b", "type": "uint256[2][2]" }, { "name": "b_p", "type": "uint256[2]" }, { "name": "c", "type": "uint256[2]" }, { "name": "c_p", "type": "uint256[2]" }, { "name": "h", "type": "uint256[2]" }, { "name": "k", "type": "uint256[2]" }, { "name": "input", "type": "uint256[1]" } ], "name": "verifyTx", "outputs": [ { "name": "r", "type": "bool" } ], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [ { "name": "a", "type": "uint256[2]" }, { "name": "a_p", "type": "uint256[2]" }, { "name": "b1", "type": "uint256[2]" }, { "name": "b2", "type": "uint256[2]" }, { "name": "b_p", "type": "uint256[2]" }, { "name": "c", "type": "uint256[2]" }, { "name": "c_p", "type": "uint256[2]" }, { "name": "h", "type": "uint256[2]" }, { "name": "k", "type": "uint256[2]" } ], "name": "withdraw", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "anonymous": false, "inputs": [ { "indexed": false, "name": "", "type": "string" } ], "name": "WrongAnswer", "type": "event" }, { "anonymous": false, "inputs": [ { "indexed": false, "name": "", "type": "string" } ], "name": "Verified", "type": "event" } ]')
  zkFact = web3js.eth.contract(abi);
  contractInstance = zkFact.at($("#address").val());

  proof = $("#zokratesproof").val();
  lines = proof.split('\n');

  var a,a_p,b,b1,b2,b_p,c,c_p,h,k

  lines.forEach((line) => {
    words = line.split(/\W+/);

    switch (words[0]) {
      case 'A':
          a = [web3js.toBigNumber(words[1]),web3js.toBigNumber(words[2])]
        break;

      case 'A_p':
          a_p = [web3js.toBigNumber(words[1]),web3js.toBigNumber(words[2])]
          break;


      case 'B':
          // Used with old ABI  b = [[web3js.toBigNumber(words[1]),web3js.toBigNumber(words[2])],[web3js.toBigNumber(words[3]),web3js.toBigNumber(words[4])]]
          b1 = [web3js.toBigNumber(words[1]),web3js.toBigNumber(words[2])]
          b2 = [web3js.toBigNumber(words[3]),web3js.toBigNumber(words[4])]
          break;

      case 'B_p':
          b_p = [web3js.toBigNumber(words[1]),web3js.toBigNumber(words[2])]
          break;

      case 'C':
          c = [web3js.toBigNumber(words[1]),web3js.toBigNumber(words[2])]
          break;

      case 'C_p':
          c_p = [web3js.toBigNumber(words[1]),web3js.toBigNumber(words[2])]
          break;

      case 'H':
          h = [web3js.toBigNumber(words[1]),web3js.toBigNumber(words[2])]
          break;

      case 'K':
          k = [web3js.toBigNumber(words[1]),web3js.toBigNumber(words[2])]
          break;
    }

  })



  contractInstance.withdraw.sendTransaction(a, a_p, b1, b2, b_p, c, c_p, h, k, function (err, transactionHash) {
    if (!err)
      console.log(transactionHash); // "0x7f9fade1c0d57a7af66ab4ead7c2eb7b11a91385"
  }
  );
}

$(document).ready(function () {
});


window.addEventListener('load', function () {

  var web3 = window.web3
  // Checking if Web3 has been injected by the browser (Mist/MetaMask)
  if (typeof web3 !== 'undefined') {
    // Use Mist/MetaMask's provider
    web3js = new Web3(web3.currentProvider);
  } else {
    console.log('No web3? You should consider trying MetaMask!')
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    web3js = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
  }

  console.log(web3js.version)
  // Now you can start your app & access web3 freely:
  startApp()

})

