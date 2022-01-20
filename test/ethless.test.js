const { expect } = require('chai');
const { ethers } = require('hardhat');
const { ContractFactory } = require('@ethersproject/contracts');
var Web3 = require('web3');
var web3 = new Web3(Web3.givenProvider);


const amount = 1000;
let deployer;
const SigDomainTransfer = 3;
const fee = 1;
const sendAmount = 50;
const privateKey = "ac407fa511df5105b17881936d07c9be43ed22fc5b80d676383fdaf31ffedb5e";  
let sender = new ethers.Wallet(privateKey,ethers.provider);

async function signTransfer(domain, chainId, contractAddress, sourceAddress, sourcePrivateKey, recipientAddress, amount, fee, nonce ) {
    var hash = web3.utils.soliditySha3(
        { t: 'uint8', v: domain },
        { t: 'uint256', v: chainId },
        { t: 'address', v: contractAddress },
        { t: 'address', v: sourceAddress },
        { t: 'address', v: recipientAddress },
        { t: 'uint256', v: amount },
        { t: 'uint256', v: fee },
        { t: 'uint256', v: nonce }          
        );

    var obj = web3.eth.accounts.sign(hash , sourcePrivateKey);
    var signature = obj.signature;
    return signature;
}
describe("Token", () => {

  beforeEach(async () => {
    [deployer, receiver] = await ethers.getSigners();
    const tokenFactory = await ethers.getContractFactory("TestTokenMock");
    tokenContract = new ContractFactory(tokenFactory.interface, tokenFactory.bytecode, deployer);
    
    token = await tokenContract.connect(deployer).deploy();
    await token.deployed();

    expect(await token.totalSupply()).to.eq(0);
    
    input = await token.connect(deployer).mint(sender.address, amount);
    input = await token.connect(deployer).mint(deployer.address, amount);
    await ethers.provider.waitForTransaction(input.hash);
    expect(await token.balanceOf(sender.address)).to.eq(amount);;
  });

  it('deployer can trigger EthlessTransfer', async ()=>{

        var nonce = Date.now();
        var chainId = ethers.provider._network.chainId;
        
        var signature = await signTransfer(SigDomainTransfer,chainId,token.address, sender.address, privateKey, receiver.address, sendAmount - fee, fee, nonce);       
        var input = await token.connect(deployer).ETHlessTransfer(sender.address, receiver.address, sendAmount - fee, fee, nonce, signature);
        await ethers.provider.waitForTransaction(input.hash);
        expect(parseInt(await token.balanceOf(receiver.address))).to.equal(sendAmount - fee);
  });
  it('non-deployer cannot trigger EthlessTransfer', async ()=>{

        var nonce = Date.now();
        var chainId = ethers.provider._network.chainId;
        
        var signature = await signTransfer(SigDomainTransfer,chainId,token.address, sender.address, privateKey, receiver.address, sendAmount - fee, fee, nonce);       
        var input = await token.connect(receiver).ETHlessTransfer(sender.address, receiver.address, sendAmount - fee, fee, nonce, signature);
        var res = await ethers.provider.waitForTransaction(input.hash);
        expect(res.status).to.eq(0);
        expect(parseInt(await token.balanceOf(receiver.address))).to.equal(0);
  });
});
