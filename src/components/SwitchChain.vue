<template>
    <button id="switchChain"></button>
</template>

<script>
import { SupportedChainIds, SupportedChains } from '../constants.js'
import web3Interface from '../web3Interface'

const addChain = () => {
        const chain = SupportedChains['private'];
        try {
            ethereum.request({
                method: 'wallet_switchEthereumChain',
                params: [{ chainId: chain.chainId}],
            });
        } catch (error) {
            if (error.code === 4902) {
                try {
                    ethereum.request({
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

const onClick = () => {
    const button = document.getElementById('switchChain');
    button.disabled = true;
    addChain();
}

const updateButtons = () => {
    const button = document.getElementById('switchChain');
    button.onclick = onClick;

    const chainId = web3Interface.chainId;
    if (chainId === SupportedChainIds['private']) {
        button.disabled = true;
        button.innerText = SupportedChains['private'].chainName;
    } else {
        button.disabled = false;
        button.innerText = 'Switch Chain';
    }
}

web3Interface.eventEmitter.on('web3Initialized', updateButtons);
web3Interface.eventEmitter.on('web3ChainUpdate', updateButtons);

export default {};
</script>
