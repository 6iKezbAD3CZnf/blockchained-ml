<template>
    <div class="col px-0">
        <div class="row justify-content-center align-items-center">
            <div class="col-lg-7 text-center pt-lg">
                <div>
                    <div class="train-controls">
                        <h2>AIの学習のために、 {{digitToWrite}} をここに書いてください</h2>
                        <canvas
                            ref="canvas"
                            class="canvas"
                            :width="canvasSize.width"
                            :height="canvasSize.height"
                            @mousedown="handleMouseDown"
                            @mouseup="handleMouseUp"
                            @mousemove="handleMouseMove"
                            @mouseout="handleMouseOut"
                        ></canvas>
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
/* import ai from './models' // global variables */
import { markRaw } from 'vue';
import web3Interface from '../web3Interface'
import mlBackend from '../mlBackend'

export default {
    name: 'Train',
    data() {
        return {
            imgs: markRaw([]),
            labels: [],
            has10img: false,
            digitToWrite: 0,
            modelLoaded: false,
            donePredicting: false,

            canvasSize: {
                width: 250,
                height: 250,
            },

            mouse: {
                x: 0,
                y: 0,
                down: false,
            },

            train: () => {
                const xs = tf.concat(this.imgs, 0);
                const ys = tf.oneHot(this.labels, 10);
                mlBackend.train(xs, ys);
            },
            uploadModel: mlBackend.uploadModel
        }
    },
    computed: {
        currentMouse() {
            const c = this.$refs.canvas;
            const rect = c.getBoundingClientRect();

            return {
            x: this.mouse.x - rect.left,
            y: this.mouse.y - rect.top,
            };
        },
    },
    methods: {
        drawNext() {
            const resized_img_tensor = tf.browser
                .fromPixels(this.$refs.canvas, 1)
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

        draw() {
            if (this.mouse.down) {
                const ctx = this.$refs.canvas.getContext('2d');
                ctx.lineTo(this.currentMouse.x, this.currentMouse.y);
                ctx.strokeStyle = '#fff'; // 白文字
                ctx.lineWidth = 20;
                ctx.stroke();
            }
        },
        handleMouseDown(event) {
            this.mouse = {
                x: event.pageX,
                y: event.pageY,
                down: true,
            };
            const ctx = this.$refs.canvas.getContext('2d');
            ctx.moveTo(this.currentMouse.x, this.currentMouse.y);
        },
        handleMouseUp() {
            this.mouse.down = false;
        },
        handleMouseMove(event) {
            Object.assign(this.mouse, {
                x: event.pageX,
                y: event.pageY,
            });
            this.draw();
        },
        handleMouseOut() {
            this.mouse.down = false;
        },
        clear() {
            const ctx = this.$refs.canvas.getContext('2d');
            ctx.clearRect(0, 0, this.canvasSize.width, this.canvasSize.height);
            ctx.beginPath();
        },
    },
}
</script>
<style scoped>
.canvas {
    background-color: #000; /*黒背景*/
    width: 250px;
    height: 250px;
}
.button-wide {
    background: #150f81;
    width: 200px;
    height: 60px;
    color: #f6f6f5;
}
</style>
