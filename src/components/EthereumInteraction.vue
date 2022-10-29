<script setup>
import MyInterface from '../web3/interface'

const Init = async () => {
    //Basic Actions Section
    const onboardButton = document.getElementById('connectButton');

    const myInterface = new MyInterface();
    await myInterface.initialize();

    const onClickInstall = async () => {
        onboardButton.disabled = true;
        await myInterface.installMetaMask();
    }

    const onClickConnect = async () => {
        onboardButton.disabled = true;
        await myInterface.connectMetaMask();
        updateButtons();
    }

    const updateButtons = () => {
        //Now we check to see if MetaMask is installed
        if (!myInterface.isMetaMaskInstalled()) {
            onboardButton.innerText = 'Click here to install MetaMask!';
            onboardButton.onclick = onClickInstall;
            onboardButton.disabled = false;
        } else if (!myInterface.isMetaMaskConnected()) {
            onboardButton.innerText = 'Connect';
            onboardButton.onclick = onClickConnect;
            onboardButton.disabled = false;
        } else {
            onboardButton.innerText = 'Connected';
            onboardButton.disabled = true;
            if (myInterface.onboarding) {
                myInterface.onboarding.stopOnboarding();
            }
        }
    };

    updateButtons();
};

window.addEventListener('DOMContentLoaded', Init);
</script>

<template>
    <button id="connectButton"></button>
</template>
