// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.9;

contract AdExToken {

    string private name = "AdEx";
    string private symbol = "ADX";
	
	// uint private decimals = 18;
    uint256 private totalSupply = 100000000;
    // address admin;
    AdExToken public tokenContract;
    uint256 public tokenPrice;
    uint256 public tokensSold;
    // string dateStartSale = '2021-09-30 08:30:00';
    // string dateStage1 = '2021-09-30 08:45:00';
    // string dateStage2 = '2021-09-30 09:00:00';
    // string dateEndSale = '2021-09-30 09:30:00';
    
    // uint timestampDateStartSale = DateUtils.convertDateTimeStringToTimestamp(dateStartSale);
    // uint timestampDateStage1 = DateUtils.convertDateTimeStringToTimestamp(dateStage1);
    // uint timestampDateStage2 = DateUtils.convertDateTimeStringToTimestamp(dateStage2);
    // uint timestampEndStartSale = DateUtils.convertDateTimeStringToTimestamp(dateEndSale);

    event Sell(address _buyer, uint256 _amount);

    event Transfer(
        address indexed _from, 
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    mapping(address => uint256) private balanceOf;
    mapping(address => mapping(address => uint256)) private allowance;

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);

        return true;
    }

    function AdexTokenSale(AdExToken _tokenContract) public {
        admin = msg.sender;
        tokenContract = _tokenContract;
        
        // if(block.timestamp > timestampDateStage2&&
        //    block.timestamp <= timestampEndStartSale)
        //     tokenPrice = div(111111, 100000000);
        
        // if(block.timestamp > timestampDateStartSale &&
        //    block.timestamp <= timestampDateStage1)
        //     tokenPrice = div(48309, 50000000);
            
        // if(block.timestamp > timestampDateStage1 &&
        //    block.timestamp <= timestampDateStage2)
        //     tokenPrice = div(8547, 10000000);
    }


    function buyTokens(uint256 _numberOfTokens) public payable {
        require(msg.value == _numberOfTokens*tokenPrice);
        require(tokenContract.balanceOf(this) >= _numberOfTokens);
        require(tokenContract.transfer(msg.sender, _numberOfTokens));

        tokensSold += _numberOfTokens;

        emit Sell(msg.sender, _numberOfTokens);
    }

    function endSale() public {
        require(msg.sender == admin);
        require(tokenContract.transfer(admin, tokenContract.balanceOf(this)));

        // Just transfer the balance to the admin
        admin.transfer(address(this).balance);
    }
}