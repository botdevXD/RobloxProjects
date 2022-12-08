const axios = require("axios"); // Install axios by doing (npm install axios)
const userId = "USER_ID_HERE"
const Cookie = "ROBLOX_COOKIE_HERE";

let TotalRobuxSpent = 0;
let Finished = false;

async function CalculateTotalRobux(Cursor){
    await axios.get(`https://economy.roblox.com/v2/users/${userId}/transactions?cursor=${Cursor}&limit=100&transactionType=Purchase`, {
        withCredentials: true,
        headers: {
            ["Cookie"]: `${Cookie}`
        }
    }).then(async (Response) => {
        
        for (const [I, V] of Object.entries(Response.data.data)){
            TotalRobuxSpent = TotalRobuxSpent + Math.abs(V.currency.amount)
        }

        if (Response.data.nextPageCursor != null){
            await CalculateTotalRobux(Response.data.nextPageCursor)
        }else{
            Finished = true;
        }
    }).catch((Error) => {
        if (Cursor){
            CalculateTotalRobux(Cursor)
        }else{
            Finished = true;
        }
    })
};

CalculateTotalRobux("")

let Interval = null

Interval = setInterval(() => {
    if (Finished){
        console.log(TotalRobuxSpent)
        clearInterval(Interval)
    }
}, 1000);
