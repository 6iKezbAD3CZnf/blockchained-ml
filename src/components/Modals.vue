<template>
    <div>
        <modal :show.sync="modals.chainModal"
               gradient="warning"
               modal-classes="modal-danger modal-dialog-centered">
            <h6 slot="header" class="modal-title" id="modal-title-notification">Your blockchain network is not allowed</h6>

            <div class="py-3 text-center">
                <i class="ni ni-bell-55 ni-3x"></i>
                <h4 class="heading mt-4">Please Switch To Appropriate Network</h4>
                <p>You can select networks by clicking 'Switch' button in the above.</p>
            </div>
        </modal>
        <modal id="installModal"
               :show.sync="modals.installModal"
               gradient="primary"
               modal-classes="modal-danger modal-dialog-centered">
            <h6 slot="header" class="modal-title" id="modal-title-notification">MetaMask is NOT installed</h6>

            <div class="py-3 text-center">
                <i class="ni ni-bell-55 ni-3x"></i>
                <h4 class="heading mt-4">Please Install MetaMask</h4>
                <p>You can install MetaMask plugin by clicking 'MetaMask' button in the above.</p>
            </div>
        </modal>
        <modal :show.sync="modals.connectModal"
               gradient="primary"
               modal-classes="modal-danger modal-dialog-centered">
            <h6 slot="header" class="modal-title" id="modal-title-notification">MetaMask is NOT connected</h6>

            <div class="py-3 text-center">
                <i class="ni ni-bell-55 ni-3x"></i>
                <h4 class="heading mt-4">Please Connect MetaMask</h4>
                <p>You can connect MetaMask by clicking 'Connect' button in the above.</p>
            </div>
        </modal>
        <modal :show.sync="modals.loadModal"
               gradient="primary"
               modal-classes="modal-danger modal-dialog-centered">
            <h6 slot="header" class="modal-title" id="modal-title-notification">AI Model is NOT Loaded</h6>

            <div class="py-3 text-center">
                <i class="ni ni-bell-55 ni-3x"></i>
                <h4 class="heading mt-4">Please load an AI model first</h4>
                <p>You can load the latest model in 'HOME' tab.</p>
            </div>
        </modal>
    </div>
</template>

<script>
import web3Interface from '../web3Interface'
import mlBackend from '../mlBackend'
import Modal from '../argon/components/Modal.vue'

const modals = {
    installModal: false,
    connectModal: false,
    chainModal: false,
    loadModal: false
}

const popUp = () => {
    if (!web3Interface.isMetaMaskInstalled()) {
        modals.installModal = true;
        return true;
    } else if (!web3Interface.isMetaMaskConnected()) {
        modals.connectModal = true;
        return true;
    } else if (!web3Interface.isChainConnected()) {
        modals.chainModal = true;
        return true;
    } else {
        return false;
    }
}

const popUp2 = () => {
    if (popUp()) {
        return true;
    }

    if (!mlBackend.models.loaded) {
        modals.loadModal = true;
        return true;
    }

    return false;
}

export default {
    components: {
        Modal
    },
    data() {
        return {
            modals: modals
        }
    },
    popUp,
    popUp2
}
</script>
