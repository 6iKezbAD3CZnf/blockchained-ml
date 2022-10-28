import Web3 from "web3";
import MetaMaskOnboarding from '@metamask/onboarding'

class MyInterface {
    constructor() {
        this.forwarderOrigin = undefined;
        this.onboarding = undefined;
        this.web3 = undefined;
        this.accounts = undefined;
    }

    initialize = async () => {
        if (this.isMetaMaskInstalled()) {
            this.web3 = new Web3(window.ethereum);
            this.accounts = await this.web3.eth.getAccounts();
        }
    }

    isMetaMaskInstalled = () => {
        const { ethereum } = window;
        return Boolean(ethereum && ethereum.isMetaMask);
    };

    //This will start the onboarding proccess
    installMetaMask = () => {
        //We create a new MetaMask onboarding object to use in our app
        this.onboarding = new MetaMaskOnboarding({ forwarderOrigin: this.forwarderOrigin });
        //On this object we have startOnboarding which will start the onboarding process for our end user
        this.onboarding.startOnboarding();
    };

    connectMetaMask = async () => {
        try {
            // Will open the MetaMask UI
            // You should disable this button while the request is pending!
            await window.ethereum.request({ method: 'eth_requestAccounts' });
            this.web3 = new Web3(window.ethereum);
            this.accounts = await this.web3.eth.getAccounts();
        } catch (error) {
            console.error(error);
        }
    };

    isMetaMaskConnected = () => {
        console.log(this.accounts);
        return this.accounts && this.accounts.length > 0
    }
}

export default MyInterface;
