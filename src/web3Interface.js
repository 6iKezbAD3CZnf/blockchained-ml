import { EventEmitter } from 'events';
import Web3 from "web3";
import MetaMaskOnboarding from '@metamask/onboarding'

import {
    supportedChainIds,
    supportedChains,
    contractAddress,
    abi
} from './constants.js'

class Web3Interface {
    constructor() {
        this.eventEmitter = new EventEmitter();

        this.forwarderOrigin = undefined;
        this.onboarding = undefined;
        this.web3 = undefined;
        this.accounts = undefined;
        this.chainId = undefined;
        this.contract = undefined;

        if (this.isMetaMaskInstalled()) {
            window.ethereum.on('accountsChanged', this.handleAccountsChanged);
            window.ethereum.on('chainChanged', this.handleChainChanged);
        }
    }

    initialize = async () => {
        if (this.isMetaMaskInstalled()) {
            await this.handleAccountsChanged();
            await this.handleChainChanged();
        }
        this.eventEmitter.emit('web3Initialized');
    }

    handleAccountsChanged = async () => {
        this.web3 = new Web3(window.ethereum);
        this.accounts = await this.web3.eth.getAccounts();
        this.eventEmitter.emit('web3AccountUpdate');
    }

    handleChainChanged = async () => {
        let chainId;
        await window.ethereum
            .request({ method: 'eth_chainId' })
            .then((id) => { chainId = id; })
            .catch((error) => { console.log(error); });
        this.chainId = chainId;
        this.contract = new this.web3.eth.Contract(abi, contractAddress);
        this.eventEmitter.emit('web3ChainUpdate');
    }

    isMetaMaskInstalled = () => {
        const { ethereum } = window;
        return Boolean(ethereum && ethereum.isMetaMask);
    };

    installMetaMask = async () => {
        this.onboarding = new MetaMaskOnboarding({ forwarderOrigin: this.forwarderOrigin });
        await this.onboarding.startOnboarding();
        await this.initialize();
    };

    connectMetaMask = async () => {
        try {
            // Will open the MetaMask UI
            // You should disable this button while the request is pending!
            await window.ethereum.request({ method: 'eth_requestAccounts' });
        } catch (error) {
            console.error(error);
        }
    };

    isMetaMaskConnected = () => {
        return this.accounts && this.accounts.length > 0
    }

    isChainConnected = () => {
        return this.chainId === supportedChainIds['private'];
    }

    fetchModel = async () => {
        const model = new Array(2287);

        const blockNumber = await this.contract
            .methods
            .get()
            .call();
        const events = await this.contract.getPastEvents(
            'Update',
            {
                fromBlock: blockNumber,
                toBlock: blockNumber
            },
            (error, events) => {
                return events;
            }
        );
        const txHash = events[0].transactionHash;
        const tx = await this.web3.eth.getTransaction(txHash);
        const input = tx.input;
        for (let i=0; i<2287; i++) {
            model[i] = parseInt(input.substring(10+i*64, 74+i*64), 16);
        }
        return model;
    }
}

const web3Interface = new Web3Interface();

window.addEventListener('DOMContentLoaded', () => {
    web3Interface.initialize();
});

export default web3Interface;
