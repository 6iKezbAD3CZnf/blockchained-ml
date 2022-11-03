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

export const contractAddress  = "0x8063A7f6Be19B46F0c04e597Efc28e2bc318A77F"

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
          "internalType": "uint32[50]",
          "name": "weights",
          "type": "uint32[50]"
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
