/*
Copyright (c) 2018 ZSC Dev Team
*/

pragma solidity ^0.4.21;

import "./control_base.sol";

contract ControlApis is ControlBase {
    /// @dev Constructor
    /// @param _name The name of the controller
    function ControlApis(bytes32 _name) public ControlBase(_name) {
    }

    function setUserStatus(bytes32 _user, bool _tag) public returns (bool);
    function getUserStatus(bytes32 _user) public constant returns (bool);

    /// @dev Set the zsc adm address
    /// @param _adm The address of the zsc adm 
    function initControlApis(address _zscToken, address _adm) public {
        checkDelegate(msg.sender, 1);
        initControlApisAdrs(_zscToken, _adm);
    }

    function addSystemComponent(bytes32 _type, bytes32 _name, address _adr) public returns (bool) {
        checkDelegate(msg.sender, 1);
        require(_adr != address(0));
        return addComponent(_type, _name, _adr);
    }

    /*
    function registerErc20Token(bytes32 _symbol, bytes32 _name, uint _decimals, address _tokenAdr) public returns (bool) {
        checkDelegate(msg.sender, 1);
        return getWalletManager().addTokenContract(_name, _symbol, _decimals, _tokenAdr);
    }

    function removeErc20Token(bytes32 _symbol) public returns (bool) {
        checkDelegate(msg.sender, 1);
        return getWalletManager().removeTokenContract(_symbol);
    }

    function runSimulationTest(uint _steps) public {
        checkDelegate(msg.sender, 1);
        getSimulatorManager().runSimulation(_steps);
    }

    function getTokenContractInfoByIndex(uint _index) public constant returns (string) {
        checkDelegate(msg.sender, 1);
        return prepareTokenContractInfoByIndex(_index);
    }
    */

   
    /// @dev Get the number of elements of the database
    function numFactoryElements(bytes32 _userName, bytes32 _factoryType) public constant returns (uint) { 
        checkRegistered(_userName, msg.sender);

        return getDBFactory(_factoryType).numFactoryNodes(); 
    }
    

    /// @dev Get the element name by the index
    /// @param _index The index of the element in the database
    function getFactoryElementNameByIndex(bytes32 _userName, bytes32 _factoryType, uint _index) public constant returns (bytes32) { 
        checkRegistered(_userName, msg.sender);

        return getDBFactory(_factoryType).getFactoryNodeNameByIndex(_index); 
    }


    /// @dev Check the element wheather or not existing
    /// @param _enName The name of the element to be checked
    function doesElementExist(bytes32 _userName, bytes32 _enName) public constant returns (bool) {
        checkRegistered(_userName, msg.sender);
        checkMatched(_userName, _enName, msg.sender);

        address adr = address(getDBNode(getCurrentDBName(), _enName));
        return (adr != address(0));
    }

    function addSignatureAdr(bytes32 _userName, address _sigAdr) public returns (bool) {
        checkRegistered(_userName, msg.sender);
        if (getDBNode(getCurrentDBName(), _userName).addSignature(_sigAdr)) {
            registerSignature(_userName, _sigAdr);
        }
        return true;
    }

    /// @dev Creat an element
    function createUserNode(bytes32 _factoryType, bytes32 _userName, address _extraAdr) public returns (address) {
        checkRegistered(_userName, msg.sender);
        require(_factoryType != "staker");

        address creatorAdr;
        if (isDelegate(msg.sender, 1)) {
            creatorAdr = _extraAdr;
        } else {
            creatorAdr = msg.sender;
        }

        address ndAdr = createNodeForUser(_factoryType, _userName, creatorAdr);
        require(ndAdr != address(0));
        registerUserNode(_userName, ndAdr, creatorAdr);
        
        return ndAdr;
    }

    function createElementNode(bytes32 _factoryType, bytes32 _userName, bytes32 _enName, bytes32 _extraInfo, address _extraAdr) public returns (address) {
        checkRegistered(_userName, msg.sender);

        if (_factoryType == "provider" || _factoryType == "receiver" || _factoryType == "staker") {
            revert();
        }
        require(address(getDBNode(getCurrentDBName(), _enName)) == 0);

        address creatorAdr;
        if (isDelegate(msg.sender, 1)) {
            creatorAdr = _extraAdr;
        } else {
            creatorAdr = msg.sender;
        }

        address ndAdr = createNodeForEelement(_factoryType, _userName, _enName, _extraInfo, creatorAdr);
        return 0;


        require(ndAdr != address(0));
        registerEntityNode(_userName, _enName, ndAdr, creatorAdr);
        
        return ndAdr;
    }


    //Disabled during alpha-test
    /* 
    function enableElementWallet(bytes32 _userName, bytes32 _tokeSymbol, address _extraAdr) public returns (address) {
        checkRegistered(_userName, msg.sender);
        
        address creatorAdr;
        if (isDelegate(msg.sender, 1)) {
            creatorAdr = _extraAdr;
        } else {
            creatorAdr = msg.sender;
        }

        return enableWalletByUser(_userName, _tokeSymbol, creatorAdr);
    }
    */

    /// @dev Get the element by its address
    /// @param _adr The address of the existing element
    function getElementNameByAddress(bytes32 _userName, address _adr) public constant returns (bytes32) {
        checkRegistered(_userName, msg.sender);

        require (getDBDatabase(getCurrentDBName()).checkeNodeByAddress(_adr));
        return Object(_adr).name();
    }

    /// @dev Get the type of an element
    /// @param _enName The name of the element belonging to the user
    function getElementType(bytes32 _userName, bytes32 _enName) public constant returns (bytes32) {
        checkRegistered(_userName, msg.sender);
        checkMatched(_userName, _enName, msg.sender);

        DBNode nd = getDBNode(getCurrentDBName(), _enName);
        require(address(nd) != address(0));
        return nd.getNodeType();
    }

    /// @dev Add a paramter to an element
    /// @param _enName The name of the existing element
    /// @param _parameter The name of the added parameter
    function addElementParameter(bytes32 _userName, bytes32 _enName, bytes32 _parameter) public returns (bool) {
        checkRegistered(_userName, msg.sender);
        checkMatched(_userName, _enName, msg.sender);

        return getDBNode(getCurrentDBName(), _enName).addParameter(_parameter);
    }

    /// @dev Set the value to a paramter of an element 
    /// @param _enName The name of the element
    /// @param _parameter The name of the existing parameter
    /// @param _value The parameter value
    function setElementParameter(bytes32 _userName, bytes32 _enName, bytes32 _parameter, bytes32 _value) public returns (bool) {
        checkRegistered(_userName, msg.sender);
        checkMatched(_userName, _enName, msg.sender);

        return getDBNode(getCurrentDBName(), _enName).setParameter(_parameter, _value);
    }

    /// @dev Get the value of a paramter of an element
    /// @param _enName The name of the element
    /// @param _parameter The name of the existing parameter
    function getElementParameter(bytes32 _userName, bytes32 _enName, bytes32 _parameter) public constant returns (bytes32) {
        checkRegistered(_userName, msg.sender);
        checkMatched(_userName, _enName, msg.sender);

        return getDBNode(getCurrentDBName(), _enName).getParameter(_parameter);
    }

    /// @dev Get the address of the element 
    /// @param _enName The name of the element
    function getElementAddress(bytes32 _userName, bytes32 _enName) public constant returns (address) {
        checkRegistered(_userName, msg.sender);
        checkMatched(_userName, _enName, msg.sender);

        return address(getDBNode(getCurrentDBName(), _enName));
    }

    //Disabled during alpha-test
    /// @dev Get the eth balance of the element
    /// @param _enName The name of the element
    function getElementBalance(bytes32 _userName, bytes32 _enName, bytes32 _symbol) public constant returns (uint) {
        checkRegistered(_userName, msg.sender);
        checkMatched(_userName, _enName, msg.sender);

        bytes32 walletName = formatWalletName(_enName, _symbol);
        address walletAdr = address(getDBNode(getCurrentDBName(), walletName));
        require(walletAdr != address(0));

        return DBNode(walletAdr).getBlance().div(1 ether);
    }

    /// @dev Get the number of paramters of an element
    /// @param _enName The name of the existing element
    function numElementParameters(bytes32 _userName, bytes32 _enName) public constant returns (uint) {
        checkRegistered(_userName, msg.sender);
        checkMatched(_userName, _enName, msg.sender);

        return  getDBNode(getCurrentDBName(), _enName).numParameters();
    }

    /// @dev Get the number of paramters of an element
    /// @param _enName The name of the existing element
    /// @param _index The index of the parameter
    /* Example:
        var num = numNodeParameters("test");
        if (num > 0) {
            var para = getNodeParameterNameByIndex("test", 0);
        }
    */
    function getElementParameterNameByIndex(bytes32 _userName, bytes32 _enName, uint _index) public constant returns (bytes32) {
        checkRegistered(_userName, msg.sender);
        checkMatched(_userName, _enName, msg.sender);

        return getDBNode(getCurrentDBName(), _enName).getParameterNameByIndex(_index);
    }

    /// @dev Transfer a particular amount from a user wallet to the destination address
    /// @param _dest The destination address
    /// @param _amount The amount to be transferred
    function submitTransfer(bytes32 _userName, bytes32 _tokenSymbol, address _dest, uint256 _amount) public returns (uint) {
        require(_amount > 0);
        checkRegistered(_userName, msg.sender);

        bytes32 walletName = formatWalletName(_userName, _tokenSymbol);
        address walletAdr = address(getDBNode(getCurrentDBName(), walletName));

        require(walletAdr != address(0));

        uint amount = 0;
        amount = DBNode(walletAdr).executeTransaction(_dest, _amount);

        return amount;

        /* Multisig module
        if (DBNode(walletAdr).doesLastTransactionSigned()) {
            amount = DBNode(walletAdr).submitTransaction(_dest, _amount, "", msg.sender);
        } 
        return amount;
        */
    }

    //Disabled during alpha-test
    /* Multisig module
    /// @dev Confirm a transaction
    function confirmTransfer(bytes32 _userName, bytes32 _tokenSymbol) public returns (uint) {
        checkRegistered(_userName, msg.sender);

        bytes32 walletName = formatWalletName(_userName, _tokenSymbol);
        address walletAdr = address(getDBNode(walletName));

        require(walletAdr != address(0));

        uint amount = 0;
        if (!DBNode(walletAdr).doesLastTransactionSigned()) {
            amount = DBNode(walletAdr).confirmTransaction(msg.sender);
        } 
        return amount;
    }
    */


    function informTransfer(bytes32 _userName, bytes32 _enName, address _dest, uint256 _amount) public returns (bool) {
        checkRegistered(_userName, msg.sender);
        checkMatched(_userName, _enName, msg.sender);

        return conductInformTransaction(_enName, _dest, _amount);
    }

    //Disabled during alpha-test
    /// @dev Announce an insurance agreement by a provider
    /*
    function publishAgreement(bytes32 _userName, bytes32 _agrName) public returns (uint) {
        checkRegistered(_userName, msg.sender);
        checkMatched(_userName, _agrName, msg.sender);

        return conductPublishAgreement(_userName, _agrName, msg.sender);
    }
    */

    function numElementChildren(bytes32 _userName, bytes32 _enName) public constant returns (uint) {
        checkRegistered(_userName, msg.sender);
        checkMatched(_userName, _enName, msg.sender);
        return  getDBNode(getCurrentDBName(), _enName).numChildren();
    }

    function getElementChildNameByIndex(bytes32 _userName, bytes32 _enName, uint _index) public constant returns (bytes32) {
        checkRegistered(_userName, msg.sender);
        checkMatched(_userName, _enName, msg.sender);
        address adr = getDBNode(getCurrentDBName(), _enName).getChildByIndex(_index);
        return Object(adr).name();
    }

    function numTemplates(bytes32 _userName) public constant returns (uint) {
        checkRegistered(_userName, msg.sender);

        return getDBNode(getCurrentDBName(), _userName).numTemplates();
    }

    function getTemplateNameByIndex(bytes32 _userName, uint _index) public constant returns (bytes32) {
        checkRegistered(_userName, msg.sender);

        address adr = getDBNode(getCurrentDBName(), _userName).getTemplateByIndex(_index);
        return Object(adr).name();
    }

    function numAgreements(bytes32 _userName) public constant returns (uint) {
        checkRegistered(_userName, msg.sender);

        return getDBNode(getCurrentDBName(), _userName).numAgreements();
    }

    function getAgreementNameByIndex(bytes32 _userName, uint _index) public constant returns (bytes32) {
        checkRegistered(_userName, msg.sender);

        address adr = getDBNode(getCurrentDBName(), _userName).getAgreementByIndex(_index);
        return Object(adr).name();
    }

    //Disabled during alpha-test
    /*
    function deleteAgreementByIndex(bytes32 _userName, uint _index) public returns (bool) {
        checkRegistered(_userName, msg.sender);

        address adr = getDBNode(getCurrentDBName(), _userName).getAgreementByIndex(_index);
        return deleteAgreement( Object(adr).name());
    }
    */

    /// @dev Buy an insurance agreement from a provider
    function purchaseAgreement(bytes32 _userName, bytes32 _agrName) public returns (uint) {
        checkRegistered(_userName, msg.sender);

        bytes32 userType = getDBNode(getCurrentDBName(), _userName).getNodeType();
        require(userType == "receiver");

        return conductPurchaseAgreement(_userName, _agrName); 
    }

    function claimInsurance(bytes32 _userName, bytes32 _agrName) public returns (bool) {
        checkRegistered(_userName, msg.sender);

        return conductZSCClaimInsurance(_userName, _agrName);
    }

    /*
    /// @dev Buy an insurance agreement from a provider
    /// @param _userName The receiver name
    function confirmPurchaseAgreement(bytes32 _userName, bytes32 _agrName) public returns (uint) {
        checkRegistered(_userName, msg.sender);

        uint amount = getWalletManager().conductPurchaseAgreement(false, _userName, _agrName, msg.sender);
        if (amount > 0) {
            require(preparePurchaseAgreement(_userName, _agrName));
        }     
        return amount; 
    }
    */

    /*
    function numRegisteredErc20Tokens(bytes32 _userName) public constant returns (uint) {
        checkRegistered(_userName, msg.sender);

        return getWalletManager().numTokenContracts() + 1;
    }
    */

    function getUserWalletAddress(bytes32 _userName, bytes32 _tokenSymbol) public constant returns (address) {
        checkRegistered(_userName, msg.sender);

        bytes32 walletName = formatWalletName(_userName, _tokenSymbol);
        address walletAdr = address(getDBNode(getCurrentDBName(), walletName));

        //require(walletAdr != address(0));        

        return walletAdr;
    }

    function getTokenBalanceInfoByIndex(bytes32 _userName, uint _index) public constant returns (string) {
        checkRegistered(_userName, msg.sender);

        return prepareTokenBalanceInfoByIndex(_userName, _index);
    }

    //Disabled during alpha-test
    /*
    function getUserWalletAddress(bytes32 _userName, bytes32 _tokenSymbol) public constant returns (address) {
        checkRegistered(_userName, msg.sender);

        DBNode nd = getDBNode(getCurrentDBName(), _userName);
        require(nd != DBNode(0));

        string memory temp = PlatString.append(_userName, "-", _tokenSymbol);
        return address(getDBNode(getCurrentDBName(), PlatString.tobytes32(temp)));
    }
    */

    function numUserTransactions(bytes32 _userName, bytes32 _tokenSymbol) public constant returns (uint) {
        checkRegistered(_userName, msg.sender);

        bytes32 walletName = formatWalletName(_userName, _tokenSymbol);
        address walletAdr = address(getDBNode(getCurrentDBName(), walletName));

        require(walletAdr != address(0));
        
        return DBNode(walletAdr).numTransactions();
    }

    function getUserTransactionByIndex(bytes32 _userName, bytes32 _tokenSymbol, uint _index) public constant returns (string) {
        checkRegistered(_userName, msg.sender);

        bytes32 walletName = formatWalletName(_userName, _tokenSymbol);
        return prepareTransationfoByIndex(walletName, _index);
    }

    /*
    function numBlockInfo(bytes32 _userName, uint _poolIndex, bool _isMined) public constant returns (uint) {
        checkRegistered(_userName, msg.sender);
        return getPosManager().numBlockInfo(_poolIndex, _isMined);
    }

    function getBlockInfoByIndex(bytes32 _userName, uint _poolIndex, uint _blockIndex) public constant returns (string) {
        checkRegistered(_userName, msg.sender);
        return prepareBlockInfoByIndex(_poolIndex, _blockIndex);
    }

    function numStakerMining(bytes32 _userName, bool _isReward) public constant returns (uint) {
        checkRegistered(_userName, msg.sender);
        return getDBNode(_userName).numMiningInfo(_isReward);
    }

    function getStakerMiningInfoByIndex(bytes32 _userName, bool _isReward, uint _index) public constant returns (string) {
        checkRegistered(_userName, msg.sender);
        return prepareMiningInfoByIndex(_userName, _isReward, _index);
    }
    */
}
