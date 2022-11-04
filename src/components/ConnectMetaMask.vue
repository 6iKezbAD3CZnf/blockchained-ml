<template>
    <li class="nav-item d-lg-block ml-lg-4">
        <base-button id="connectMetaMask">MetaMask</base-button>
    </li>
</template>

<script>
import web3Interface from '../web3Interface'

const onClickInstall = async () => {
    const button = document.getElementById('connectMetaMask');
    button.disabled = true;
    await web3Interface.installMetaMask();
    button.disabled = false;
}

const onClickConnect = async () => {
    const button = document.getElementById('connectMetaMask');
    button.disabled = true;
    await web3Interface.connectMetaMask();
    button.disabled = false;
}

const updateButtons = () => {
    const button = document.getElementById('connectMetaMask');
    //Now we check to see if MetaMask is installed
    if (!web3Interface.isMetaMaskInstalled()) {
        button.innerHTML = "Click here to install MetaMask!";
        button.onclick = onClickInstall;
        button.disabled = false;
    } else if (!web3Interface.isMetaMaskConnected()) {
        button.innerHTML = 'Connect';
        button.onclick = onClickConnect;
        button.disabled = false;
    } else {
        button.innerHTML = web3Interface.accounts[0].substring(0, 8);
        button.disabled = true;
        if (web3Interface.onboarding) {
            web3Interface.onboarding.stopOnboarding();
        }
    }
}

web3Interface.eventEmitter.on('web3Initialized', updateButtons);
web3Interface.eventEmitter.on('web3AccountUpdate', updateButtons);

export default {};
</script>
