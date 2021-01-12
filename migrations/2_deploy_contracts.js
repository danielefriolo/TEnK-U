var EllipticCurve = artifacts.require('./libs/EllipticCurve.sol');
var BytesLib = artifacts.require('./libs/BytesLib.sol');
var DateTime = artifacts.require('./libs/DateTime.sol');
var ProtobufLib = artifacts.require('./libs/ProtobufLib.sol');
var Base64 = artifacts.require('./libs/Base64.sol');
var TakeTEK = artifacts.require('./TakeTEK.sol');


var tekPK = ['0x2b693d9d9f20ba8ec93f610b3d05e7524a83ca38c99989a9b7d672d073ec8865','0xc2748dd21662ebdb4e0a37392e213a69355e4fefe6d74718a2634e0d32b1084e'];
 
keys = ["0x9e170a4ead6589e6b621b32e1d28b453"];
    trasmissionRisk = [0];
    rollingStart = [2664000];

module.exports = function(deployer) {
  deployer.deploy(DateTime);
	deployer.deploy(EllipticCurve);
  deployer.deploy(Base64);
      deployer.link(TakeTEK,[DateTime,Base64,EllipticCurve]);
    deployer.deploy(TakeTEK, tekPK[0],tekPK[1],3,300000,keys,rollingStart,trasmissionRisk);

}
