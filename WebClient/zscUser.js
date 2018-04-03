/*
Copyright (c) 2018 ZSC Dev Team
*/
function ZSCUser() {
    this.userName;
    this.userNameHr;
    this.controlApisAdr;
    this.controlApisFullAbi;
}
ZSCUser.prototype.setControlApisAdr = function(adr) { this.controlApisAdr = adr; } 
ZSCUser.prototype.setControlApisFullAbi = function(abi) { this.controlApisFullAbi = abi; } 
ZSCUser.prototype.getUserName = function() { return this.userName; }
ZSCUser.prototype.getUserNameHr = function() { return this.userNameHr; }
ZSCUser.prototype.getControlApisAdr = function() { return this.controlApisAdr; }
ZSCUser.prototype.getControlApisFullAbi = function() { return this.controlApisFullAbi; }
ZSCUser.prototype.getLoginAbi = function() { return [{"constant":true,"inputs":[{"name":"_user","type":"bytes32"},{"name":"_hexx","type":"bytes32"}],"name":"getFullAbi","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"_user","type":"bytes32"},{"name":"_pass","type":"bytes32"}],"name":"tryLogin","outputs":[{"name":"","type":"bytes32"}],"payable":false,"stateMutability":"view","type":"function"}]; }

ZSCUser.prototype.tryLogin = function(user, pass, adr, func){
    var myContract = web3.eth.contract(uF_controlApisAdvAbiLogin);
    var myControlApi = myContract.at(adr);

    myControlApi.tryLogin(user, pass, function(error, hexx) {
        if(!error) {
            if (hexx == 0x0) {
                func(false);
            } else {
                this.getFullAbi(user, hexx, adr, func);
            }
        } else console.log("error: " + error);
    } );
}

ZSCUser.prototype.getFullAbi = function (user, hexx, adr, func){
    var myContract = web3.eth.contract(this.getLoginAbi());
    var myControlApi = myContract.at(adr);
    myControlApi.getFullAbi(user, hexx, adr, function(error, fullAbi) {
        if(!error) { 
            this.userName = user;
            this.userNameHr = hex;
            this.controlApisAdr = adr;
            this.controlApisFullAbi = fullAbi;
            func(true);
        } else {
            console.log("error: " + error);
        }
    } );
}


