const CONTRACT_ADDRESSES = {
    ["aave-v2"]: "0x779877A7B0D9E8603169DdbD7836e478b4624789",
    ["aave-v3"]: "0x779877A7B0D9E8603169DdbD7836e478b4624789",
    ["compound"]: "0x779877A7B0D9E8603169DdbD7836e478b4624789",
    ["compound-v3"]: "0x779877A7B0D9E8603169DdbD7836e478b4624789",
}

const request = await Functions.makeHttpRequest({
    url: `https://yields.llama.fi/pools`
});

const result = request.data.data;

const apys = result.filter(el => (el.chain === "Ethereum" && (el.project === "aave-v2" || el.project === "aave-v3" || el.project === "compound" || el.project === "compound-v3") && el.symbol === "LINK")).map(el => ({ apy: el.apy, project: el.project }));

const maxApy = Math.max(...apys.map(el => el.apy));

console.log("Max APY", maxApy);

let protocolWithMaxApyAvailable = {};

apys.forEach(el => {
    console.log(el.apy, el.project);
    if (el.apy === maxApy) {
        console.log(el.apy, el.project);
        protocolWithMaxApyAvailable = el;
    }
});

let protocolAddress;

if (protocolWithMaxApyAvailable.apy > args[0]) {
    protocolAddress = CONTRACT_ADDRESSES[protocolWithMaxApyAvailable.project];
} else {
    protocolAddress = "0x0000000000000000000000000000000000000000"
}

return Buffer.from(protocolAddress.slice(2), 'hex');
