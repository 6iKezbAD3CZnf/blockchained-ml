export const supportedChainIds = {
    'private': '0x1ad'
}

export const chainIdsToNames = {
    '0x1ad': 'Private'
}

export const supportedChains = {
    'private': {
        chainId: '0x1ad', // 429
        chainName: 'Private',
        nativeCurrency: {
            name: "Ethereum",
            symbol: "ETH",
            decimals: 18,
        },
        /* rpcUrls: ["https://tk2-252-35891.vs.sakura.ne.jp:8545"], */
        rpcUrls: ["http://127.0.0.1:8545"],
    }
}

export const contractAddress  = "0x5AA456E726B89Ead9b9Ad72b681113372697c2Ec"

export const abi = [
    {
      "inputs": [],
      "stateMutability": "nonpayable",
      "type": "constructor"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "blockNumber",
          "type": "uint256"
        }
      ],
      "name": "Update",
      "type": "event"
    },
    {
      "inputs": [
        {
          "internalType": "int32[2287]",
          "name": "weights",
          "type": "int32[2287]"
        }
      ],
      "name": "update",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "get",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    }
]
