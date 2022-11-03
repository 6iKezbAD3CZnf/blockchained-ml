<template>
    <section class="section-home section-shaped my-0">
        <div class="shape shape-style-1 shape-custom">
        </div>
        <div class="container shape-container d-flex">
            <div class="col px-0">
                <div class="row justify-content-center align-items-center">
                    <div class="col-lg-7 text-center pt-lg">
                        <h1 class="display-1">Model.</h1>
                        <base-button @click="onClick">Push your model</base-button>
                    </div>
                </div>
            </div>
        </div>
    </section>
</template>
<script>
import web3Interface from '../web3Interface'

const input = new Array(50);
for (let i=0; i<50; i++) {
    input[i] = 255 + i;
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
