<template>
    <div class="col px-0">
        <div class="row justify-content-center align-items-center">
            <div class="col-lg-7 text-center pt-lg">
                <div>
                    <div class="train-controls">
                        <h2>AIの学習のために、 {{digitToWrite}} をここに書いてください</h2>
                        <Canvas/>
                    </div>
                    <base-button class="button-wide" v-on:click="drawNext">次の数字を書く</base-button>
                    <base-button class="button-wide" @click="clear">書き直す</base-button>
                    <base-button class="button-wide" @click="train">AIを学習させる</base-button>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import * as tf from '@tensorflow/tfjs'
import { markRaw } from 'vue';
import mlBackend from '../mlBackend'
import Canvas from './Canvas'

export default {
    name: 'Train',
    components: {
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
                const xs = tf.concat(this.imgs, 0);
                const ys = tf.oneHot(this.labels, 10);
                mlBackend.train(xs, ys);
            },
            uploadModel: mlBackend.uploadModel,
            clear: Canvas.methods.clear
        }
    },
    methods: {
        async drawNext() {
            const canvasElement = await document.getElementById('mnistCanvas');
            const resized_img_tensor = tf.browser
                .fromPixels(canvasElement, 1)
                .toFloat()
                .resizeNearestNeighbor([mlBackend.inputSize, mlBackend.inputSize])
                .div(tf.scalar(255))
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
<style scoped>
.button-wide {
    background: #150f81;
    width: 200px;
    height: 60px;
    color: #f6f6f5;
}
</style>
