<?php 
/*
Copyright (c) 2018 ZSC Dev Team
*/
?>

<?php
include("adm_header.php");
$htmlObjects = new ZSCHtmlObjects();
?>

<html>
<head>
<?php echo $htmlObjects->loadScriptFiles(); ?>
<script type="text/javascript">
    var web3 = setupWeb3js(false);
    
</script>
</head>
<body>

<?php     
echo $htmlObjects->loadHeader(); 
?>

<div class="page-header"><font size="5" color="blue" >ZSC Alpha-test Adm: show log</font></div>
 <?php     
echo $htmlObjects->loadAllAdrs();
?>   

<text>Log:</text>
<div class="well">
    <button type="button" onClick="<?php echo "sF_changeLogerModule('".$htmlObjects->readObjectAddress("AdmAdv")."')"?>">AdmAdv</button> 
    <button type="button" onClick="<?php echo "sF_changeLogerModule('".$htmlObjects->readObjectAddress("DBDatabase")."')"?>">DBDatabase</button> 
    <button type="button" onClick="<?php echo "sF_changeLogerModule('".$htmlObjects->readObjectAddress("FactoryPro")."')"?>">FactoryPro</button> 
    <button type="button" onClick="<?php echo "sF_changeLogerModule('".$htmlObjects->readObjectAddress("FactoryRec")."')"?>">FactoryRec</button> 
    <button type="button" onClick="<?php echo "sF_changeLogerModule('".$htmlObjects->readObjectAddress("FactoryTmp")."')"?>">FactoryTmp</button> 
    <button type="button" onClick="<?php echo "sF_changeLogerModule('".$htmlObjects->readObjectAddress("FactoryAgr")."')"?>">FactoryAgr</button> 
    <button type="button" onClick="<?php echo "sF_changeLogerModule('".$htmlObjects->readObjectAddress("FactoryWalletErc20")."')"?>">FactoryWalletErc20</button> 
    <button type="button" onClick="<?php echo "sF_changeLogerModule('".$htmlObjects->readObjectAddress("ControlApisAdv")."')"?>">ControlApisAdv</button><br><br>
    <text id = "SystemLog0"></text> 
    <text id = "SystemLog1"></text> 
    <text id = "SystemLog2"></text> 
    <text id = "SystemLog3"></text> 
    <text id = "SystemLog4"></text> 
    <text id = "SystemLog5"></text> 
    <text id = "SystemLog6"></text> 
    <text id = "SystemLog7"></text> 
</div>
<script type="text/javascript">
	var logedModuleAdrs = <?php echo $htmlObjects->getLogedObjectAddressArrayInString()?>;
    var recorderAdr = "<?php echo $htmlObjects->readObjectAddress('LogRecorder')?>";

    //function sF_initSystemLog(logRecorderAdr, adrs, elementID, initialModuleIndex) {
    sF_initSystemLog(recorderAdr, logedModuleAdrs, "SystemLog", 0);

</script>      
</body>
</html>

