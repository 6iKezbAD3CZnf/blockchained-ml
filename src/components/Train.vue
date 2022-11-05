<template>
    <div class="col px-0">
        <Modals/>
        <div class="row justify-content-center align-items-center">
            <div class="col-lg-7 text-center pt-lg">
                <div>
                    <h2 class="display-3" v-show="!has10img">Write Here ({{digitToWrite}}/9)</h2>
                    <h2 class="display-3" v-show="has10img">Write more or let's train!</h2>
                    <h2 class="display-1">" {{digitToWrite}} "</h2>
                    <Canvas/>
                    <base-button class="button-wide mt-2" size="lg" v-on:click="drawNext">Next</base-button>
                    <base-button class="button-wide mt-2" size="lg" @click="clear">Reset</base-button>
                    <base-button class="button-wide mt-2" size="lg" @click="train">Train</base-button>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import * as tf from '@tensorflow/tfjs'
import { markRaw } from 'vue';
import mlBackend from '../mlBackend'
import Modals from './Modals'
import Canvas from './Canvas'

export default {
    name: 'Train',
    components: {
        Modals,
        Canvas
    },
    data() {
        return {
            imgs: markRaw([]),
            labels: [],
            has10img: false,
            digitToWrite: 0,
            modelLoaded: false,
            donePredicting: false,
            train: () => {
                if (Modals.popUp2()) {
                    return;
                }

                const xs = tf.concat(this.imgs, 0);
                const ys = tf.oneHot(this.labels, 10);
                mlBackend.train(xs, ys);
            },
            setWeightsGrads: mlBackend.setWeightsGrads,
            clear: Canvas.methods.clear
        }
    },
    methods: {
        async drawNext() {
            if (Modals.popUp2()) {
                return;
            }

            const canvasElement = await document.getElementById('mnistCanvas');
            const resized_img_tensor = tf.browser
                .fromPixels(canvasElement, 1)
                .toFloat()
                .resizeNearestNeighbor([mlBackend.inputSize, mlBackend.inputSize])
                .div(tf.scalar(255))
                .sub(tf.scalar(0.5))
                .expandDims()
                .reshape([1, mlBackend.inputSize*mlBackend.inputSize])

            this.imgs.push(markRaw(resized_img_tensor));
            this.labels.push(this.digitToWrite);

            this.clear()

            this.digitToWrite++;

            if (this.digitToWrite >= 10) {
                this.has10img = true;
                this.digitToWrite -= 10;
            }
        },
    }
}
</script>
