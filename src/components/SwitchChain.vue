<script setup>
import { SupportedChains } from '@/constants.js'

class SwitchChain {
    initialize = async () => {
        this.button = await document.getElementById('switchChainButton');
        this.button.innerText = 'Switch Chain';
        this.button.onclick = this.addChain;
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
                    // console.error(error);
                }
            } else {
                console.error(error);
            }
        }
    }
}

window.addEventListener('DOMContentLoaded', (new SwitchChain()).initialize);
</script>

<template>
    <button id="switchChainButton"></button>
</template>
