const { expect } = require("chai");
const { ethers } = require("hardhat");

async function mineNBlocks(n) {
  for (let index = 0; index < n; index++) {
    await ethers.provider.send('evm_mine');
  }
}

describe("Brew",  function ()  {

  
  let Brew
  let brew
  let NFTCrowdsale
  let nFTCrowdsale
  let Auction
  let auction



//   let [_,per1,per2,per3] = [1,1,1,1]

  it("Should deploy Brew smart contract", async function () {

    [_,per1,per2,per3] = await ethers.getSigners()

    Brew = await ethers.getContractFactory("Brew")
    brew =await Brew.deploy(per1.address)
    await brew.deployed()  
     
  });
 
  it("Should mint", async function () {
    
    let _value = await ethers.utils.parseEther('1')
    await brew.connect(per1).mint(_.address,_value)
   
  });
  
  

});
