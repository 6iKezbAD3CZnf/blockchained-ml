<script setup>
import Web3Interface from '../web3/interface'

class ConnectMetaMask {
    constructor() {
        this.web3Interface = new Web3Interface();
        if (this.web3Interface.isMetaMaskInstalled()) {
            window.ethereum.on('accountsChanged', this.updateButtons);
            window.ethereum.on('chainChanged', this.updateButtons);
        }
    }

    initialize = async () => {
        this.button = await document.getElementById('connectButton');
        await this.web3Interface.initialize();
        this.updateButtons();
    }

    onClickInstall = async () => {
        this.button.disabled = true;
        await this.web3Interface.installMetaMask();
    }

    onClickConnect = async () => {
        this.button.disabled = true;
        await this.web3Interface.connectMetaMask();
        this.updateButtons();
    }

    updateButtons = () => {
        //Now we check to see if MetaMask is installed
        if (!this.web3Interface.isMetaMaskInstalled()) {
            this.button.innerText = 'Click here to install MetaMask!';
            this.button.onclick = this.onClickInstall;
            this.button.disabled = false;
        } else if (!this.web3Interface.isMetaMaskConnected()) {
            this.button.innerText = 'Connect';
            this.button.onclick = this.onClickConnect;
            this.button.disabled = false;
        } else {
            this.button.innerText = this.web3Interface.accounts[0];
            this.button.disabled = true;
            if (this.web3Interface.onboarding) {
                this.web3Interface.onboarding.stopOnboarding();
            }
        }
    }
}

window.addEventListener('DOMContentLoaded', (new ConnectMetaMask()).initialize);
</script>

<template>
    <button id="connectButton"></button>
</template>
