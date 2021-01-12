    pragma solidity ^0.6.0;
	
    contract GaenKey {
    	string keyData; //base64 key (optional)
    	uint rollingStartNumber;
    	uint rollingPeriod;
    	uint transmissionRiskLevel;
    /*	constructor (bytes memory _keyData, uint _rollingStartNumber, uint _rollingPeriod, uint _trasmissionRiskLevel) public {
    	    keyData = _keyData;
    	    rollingStartNumber = _rollingStartNumber;
    	    rollingPeriod = _rollingPeriod;
    	    transmissionRiskLevel = _trasmissionRiskLevel;
    	}*/
    	    constructor (string memory _keyData, uint _rollingStartNumber, uint _rollingPeriod, uint _trasmissionRiskLevel) public {
    	    rollingStartNumber = _rollingStartNumber;
    	    transmissionRiskLevel = _trasmissionRiskLevel;
    	    rollingPeriod = _rollingPeriod;
    	    keyData = _keyData;
    	}
    function getKeyData() view public returns (string memory) {
    	    return keyData;
    	}
       function getRollingStartNumber() view public returns (uint) {
    	    return rollingStartNumber;
    	}
    	function getRollingPeriod() view public returns (uint) {
    	    return rollingPeriod;
    	}
    	  	function getTrasmissionRiskLevel() view public returns (uint) {
    	    return transmissionRiskLevel;
    	}
    }