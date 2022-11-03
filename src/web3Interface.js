import { EventEmitter } from 'events';
import Web3 from "web3";
import MetaMaskOnboarding from '@metamask/onboarding'

class Web3Interface {
    constructor() {
        this.eventEmitter = new EventEmitter();

        this.forwarderOrigin = undefined;
        this.onboarding = undefined;
        this.web3 = undefined;
        this.accounts = undefined;
        this.chainId = undefined;

        window.ethereum.on('accountsChanged', this.handleAccountsChanged);
        window.ethereum.on('chainChanged', this.handleChainChanged);
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
}

const web3Interface = new Web3Interface();
web3Interface.initialize();

export default web3Interface;
