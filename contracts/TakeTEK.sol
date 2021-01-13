pragma solidity ^0.6.0;
import "@lazyledger/protobuf3-solidity-lib/contracts/ProtobufLib.sol";
 import "./libs/Base64.sol";
 import "./libs/DateTime.sol";
 import "./libs/EllipticCurve.sol";
 import "solidity-bytes-utils/contracts/BytesLib.sol";
 
 
contract TakeTEK is EllipticCurve  {
    uint[2] tekPK;
    uint256 prize;
    address payable buyer; 
    address payable seller;
    bool buyerDeposited;
    bool promised;
    bool sigVerified = false;
    uint k;
    uint256 timer;
    uint256 collateral;
    bytes buffer;
    uint constant IMMUNI_EXP_START = 111;
    uint constant SWISSCOVID_EXP_START = 97;
    uint constant IMMUNI_SIG_START = 73;
    uint constant SWISSCOVID_SIG_START = 60;

    bytes16[] keys;
    uint[] rollingStartNumbers;
    uint[] transmissionRiskLevels;
    
    constructor(bytes memory _pkX, bytes memory _pkY, uint _k, uint256 _collateral , bytes16[] memory _keys, uint[] memory _rollingStartNumbers, uint[] memory _transmissionRiskLevels
    ) public {
       tekPK[0] = BytesLib.toUint256(_pkX,0);
       tekPK[1] = BytesLib.toUint256(_pkY,0);
       keys = _keys;
        rollingStartNumbers = _rollingStartNumbers;
        transmissionRiskLevels = _transmissionRiskLevels;
        buyer = msg.sender;
        buyerDeposited = false;
        promised = false;
        k = _k;
        collateral = _collateral;
    }
    function getPrize() public view  returns (uint) {
        return prize;
    }
   function getCollateral() public view  returns (uint) {
        return collateral;
    }
    function isSigVerified() public view  returns (bool) {
        return sigVerified;
    }
    function depositBuyer() public payable {
        require(!buyerDeposited);
        if (msg.sender == buyer) buyerDeposited = true;
        prize = msg.value;
    }
    //The infected seller do a promise of sending the teks online
    function promiseUpload() public payable {
        require(msg.value == collateral);
        require(buyerDeposited);
        require(!promised);
        seller = msg.sender;
        timer = block.timestamp+k;
        promised = true;
    }
    
    //function triggered if the infected didn't send his TEKs or sent incorrect ones.
    function checkTimeout() public {
        require(block.timestamp > timer);
        require(buyerDeposited);
        require(promised);
        require(!sigVerified);
        buyer.transfer(prize);
        buyer.transfer(collateral);
    }
     //auxiliary functions
    function checkKey(bytes16 _keyData, uint _rollingStartNumber, uint _transmissionRiskLevel) public returns (uint) {
            for (uint j = 0; j < keys.length; j++) {
               if (keccak256(abi.encodePacked(_keyData)) == keccak256(abi.encodePacked(keys[j])) &&
             _rollingStartNumber == rollingStartNumbers[j] &&
               _transmissionRiskLevel == transmissionRiskLevels[j])
                return j+1;
            }
    return 0;
    }
    function checkExportKeys(bytes memory exportFile, uint expStart)  public returns (bool) {
        bool[] memory checks = new bool[](keys.length);
       uint64 pos = uint64(expStart);
            while (pos < exportFile.length) {
            bytes16 _keyData = toBytes16(exportFile,pos);
            pos+=16;
            (bool succ, uint64 p, uint64 _transmissionRiskLevel) = ProtobufLib.decode_varint(pos,exportFile); 
             assert(succ);
            pos =p+1;
            (bool succ2, uint64 p2, uint64 _rollingStartNumber) = ProtobufLib.decode_varint(pos,exportFile); 
            assert(succ2);
            pos = p2+1;

            //convert to midnight of the same day, based on how immuni/swisscovid work
           _rollingStartNumber = uint64(DateTime.toTimestamp(DateTime.getYear(_rollingStartNumber),
                DateTime.getMonth(_rollingStartNumber),DateTime.getDay(_rollingStartNumber)));

            /* (bool succ3, uint64 p3, uint64 _rollingPeriod) = ProtobufLib.decode_varint(pos,exportFile); 
           assert(succ3);
            //Value not important in Immuni
            pos = p3+7;*/
            pos += 10;
            uint i = checkKey(_keyData,_rollingStartNumber,_transmissionRiskLevel);
            if (i != 0) checks[i-1] = true;
        }
        for(uint i = 0; i < keys.length; i++)
                if (!checks[i]) return false;
        return true;
    } 

    //Check primev256 signature
    function checkSignature(bytes memory exportFile, 
    bytes memory signatureFile, uint sigStart) internal  returns (bool)
    {
        bytes memory signature = BytesLib.slice(signatureFile,sigStart,71);
       uint8 offset = uint8(signature[3])-32;
       uint8 offset2 = uint8(signature[offset+37])-32;
        uint[2] memory sig;
        sig[0] = BytesLib.toUint256(signature,offset+4);
        sig[1] = BytesLib.toUint256(signature,offset+38+offset2);
      return EllipticCurve.validateSignature(sha256(exportFile),sig,tekPK);
    }

    function sendSignedTEKListImmuni(bytes memory exportFile,  bytes memory signatureFile) public payable {
        sendSignedTEKList(exportFile,signatureFile,IMMUNI_EXP_START,IMMUNI_SIG_START);

    }
      function sendSignedTEKListSC(bytes memory exportFile,  bytes memory signatureFile) public payable {
        sendSignedTEKList(exportFile,signatureFile,SWISSCOVID_EXP_START,SWISSCOVID_SIG_START);
        
    }


    function sendSignedTEKList(bytes memory exportFile,  bytes memory signatureFile, uint expStart, uint sigStart) public payable {
        require (buyerDeposited);
        require (promised);
        require (!sigVerified);
        require (checkExportKeys(exportFile,expStart));
        require (checkSignature(exportFile,signatureFile,sigStart));
        seller.transfer(prize);
        sigVerified = true;
    }


    function toBytes16(bytes memory _bytes, uint256 _start) internal pure returns (bytes16) {
        require(_start + 16 >= _start, "toBytes16_overflow");
        require(_bytes.length >= _start + 16, "toBytes16_outOfBounds");
        bytes16 tempBytes16;

        assembly {
            tempBytes16 := mload(add(add(_bytes, 0x10), _start))
        }

        return tempBytes16;
    }
    }