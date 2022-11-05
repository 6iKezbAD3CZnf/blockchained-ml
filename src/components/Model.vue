<template>
    <div class="col px-0">
        <Modals/>
        <div class="row justify-content-center align-items-center">
            <div class="col-lg-7 text-center pt-lg">
                <h1 class="display-1 mb-5">Model</h1>
                <h1/>
                <base-button @click="onClick">Push your model</base-button>
            </div>
        </div>
    </div>
</template>
<script>
import web3Interface from '../web3Interface'
import mlBackend from '../mlBackend';
import Modals from './Modals'

const input = new Array(2287);
for (let i=0; i<2287; i++) {
    input[i] = i - 50;
}

const onClick = () => {
    if (Modals.popUp2()) {
        return;
    }

    const grad = new Array(mlBackend.numParams);
    const newW = new Array(mlBackend.numParams);
    mlBackend.setWeightsGrads(newW, grad); // get new weights and gradients
    console.log('submitted weights')
    console.log(newW);

    web3Interface.contract.methods
        .update(newW)
        .send({ from: web3Interface.accounts[0] });
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
}
</script>
