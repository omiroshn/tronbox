// Initiate request object
const request = require("request");
// Initiate TronWeb object
const TronWeb = require('tronweb');
const HttpProvider = TronWeb.providers.HttpProvider;
// Full node http endpoint
const fullNode = new HttpProvider("https://api.shasta.trongrid.io");
// Solidity node http endpoint
const solidityNode = new HttpProvider("https://api.shasta.trongrid.io");
// Contract events http endpoint
const eventServer = "https://api.shasta.trongrid.io";
// Private key of oracle
const ownerPrivateKey = '8e0145af26cee3a398f7fa5cf9cdcba0656df85da6060b3887272227d35dfe0f';
const userPrivateKey = '73740b7d3c2dc49108fd4cf89cb8ef084d4cb054bc704747718696b17584ea15';

// Create instance of TronWeb
const tronWeb = new TronWeb(
    fullNode,
    solidityNode,
    eventServer,
    ownerPrivateKey
);

const diceTRXHex = "413a5a566a8480bf24dfe3f6eedacaac818bd2bf6e"
const portalHex  = "41ca574310303779f905be01e8d263f513c0e7b5df"
const SCGHex     = "41cb34e1317e096f52837e5146bbeb6c817ddde510"

var DiceTRX_JSON = require('./JSON/DiceTRX.json');
var Portal_JSON  = require('./JSON/Portal.json');
var SCG_JSON     = require('./JSON/SCG.json');

const contractDiceTRX = {
    "DiceTRX.sol:DiceTRX": {
        "address": diceTRXHex,
        "abi": DiceTRX_JSON
    }
};
const contractPortal = {
    "Portal.sol:Portal": {
        "address": portalHex,
        "abi": Portal_JSON
    }
};
const contractSCG = {
    "SCG.sol:SCG": {
        "address": SCGHex,
        "abi": SCG_JSON
    }
};

const SCG = tronWeb.contract(contractSCG["SCG.sol:SCG"].abi, contractSCG["SCG.sol:SCG"].address);
const Portal = tronWeb.contract(contractPortal["Portal.sol:Portal"].abi, contractPortal["Portal.sol:Portal"].address);
const DiceTRX = tronWeb.contract(contractDiceTRX["DiceTRX.sol:DiceTRX"].abi, contractDiceTRX["DiceTRX.sol:DiceTRX"].address);

async function start() {

    // SCG.setSaleAgent(portalHex).send({
    //     shouldPollResponse: true,
    //     callValue: 0
    // }).catch(error => {
    //     console.error(error);  
    // });

    // Portal.setMainStatus(portalHex).send({
    //     shouldPollResponse: true,
    //     callValue: 0
    // }).catch(error => {
    //     console.error(error);  
    // });

    // Portal.setDiceTRXContract(diceTRXHex).send({
    //     shouldPollResponse: true,
    //     callValue: 0
    // }).catch(error => {
    //     console.error(error);  
    // });

    const serverHash = "0x9932dd2d28263008a0e50a54d95c47b713977a2db276e1f314423af38fc774e5"

    // DiceTRX.initGame(serverHash).send({
    //     shouldPollResponse: true,
    //     callValue: 0
    // }).then(gameId => {
    //     console.log(`Game id is: ${ Object.values(gameId) }`);
    // }).catch(error => {
    //     console.error(error);  
    // });

    const clientSeed = "0x9932dd2d28263008a0e50a54d95c47b713977a2db276e1f314423af38fc774e1"
    const number = "5"
    const rollUnder = "false"
    const id = "1"

    // DiceTRX.startGame(clientSeed, number, rollUnder, id).send({
    //     shouldPollResponse: true,
    //     callValue: 2
    // }).then(ret => {
    //     console.log(`Game started: ${ret}`);
    // }).catch(error => {
    //     console.error(error);  
    // });

    const serverSeed = "0x6B86B273FF34FCE19D6B804EFF5A3F5747ADA4EAA22F1D49C01E52DDB7875B4B"

    // DiceTRX.finishGame(serverSeed, id).send({
    //     shouldPollResponse: true,
    //     callValue: 0
    // }).then(ret => {
    //     console.log(`Game ended: ${ret}`);
    // }).catch(error => {
    //     console.error(error);
    // });

    // tronWeb.trx.sendTransaction("TFHkQwzvFdrM8cfm3b9EmVpbtgt2wniaM8", 100, userPrivateKey);

    // DiceTRX.getBalance().call({
    //     shouldPollResponse: true,
    //     callValue: 0
    // }).then(gameId => {
    //     console.log(`Balance is: ${ gameId }`);
    // }).catch(error => {
    //     console.error(error);  
    // });

    // const rtp = "100";
    // const rtpDiv = "200";

    // DiceTRX.changeRTP(rtp, rtpDiv).send({
    //     shouldPollResponse: true,
    //     callValue: 0
    // }).then(gameId => {
    //     console.log(`Resp: ${ gameId }`);
    // }).catch(error => {
    //     console.error(error);  
    // });
}

start()

// const main = async() => {
//     console.log(await start());
// }
// main();

