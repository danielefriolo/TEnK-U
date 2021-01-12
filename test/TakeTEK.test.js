const TakeTEK      = artifacts.require("TakeTEK");
//const assertRevert   = require('../helpers/assertRevert');
//const bigNumber      = require('bignumber.js');
const crypto         = require('crypto');
const ecPem          = require('ec-pem');
const ethereumJSUtil = require('ethereumjs-util');
contract('TakeTEK', async(accounts) => {

  it("Correct deposit", async() => {
     let instance = await TakeTEK.deployed();
      let dep = await instance.depositBuyer.call({from: accounts[0], value: 30000});
      let ans = await instance.getPrize()
      console.log(ans);
        assert.equal(
          ans.valueOf(),
          30000,
          "deposit not correct"
        );

  });


  it("Correct promise2", async () => {
    let instance = await TakeTEK.deployed();
        await  instance.promiseUpload.call({from: accounts[1], value: 30000})
      let ans = instance.getCollateral.call();
        assert.equal(
          ans.valueOf(),
          60000,
          "Promise incorrect"
        );
  });

  /*
  it("Correct deposit", () => {
    TakeTEK.deployed()
      .then(instance => instance.depositBuyer.call({from: accounts[0], value: 30000})
      .then(dep => instance.getPrize()
      .then (ans =>

      {
        assert.equal(
          ans.valueOf(),
          30000,
          "Value correctly deposited"
        );

      })));
  });

  it("Correct promise", () => {
    let meta;
    TakeTEK.deployed()
      .then(instance => {
        meta = instance;
        return  meta.promiseUpload.call({from: accounts[1], value: 30000})
      })
      .then(prom => { return meta.getCollateral.call() })
      .then (ans =>

      {
        assert.equal(
          ans.valueOf(),
          60000,
          "Promise incorrect"
        );

      });
  });




    it("Send correct TEKs", () => {
    var exportFile = "0x454b204578706f7274207631202020200900a6455f000000001120c2455f000000001a0263682001280132310a1163682e61646d696e2e6261672e647033741a02763122033232382a13312e322e3834302e31303034352e342e332e323a1c0a109e170a4ead6589e6b621b32e1d28b453100018c0cca201209001";
    var sigFile = "0x0a80010a310a1163682e61646d696e2e6261672e647033741a02763122033232382a13312e322e3834302e31303034352e342e332e321001180122473045022061bb594ba5413a4d475818726c61f5f6754ccf9ddc2636b826ab0cd004b82002022100cbed2773953259a2ae2f9b55a8174c22c518ddf2e909e46f59b7365f9e71d649";

    TakeTEK.deployed()
      .then(instance => instance.sendSignedTEKListSC.call(exportFile,sigFile,{from: accounts[0]})
      .then(sig => instance.isSigVerified()
      .then (ans =>

      {
        assert.equal(
          ans,
          true,
          "Signature Correctly verified"
        );

      })));
  });

*/


  });

