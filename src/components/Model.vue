<template>
    <div class="col px-0">
        <div class="row justify-content-center align-items-center">
            <div class="col-lg-7 text-center pt-lg">
                <h1 class="display-1">Model.</h1>
                <base-button @click="onClick">Push your model</base-button>
            </div>
        </div>
    </div>
</template>
<script>
import web3Interface from '../web3Interface'

const input = new Array(50);
for (let i=0; i<50; i++) {
    input[i] = i*5;
}

const onClick = () => {
    web3Interface.contract.methods
        .update(input)
        .send({ from: web3Interface.accounts[0] });
}

export default {
    data() {
        return {
            onClick: onClick
        };
    }
}
</script>
