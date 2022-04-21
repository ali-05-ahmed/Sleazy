const { expect } = require("chai");
const { ethers } = require("hardhat");

async function mineNBlocks(n) {
  for (let index = 0; index < n; index++) {
    await ethers.provider.send('evm_mine');
  }
}

describe("Staking",  function ()  {

  
  let Staking
  let staking
  let NFT
  let nFT
  let Brew
  let brew



//   let [_,per1,per2,per3] = [1,1,1,1]

  it("Should deploy Staking smart contract", async function () {

    [_,per1,per2,per3] = await ethers.getSigners()

    NFT = await ethers.getContractFactory("NFT")
    nFT =await NFT.deploy(per1.address)
    await nFT.deployed()

    

    Staking = await ethers.getContractFactory("Staking")
    staking =await Staking.deploy(nFT.address)
    await staking.deployed()  

    Brew = await ethers.getContractFactory("Brew")
    brew =await Brew.deploy(staking.address)
    await brew.deployed() 

    await staking.setTokenAddress(brew.address)
     
  });
 
  it("Should mint NFT", async function () {
    
    let _value = await ethers.utils.parseEther('1')
    await nFT.createToken(_.address,1)
   
  });

  it("Should Stake NFT", async function () {
    
    let _value = await ethers.utils.parseEther('1')
    let  tx = await nFT["safeTransferFrom(address,address,uint256)"](_.address, staking.address, 0);
    await tx.wait()
    let check = await staking.exist(0)
    console.log(check)
    mineNBlocks(6653)
   
  });

  it("My Staked NFTs", async function () {

    let check = await staking.fetchMyNFTs()
   // console.log(check)

   

    let calculateRewards = await staking.calculateRewards(1)
    console.log(calculateRewards)

    //console.log(await ethers.provider._getBlock)
   
  });
  
  

});
