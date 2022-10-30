<script setup>
const addChain = async () => {
    const tatsuyaChainId = "0x1ad"; // 429
    const chainParam = {
        chainId: tatsuyaChainId,
        chainName: "Tatsuya's private test chain",
        nativeCurrency: {
            name: "Ethereum",
            symbol: "ETH",
            decimals: 18,
        },
        /* rpcUrls: ["https://tk2-252-35891.vs.sakura.ne.jp:8545"], */
        rpcUrls: ["http://127.0.0.1:8545"],
    };
    try {
        await ethereum.request({
            method: 'wallet_switchEthereumChain',
            params: [{ chainId: tatsuyaChainId}],
        });
    } catch (error) {
        if (error.code === 4902) {
            try {
                await ethereum.request({
                    method: 'wallet_addEthereumChain',
                    params: [chainParam],
                });
            } catch (error) {
                console.error(error);
            }
        } else {
            console.error(error);
        }
    }
};

const init = () => {
    const button = document.getElementById('switchChainButton');
    button.innerText = 'Switch Chain';
    button.onclick = addChain;
};

window.addEventListener('DOMContentLoaded', init);
</script>

<template>
    <button id="switchChainButton"></button>
</template>
