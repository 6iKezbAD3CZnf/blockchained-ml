<template>
    <base-button id="switchChain" type="primary">Switch Chain</base-button>
</template>

<script>
import { supportedChainIds, supportedChains } from '../constants.js'
import web3Interface from '../web3Interface'
import Modals from './Modals'

const addChain = async () => {
        const chain = supportedChains['private'];
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

const onClick = async () => {
    if (Modals.popUp3()) {
        return;
    }

    const button = document.getElementById('switchChain');
    button.disabled = true;
    await addChain();
    button.disabled = false;
}

const updateButtons = () => {
    const button = document.getElementById('switchChain');
    button.onclick = onClick;

    const chainId = web3Interface.chainId;
    if (chainId === supportedChainIds['private']) {
        button.disabled = true;
        button.innerText = supportedChains['private'].chainName;
    } else {
        button.disabled = false;
        button.innerText = 'Switch Chain';
    }
}

web3Interface.eventEmitter.on('web3Initialized', updateButtons);
web3Interface.eventEmitter.on('web3ChainUpdate', updateButtons);

export default {};
</script>
