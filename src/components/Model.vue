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

import { initialize } from 'zokrates-js';
import zokratesSource from '!raw-loader!../../zokrates/blockchained_ml.zok'
import getHashSource from '!raw-loader!../../zokrates/get_hash.zok'
import keypairPk from '../../zokrates/keypair.pk.json'

/* const old_weights = new Array(142); */
/* for (let i=0; i<142; i++) { */
/*     old_weights[i] = "10"; */
/* } */
/* const gradient = new Array(2287); */
/* for (let i=0; i<2287; i++) { */
/*     gradient[i] = 5; */
/* } */
/* const new_weights = new Array(142); */
/* for (let i=0; i<142; i++) { */
/*     new_weights[i] = "11"; */
/* } */

const packTo64Bytes = (vector) => {
    let packedVector = new Array(142);
    for (let i=0; i<142; i++) {
        let element = "";
        for (let j=0; j<16; j++) {
            element += gradient[i*16+j].toString(16).padStart(4, '0');
        }
        packedVector[i] = BigInt("0x"+element);
    }

    return packedVector;
}

const onClick = async () => {
    if (Modals.popUp2()) {
        return;
    }

    const oldWeights = new Array(mlBackend.numParams);
    const newWeights = new Array(mlBackend.numParams);
    const gradient = new Array(mlBackend.numParams);
    mlBackend.setWeightsGrads(oldWeights, newWeights, gradient); // get new weights and gradients

    let packedOldWeights = packTo64Bytes(oldWeights);
    let packedNewWeights = packTo64Bytes(newWeights);
    let packedGradient = packTo64Bytes(gradient);
    for (let i=0; i<142; i++) {
        console.log(packedGradient[i].toString(16).padStart(64, '0'));
    }

    const zokratesProvider = await initialize();

    console.log("compiling...");
    const getHashArtifacts = await zokratesProvider.compile(getHashSource);

    const oldHash = await web3Interface.getModelHash();

    const { witness: witness1, output: rawNewHash } = await zokratesProvider.computeWitness(getHashArtifacts, [packedNewWeights]);
    const newHash = rawNewHash.substring(1, rawNewHash.length-1);

    console.log("compiling...");
    const zokratesArtifacts = await zokratesProvider.compile(zokratesSource);
    console.log(zokratesArtifacts);

    const { witness: witness2 } = await zokratesProvider.computeWitness(zokratesArtifacts, [packedGradient, newHash, oldHash, packedOldWeights]);

    console.log("generating proof...");
    const proof = zokratesProvider.generateProof(zokratesArtifacts.program, witness2, keypairPk);
    console.log(proof);
    /* const isVerified = zokratesProvider.verify(keypairVk, proof); */
    /* if (isVerified) { */
    /*     console.log("verified!"); */
    /* } */

    web3Interface.contract.methods
        .update(newWeights, proof, witness2)
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
