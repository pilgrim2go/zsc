/*
Copyright (c) 2018 ZSC Dev.
*/

pragma solidity ^0.4.18;

import "./object.sol";

//Proof of Stake for ZSC system
contract PosBase is Object {
    enum TransactionStatus {NULL, PENDING, FAILED, SUCCEED}
    
    struct Transaction {
        TransactionStatus status_;
        uint createdTime_;
        uint finishedTime_;
        uint excutionSize_;
        bytes32 txhash_;
        address sender_;
        address receiver_;
        uint256 amount_;
        uint ethGasUsed_;
        bytes data_;
    }

    struct TransactionHistory {
        uint nos_;
        mapping(uint => Transaction) transactions_;
    }
    
    struct ZscStaker {
        bytes32 nodeName_;
        address nodeAddress_;
        address ethAddress_;
        uint stakePoint_;
        mapping(uint => uint) zscAmounts_;
    }

    struct ZscStakerPool {        
        uint nos_;
        mapping(address => bool) stakerExists_;
        mapping(address => uint) stakerIndex_;
        mapping(uint => ZscStaker) stakers_;
    }

    TransactionHistory private transactionHistory_;
    ZscStakerPool private zscStakerPool_;

    address zscToken_;

    // Constructor
    function PosBase(bytes32 _name) public Object(_name) {
    } 

    function setZscTokenAddress(address _adr) public only_delegate {
        zscToken_ = _adr;
    }

    function registerTransaction() public constant only_delegate {
    }

    function registerStaker(bytes32 _nodeName, address _nodeAddress, address _ethAddress) public only_delegate {
        require(!zscStakerPool_.stakerExists_[_ethAddress]);
        uint index = zscStakerPool_.nos_;
        zscStakerPool_.nos_++;
        zscStakerPool_.stakerExists_[_ethAddress] = true;
        zscStakerPool_.stakerIndex_[_ethAddress] = index;
        zscStakerPool_.stakers_[index].nodeName_    = _nodeName;
        zscStakerPool_.stakers_[index].nodeAddress_ = _nodeAddress;
        zscStakerPool_.stakers_[index].ethAddress_  = _ethAddress;
        zscStakerPool_.stakers_[index].stakePoint_  = 0;
    }

    function registerStaker(address _ethAddress) public only_delegate  {
        require(zscStakerPool_.stakerExists_[_ethAddress]);
        uint index = zscStakerPool_.stakerIndex_[_ethAddress];
        zscStakerPool_.nos_--;

        delete zscStakerPool_.stakerExists_[_ethAddress];
        delete zscStakerPool_.stakerIndex_[_ethAddress];
        delete zscStakerPool_.stakers_[index];
    }

}
