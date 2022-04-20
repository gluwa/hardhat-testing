const {merge} = require("sol-merger");
fs = require("fs");

async function start(){
    const code = await merge('TestToken.sol');
    fs.writeFile("Test.sol",code,(err)=>{
        if(err)console.log(err);
    })
}
start();