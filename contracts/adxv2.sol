// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.9;

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
}

contract AdExToken {
    using SafeMath for uint256;

    string public constant name = "AdEx";
    string public constant symbol = "ADX";
    uint8 public constant decimals = 18;

    uint256 private constant totalSupply_ = 100000000;
    uint256 private constant hardCap = 40000;
    uint256 private startDate;
    uint256 private constant startDayEndDayDiff = 30;

    mapping(address => uint256) private balances;
    mapping(address => mapping (address => uint256)) private allowed;

    constructor() {
        balances[msg.sender] = totalSupply_;
        startDate = block.timestamp;
    }

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Sell(address _buyer, uint256 _amount);
    
    function totalSupply() public pure returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address tokenOwner) public view returns (uint256) {
        return balances[tokenOwner];
    }

    function getHardCap() public pure returns (uint256){
        return hardCap; 
    }

	function getCurrentTime() public view returns (uint256){
        return block.timestamp;
    }

	function getStartDate() public view returns (uint256){
        return startDate;
    }

	function getStartDayEndDayDiff() public pure returns (uint256){ 
        return startDayEndDayDiff;
    }
	

    function transfer(address receiver, uint256 numTokens) public returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) public returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public view returns (uint) {
      return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
}
}