// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract TransferToUsername is Ownable {

using SafeMath for uint256;

// VARIABLES
uint256 public feeOnTransfer;
uint256 public feeSetUsername;

// MAPPINGS
mapping(address => string) public addressToUsername;
mapping(string => address) public usernameToAddress;
mapping(address => bool) public changeCount;

// EVENTS
event SetUsername(
string chosenUsername,
address indexed user
);

event SendTokens(
    string usernameReceiver,
    string usernameSender,
    address tokenAddress,
    uint256 amount
);

// INTERNAL FUNCTIONS
function _setMyUsername(string memory _newUsername, address _givenAccount) internal {
require(usernameToAddress[_newUsername] == address(0x0), "This username is taken!");
addressToUsername[_givenAccount] = _newUsername;
usernameToAddress[_newUsername] = _givenAccount;
}

function _transferToContract(address _fromUser, address _tokenAddress, uint256 _amount) internal {
IERC20 _tokenToTransfer = IERC20(_tokenAddress);
_tokenToTransfer.approve(address(this), _amount);
_tokenToTransfer.transferFrom(_fromUser, address(this), _amount);
}

function _transferFromContract(address _toUser, address _tokenAddress, uint256 _amount) internal {
IERC20 _tokenToTransfer = IERC20(_tokenAddress);
_tokenToTransfer.approve(_toUser, _amount);
_tokenToTransfer.transferFrom(address(this), _toUser, _amount);
}

function _transferEthToContract(uint256 _amount) internal {
 payable(address(this)).transfer(_amount);
}
function _transferEthFromContract(address _toUser, uint256 _amount) internal {
    payable(_toUser).transfer(_amount);
}

// PUBLIC FUNCTIONS
function setMyUsername(string memory newUsername) public payable {
require(changeCount[msg.sender] == true, "You can't change your username!");
changeCount[msg.sender] = false;
require(msg.value >= feeSetUsername, "Please pay the fee in order to choose an username!");
_setMyUsername(newUsername, msg.sender);
emit SetUsername(newUsername, msg.sender);
}

function sendToUSername(string memory toUser, address tokenAddress, uint256 amount) public payable {
    require(msg.value >= feeOnTransfer, "Pay the fee before transfer!");
    address _toUser = usernameToAddress[toUser];
    address _fromUser = msg.sender;
    _transferToContract(_fromUser, tokenAddress, amount);
    _transferFromContract(_toUser, tokenAddress, amount);
    emit SendTokens(toUser, addressToUsername[msg.sender], tokenAddress, amount);
}

function sendEthToUsername(string memory toUser, uint256 amount) public payable {
    require(msg.value >= feeOnTransfer, "Pay the fee before transfer!");
    address _toUser = usernameToAddress[toUser];
    _transferEthToContract(amount);
    _transferEthFromContract(_toUser, amount);
}
}
