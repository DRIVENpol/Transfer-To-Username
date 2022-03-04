// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract TransferToUsername {

using SafeMath for uint256;


// VARIABLES
//uint256 public feeOnTransfer;
uint256 public feeSetUsername;

// MAPPINGS
mapping(address => string) public addressToUsername;
mapping(string => address) public usernameToAddress;


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
IERC20(_tokenAddress).transferFrom(_fromUser, address(this), _amount);
}

function _transferFromContract(address _toUser, address _tokenAddress, uint256 _amount) internal {
IERC20(_tokenAddress).transferFrom(address(this), _toUser, _amount);
}

function _transferEthToContract(uint256 _amount) internal {
 payable(address(this)).transfer(_amount);
}
function _transferEthFromContract(address _toUser, uint256 _amount) internal {
    payable(_toUser).transfer(_amount);
}

// PUBLIC FUNCTIONS
function setMyUsername(string memory newUsername) public {
_setMyUsername(newUsername, msg.sender);
emit SetUsername(newUsername, msg.sender);
}

function sendToUsername(string memory toUser, address tokenAddress, uint256 amount) public {
    require(usernameExist(toUser), "The username don't exist!");
    address _toUser = usernameToAddress[toUser];
    address _fromUser = msg.sender;
    _transferToContract(_fromUser, tokenAddress, amount);
    _transferFromContract(_toUser, tokenAddress, amount);
    emit SendTokens(toUser, addressToUsername[msg.sender], tokenAddress, amount);
}

function sendEthToUsername(string memory toUser, uint256 amount) public payable {
  //  require(msg.value >= feeOnTransfer, "Pay the fee before transfer!");
    require(usernameExist(toUser), "The username don't exist!");
    address _toUser = usernameToAddress[toUser];
    _transferEthToContract(amount);
    _transferEthFromContract(_toUser, amount);
}

// GETTERS
function getMyUsername() public view returns(string memory) {
    return addressToUsername[msg.sender];
}

function usernameExist(string memory toUser) public view returns(bool) {
if(usernameToAddress[toUser] != address(0x0)) {
return true;
} else {
    return false;
    }
}

}
