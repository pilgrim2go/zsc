/*
Copyright (c) 2018 ZSC Dev Team
*/

//class zscWallet
function ZSCAgreementProvider(nm, abi, adr) {
    this.userName = nm;
    this.tmpName;
    this.agrNos = 0;
    this.agrNames = [];
    this.balance = [];
    this.account = web3.eth.accounts[0];
    this.contractAdr = adr;
    this.contractAbi = JSON.parse(abi);
}

ZSCAgreementProvider.prototype.getUserName = function() {return this.userName;}

ZSCAgreementProvider.prototype.setTemplateName = function(name) {this.tmpName = name;}

ZSCAgreementProvider.prototype.loadAgreements = function(func) {
    var gm = this;
    var callBack = func;
    var myControlApi = web3.eth.contract(gm.contractAbi).at(gm.contractAdr);

    gm.numAgreements(gm, function(gm) {
        if (gm.agrNos == 0) {
            callBack();
        } else {
            for (var i = 0; i < gm.agrNos; ++i) {
                gm.getAgrNameByIndex(gm, i, function(gm, j){
                    gm.getAgrBalance(gm, j, function(gm, index) {
                        if (index == gm.agrNos - 1) {
                            callBack();
                        }
                    });
                });
            }
        }
    });
}

ZSCAgreementProvider.prototype.numAgreements= function(gm, func) {
    var callBack = func;
    var myControlApi = web3.eth.contract(gm.contractAbi).at(gm.contractAdr);

    myControlApi.numElementChildren(gm.userName, gm.tmpName,
        {from: gm.account},
        function(error, result){ 
            if(!error) {
                gm.agrNos = result.toString(10);
                callBack(gm);
            } else {
                console.log("error: " + error);
            }
        });
}

ZSCAgreementProvider.prototype.getAgrNameByIndex = function(gm, index, func) {
    var callBack = func;
    var myControlApi = web3.eth.contract(gm.contractAbi).at(gm.contractAdr);
    
    myControlApi.getElementChildNameByIndex(gm.userName, gm.tmpName, index,
        {from: gm.account},
        function(error, result){ 
            if(!error) {
                gm.agrNames[index] = web3.toUtf8(result);
                callBack(gm, index);
            } else {
                console.log("error: " + error);
            }
        });
}

ZSCAgreementProvider.prototype.getAgrBalance = function(gm, index, func) {
    var callBack = func;
    var myControlApi = web3.eth.contract(gm.contractAbi).at(gm.contractAdr);
    
    myControlApi.getElementBalance(gm.userName, gm.agrNames[index], "ZSC",
        {from: gm.account},
        function(error, result){ 
            if(!error) {
                gm.balance[index] = result.toString(10);
                if (index == gm.agrNos - 1) {
                    callBack(gm, index);
                }
            } else {
                console.log("error: " + error);
            }
        });
}

ZSCAgreementProvider.prototype.confirmPublishAgreement = function(index, func) {
    this.myControlApi.confirmPublishAgreement(this.userName, this.agrNames[index] ,
        {from: this.getAccount(), gasPrice: this.getGasPrice(1), gas : this.getGasLimit(20)}, 
        function(error, result){ 
            if(!error) {
                func(result);
            } else {
                console.log("error: " + error);
            }
        });
}

ZSCAgreementProvider.prototype.claimReward = function(hashLogId, elementName, func) {
    var gm = this;
    var callBack = func;
    var myControlApi = web3.eth.contract(gm.contractAbi).at(gm.contractAdr);
    
    myControlApi.claimInsurance(gm.userName, elementName,
        {from: gm.account, gas: 9000000},
        function(error, result){ 
            if(!error) {
                bF_showHashResult(hashLogId, result, callBack);
            } else {
                console.log("error: " + error);
            }
        });
}

ZSCAgreementProvider.prototype.loadAgreementsHtml = function(elementId, funcSetPara)  {
    var funcSetParaPrefix = funcSetPara + "('"; 
    var funcSetParaSuffix = "')";

    var titlle = "provider [" + this.userName + "] - published agreements: "

    var text ="";
    text += '<div class="well">';
    text += '<div class="well"> <text>' + titlle + ' </text></div>';
    text += '<table align="center" style="width:600px;min-height:30px">'
    text += '<tr>'
    text += '   <td>Name</td> <td>Balance </td> <td>Details </td>'
    text += '</tr>'
    text += '<tr> <td>---</td> <td>---</td> <td>---</td> </tr>'

    for (var i = 0; i < this.agrNos; ++i) {
        text += '<tr>'
        text += '   <td><text>' + this.agrNames[i]  + '</text></td>'
        text += '   <td><text>' + this.balance[i]  + '</text></td>'
        text += '   <td><button type="button" onClick="' + funcSetParaPrefix + this.agrNames[i] + funcSetParaSuffix + '">Show</button></td>'
        text += '</tr>'
        text += '<tr> <td>---</td> <td>---</td> <td>---</td>  </tr>'
    }
    text += '</table></div>'

    document.getElementById(elementId).innerHTML = text;  
}

