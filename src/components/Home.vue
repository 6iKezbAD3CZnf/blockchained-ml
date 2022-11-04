<template>
    <div class="col px-0">
        <div class="row justify-content-center align-items-center">
            <div class="col-lg-7 text-center pt-lg">
                <h1 class="display-1">Blockchained Learning</h1>
                <p class="lead text-white mt-4 mb-5">Federated Learning on Blockchain.</p>
                <base-button @click="onClick"
                             href="https://www.creative-tim.com/product/vue-argon-design-system"
                             class="mb-3 mb-sm-0"
                             type="white">
                    Download The Latest Model
                </base-button>
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
            </div>
        </div>
    </div>
</template>

<script>
import Modal from "../argon/components/Modal.vue";
import web3Interface from '../web3Interface'

const modals = {
    installModal: false,
    connectModal: false,
    chainModal: false
}

const onClick = async () => {
    if (!web3Interface.isMetaMaskInstalled()) {
        modals.installModal = true;
    } else if (!web3Interface.isMetaMaskConnected()) {
        modals.connectModal = true;
    } else if (!web3Interface.isChainConnected()) {
        modals.chainModal = true;
    } else {
        console.log("Loading a model.");
        const model = await web3Interface.fetchModel();
        console.log(model);
    }
}

export default {
    components: {
        Modal
    },
    data() {
        return {
            modals: modals,
            onClick: onClick
        };
    }
};
</script>
