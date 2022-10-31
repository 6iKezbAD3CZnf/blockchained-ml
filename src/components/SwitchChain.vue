<script setup>
import { SupportedChainIds, SupportedChains } from '@/constants.js'
import Web3Interface from '../web3/interface'

class SwitchChain {
    constructor() {
        this.web3Interface = new Web3Interface();
        this.web3Interface.eventEmitter.on('web3ChainUpdate', this.updateButtons);
    }

    initialize = async () => {
        await this.web3Interface.initialize();
        this.button = await document.getElementById('switchChainButton');
        this.button.onclick = this.onClickSwitchChain;
        this.updateButtons();
    }

    onClickSwitchChain = async () => {
        this.button.disabled = true;
        await this.addChain();
        this.updateButtons();
    }

    addChain = async () => {
        const chain = SupportedChains['private'];
        try {
            await ethereum.request({
                method: 'wallet_switchEthereumChain',
                params: [{ chainId: chain.chainId}],
            });
        } catch (error) {
            if (error.code === 4902) {
                try {
                    await ethereum.request({
                        method: 'wallet_addEthereumChain',
                        params: [chain],
                    });
                } catch (error) {
                    console.error(error);
                }
            } else {
                console.error(error);
            }
        }
    }

    updateButtons = () => {
        if (!this.button) {
            return;
        }

        const chainId = this.web3Interface.chainId;
        //Now we check to see if MetaMask is installed
        if (chainId === SupportedChainIds['private']) {
            this.button.disabled = true;
            this.button.innerText = SupportedChains['private'].chainName;
        } else {
            this.button.disabled = false;
            this.button.innerText = 'Switch Chain';
        }
    }
}

window.addEventListener('DOMContentLoaded', (new SwitchChain()).initialize);
</script>

<template>
    <button id="switchChainButton"></button>
</template>
