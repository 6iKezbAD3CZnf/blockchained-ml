<template>
    <div class="col px-0">
        <div class="row justify-content-center align-items-center">
            <div class="col-lg-7 text-center pt-lg">
                <div>
                    <div class="train-controls">
                        <base-button @click='loadModel'>Foo</base-button>
                        <h2>AIの学習のために、 {{digitToWrite}} をここに書いてください</h2>
                        <canvas
                            ref="canvas"
                            class="canvas"
                            :width="canvasSize.width"
                            :height="canvasSize.height"
                            @mousedown="handleMouseDown"
                            @mouseup="handleMouseUp"
                            @mousemove="handleMouseMove"
                        ></canvas>
                    </div>
                    <base-button class="button-wide" v-on:click="drawNext">次の数字を書く</base-button>
                    <base-button class="button-wide" @click="clear">書き直す</base-button>
                    <base-button class="button-wide" @click="train">AIを学習させる</base-button>
                    <base-button class="button-wide" @click="submitGrad">成長したAIを送信</base-button>
                </div>
            </div>
        </div>
    </div>
</template>


<script>
import * as tf from '@tensorflow/tfjs'
import ai from './models' // global variables
import { markRaw } from 'vue';
import web3Interface from '../web3Interface'

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

            weightScaler: 1, // use when you load or submit weights

            canvasSize: {
                width: 250,
                height: 250,
            },

            mouse: {
                x: 0,
                y: 0,
                down: false,
            },
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
                .resizeNearestNeighbor([ai.inputSize, ai.inputSize])
                .div(tf.scalar(255))
                .expandDims()
                .reshape([1, ai.inputSize*ai.inputSize])

            this.imgs.push(markRaw(resized_img_tensor));
            this.labels.push(this.digitToWrite);

            this.clear()

            this.digitToWrite++;

            if (this.digitToWrite >= 10) {
                this.has10img = true;
                this.digitToWrite -= 10;
            }
        },
        train() {
            const xs = tf.concat(this.imgs, 0);
            const ys = tf.oneHot(this.labels, 10);
            ai.model.fit(xs, ys, {epochs: 50, batchSize: 10});

            const gWeights = ai.globalModel.getWeights()[0].dataSync();
            const nWeights = ai.model.getWeights()[0].dataSync();
            console.log(gWeights);
            console.log(nWeights);
            for (let i=0; i<50; i++) {
                if (gWeights[i] !== nWeights[i]) {
                    console.log(gWeights[i]);
                    console.log(nWeights[i]);
                }
            }
        },
        async loadModel() {
            console.log("loading model");
            // making global model
            const gModel = ai.makeModel();
            const model = ai.makeModel();

            let paramsArray = null;
            //serverから重みをloadする関数loadWeightsができたら、ここのfalseをtrueに。
            if (true) {
                console.log("here");
                const model = await web3Interface.fetchModel();
                console.log(model);
                paramsArray = new Float32Array(model);

                for (let i = 0; i < paramsArray.length; i++) {
                    paramsArray[i] /= this.weightScaler;
                }

                console.log(paramsArray);
            }
            else {
                paramsArray = new Float32Array(ai.numParams);
                for (let i = 0; i < paramsArray.length; i++) {
                    paramsArray[i] = Math.random();
                }
            }
            let scannedCnt = 0;
            for (let layerIdx = 0; layerIdx < ai.weight_layer.length; layerIdx++) {
                const wBegin = scannedCnt;
                const wEnd = wBegin + ai.weight_layer[layerIdx];
                const bBegin = wEnd;
                const bEnd = bBegin + ai.bias_layer[layerIdx];
                const w = tf.tensor(paramsArray.slice(wBegin, wEnd))
                            .reshape([ai.weightShapes[layerIdx][0], ai.weightShapes[layerIdx][1]]);
                const b = tf.tensor(paramsArray.slice(bBegin, bEnd));
                model.layers[layerIdx].setWeights([w, b]);
                gModel.layers[layerIdx].setWeights([w.clone(), b.clone()]);
                model.layers[layerIdx].trainable = true;
                gModel.layers[layerIdx].trainable = true;
                scannedCnt = bEnd;
            }
            gModel.compile({loss: 'categoricalCrossentropy', optimizer: 'adam'});
            model.compile({loss: 'categoricalCrossentropy', optimizer: 'adam'});

            // share them as global variables
            ai.model = model;
            ai.globalModel = gModel;

            this.modelLoaded = true;
        },
        submitGrad() {
            let wCounter = 0;
            let gradients = new Int32Array(ai.numParams);
            for (let i = 0; i < ai.model.getWeights().length; i++) {
                const gW = ai.globalModel.getWeights()[i].dataSync();
                const lW = ai.model.getWeights()[i].dataSync();
                for (let j = 0; j < gW.length; j++) {
                    const int32w = parseInt(lW[j]*this.weightScaler - gW[j]*this.weightScaler);
                    gradients.set([int32w], wCounter + j);
                }
                wCounter += gW.length;
            }
            return gradients;
        },

        // funcs below here are for canvas

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
