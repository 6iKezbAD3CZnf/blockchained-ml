<template>
    <div class="col px-0">
        <Modals/>
        <div class="row justify-content-center align-items-center">
            <div class="col-lg-7 text-center pt-lg">
                <h1 class="display-1">Blockchained Learning</h1>
                <p class="lead text-white mt-4 mb-5">Federated Learning on Blockchain.</p>
                <base-button @click="onClick"
                             class="mb-3 mb-sm-0"
                             type="secondary">
                    Download The Latest Model
                </base-button>
            </div>
        </div>
    </div>
</template>

<script>
import mlBackend from '../mlBackend'
import Modals from './Modals'

const onClick = () => {
    if (Modals.popUp()) {
        return;
    }

    mlBackend.loadModel();
}

export default {
    components: {
        Modals
    },
    data() {
        return {
            onClick: onClick
        };
    }
};
</script>
