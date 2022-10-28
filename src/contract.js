import Web3 from "web3";

const detectCurrentProvider = () => {
    let provider;
    if (window.ethereum) {
        provider = window.ethereum;
    } else if (window.web3) {
        provider = window.web3.currentProvider;
    } else {
        console.log(
            'Non-Ethereum browser detected. You should consider trying MetaMask!'
        );
    }
    return provider;
};

const web3Init = async (provider) => {
    try {
        const web3 = new Web3(provider);
        const userAccount = await web3.eth.getAccounts();
        const chainId = await web3.eth.getChainId();
        const account = userAccount[0];
        // let ethBalance = await web3.eth.getBalance(account); // Get wallet balance
        // ethBalance = web3.utils.fromWei(ethBalance, 'ether'); //Convert balance to wei
        const abi = [
            {
              "inputs": [
                {
                  "internalType": "uint64[4][]",
                  "name": "grad",
                  "type": "uint64[4][]"
                }
              ],
              "name": "update",
              "outputs": [],
              "stateMutability": "nonpayable",
              "type": "function",
              "payable": true
            },
            {
                "inputs": [],
                "name": "get",
                "outputs": [
                    {
                        "internalType": "uint64[4]",
                        "name": "",
                        "type": "uint64[4]"
                    }
                ],
                "stateMutability": "view",
                "type": "function",
                "constant": true
            }
        ];
        const address = "0x871213Ef99832B46F4672e1aa2143c3A79Feb45d";
        const contract = new web3.eth.Contract(abi, address);
        contract.methods
            .get()
            .call()
            .then(console.log);
        await contract.methods
            .update([[1, 2, 3, 4]])
            .send({ from: account });
        contract.methods
            .get()
            .call()
            .then(console.log);
        //debug
        // console.log(ethBalance);

        // saveUserInfo(ethBalance, account, chainId);
        // if (userAccount.length === 0) {
        //     console.log('Please connect to meta mask');
        // }
    } catch(e) {
        console.log(e);
    }
};

export default web3Init;
