// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.0;

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
    
    function mul(uint a, uint b) public pure returns (uint c ) {
        c = a * b; 
        require(a == 0 || c / a == b);
    } 
    
    function div(uint a, uint b) public pure returns (uint c ) {
        require(b > 0);
        c = a / b;
    }
}

contract AdExToken {
    using SafeMath for uint256;

    string public constant name = "AdEx";
    string public constant symbol = "ADX";
    uint8  public constant decimals = 18;

    uint256 private constant totalSupply_ = 100000000;
    uint256 private constant hardCap = 40000;
    uint256 private startDate;
    uint256 private constant startDayEndDayDiff = 30;
    
    uint256 private tokenSupply = 80000000;
    uint256 private bountySupply = 2000000;
    uint256 private discoverySupply = 2000000;
    uint256 private teamSupply = 10000000;
    uint256 private advisorsSupply = 6000000;
    
    address private master;

    mapping(address => uint256) public balances;
    mapping(address => mapping (address => uint256)) public allowed;
    
    mapping(address => uint256) tokenSupplyAllowance;
    mapping(address => uint256) bountySupplyAllowance;
    mapping(address => uint256) discoverySupplyAllowance;
    mapping(address => uint256) teamSupplyAllowance;
    mapping(address => uint256) advisorsSupplyAllowance;

    constructor() public{
        balances[msg.sender] = totalSupply_;
        startDate = block.timestamp;
        master = msg.sender;
    }

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Sell(address _buyer, uint256 _amount);
    
    modifier daylimit(){
        require(getDayDifference() >= startDayEndDayDiff);
        _;
    }
    
    modifier ownable() {
        require(master == msg.sender);
        _;
    }
    
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

    function allowance(address owner, address delegate) public view returns (uint remaining) {
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
    
    function getDayDifference() public view returns (uint256){
        return (getCurrentTime().sub(startDate)).div(60).div(60).div(24);
    }
    
    function convertEthToAdx(uint256 _amount)public pure returns (uint256){
        return _amount.div(10 ** 18).mul(900);
    }
    
    function getBonusTokens(uint256 _amount) private view returns (uint256){
        uint256 diff = getDayDifference();
        uint256 bonus = _amount;
        if (diff == 0){
            return bonus.mul(130).div(100);
        }else if(diff >= 1 && diff < 7){
            return bonus.mul(115).div(100);
        }
        return bonus;
    }
    
    function buyADX() public payable daylimit returns(bool){
        require(msg.value >= 10**decimals);
        require(address(this).balance.div(10**decimals) <= hardCap);
        uint256 receivedTokens = getBonusTokens(convertEthToAdx(msg.value)); 
        addTokenSupplyAllowance(msg.sender, receivedTokens);
        transferFromTokenSupply(msg.sender, receivedTokens);
        return true;
    }
    
     function addTokenSupplyAllowance(address _newAddress, uint256 _amount) public returns(bool) {
        tokenSupplyAllowance[_newAddress] = _amount;
        return true;
    }
    function addBountySupplyAllowance(address _newAddress, uint256 _amount) public ownable returns(bool) {
        bountySupplyAllowance[_newAddress] = _amount;
        return true;
    }
    function addDiscoverySupplyAllowance(address _newAddress, uint256 _amount) public ownable returns(bool) {
        discoverySupplyAllowance[_newAddress] = _amount;
        return true;
    }
    function addTeamSupplyAllowance(address _newAddress, uint256 _amount) public ownable returns(bool) {
        teamSupplyAllowance[_newAddress] = _amount;
        return true;
    }
    function addAdvisorsSupplyAllowance(address _newAddress, uint256 _amount) public ownable returns(bool) {
        advisorsSupplyAllowance[_newAddress] = _amount;
        return true;
    }
    
    
    // Spend tokens for different allocations(Only if msg.sender has allowance)
    function transferFromTokenSupply(address _to, uint256 _amount) private returns (bool){
        require(tokenSupplyAllowance[_to] >= _amount);
        require(tokenSupply >= _amount);
        tokenSupply = tokenSupply.sub(_amount);
		balances[_to] = balances[_to].add(_amount);
		tokenSupplyAllowance[_to] = tokenSupplyAllowance[_to].sub(_amount);
		emit Transfer(address(this), _to, _amount);
		return true;
    }
    function transferFromBountySupply(address _to, uint256 _amount) public daylimit returns (bool){
        require(bountySupplyAllowance[_to] >= _amount);
        require(bountySupply >= _amount);
        bountySupply = bountySupply.sub(_amount);
		balances[_to] = balances[_to].add(_amount);
		bountySupplyAllowance[_to] = bountySupplyAllowance[_to].sub(_amount);
		emit Transfer(address(this), _to, _amount);
		return true;
    }
    function transferFromDiscoverySupply(address _to, uint256 _amount) public daylimit returns (bool){
        require(discoverySupplyAllowance[_to] >= _amount);
        require(discoverySupply >= _amount);
        discoverySupply = discoverySupply.sub(_amount);
		balances[_to] = balances[_to].add(_amount);
		discoverySupplyAllowance[_to] = discoverySupplyAllowance[_to].sub(_amount);
		emit Transfer(address(this), _to, _amount);
		return true;
    }
    function transferFromTeamSupply(address _to, uint256 _amount) public daylimit returns (bool){
        require(teamSupplyAllowance[_to] >= _amount);
        require(teamSupply >= _amount);
        teamSupply = teamSupply.sub(_amount);
		balances[_to] = balances[_to].add(_amount);
		teamSupplyAllowance[_to] = teamSupplyAllowance[_to].sub(_amount);
		emit Transfer(address(this), _to, _amount);
		return true;
    }
    function transferFromAdvisorsSupply(address _to, uint256 _amount) public daylimit returns (bool){
        require(advisorsSupplyAllowance[_to] >= _amount);
        require(advisorsSupply >= _amount);
        advisorsSupply = advisorsSupply.sub(_amount);
		balances[_to] = balances[_to].add(_amount);
		advisorsSupplyAllowance[_to] = advisorsSupplyAllowance[_to].sub(_amount);
		emit Transfer(address(this), _to, _amount);
		return true;
    }
    
    
}