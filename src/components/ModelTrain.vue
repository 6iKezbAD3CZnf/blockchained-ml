<template>
    <div>
        <div v-show="!modelLoaded">
            <h2>まずは最新のAIをloadしましょう</h2>
            <button class="button-wide" v-on:click="loadModel">load AI</button>
        </div>
        <div v-show="modelLoaded">
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
                ></canvas>
            </div>
            <button class="button-wide" v-on:click="drawNext">次の数字を書く</button>
            <button class="button-wide" @click="clear">書き直す</button>
            <button class="button-wide" v-show="has10img" v-on:click="train">AIを学習させる</button>
            <button class="button-wide" @click="submitGrad">成長したAIを送信</button>
        </div>
    </div>
</template>


<script>
import * as tf from '@tensorflow/tfjs'
import ai from './models' // global variables
import { markRaw } from 'vue';

export default {
    name: 'ModelTrain',
    data() {
        return {
            imgs: markRaw([]),
            labels: [],
            has10img: false,
            digitToWrite: 0,
            modelLoaded: false,
            donePredicting: false,

            weightScaler: 1000000, // use when you load or submit weights

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
                .resizeNearestNeighbor([28, 28])
                .div(tf.scalar(255))
                .expandDims()
                .reshape([1, 28*28])

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
        },
        loadModel() {
            // making global model
            const gModel = tf.sequential();
            gModel.add(tf.layers.dense({units: 100, inputShape: 28*28}));
            gModel.add(tf.layers.dense({units: 10, activation: 'softmax'}));

            const model = tf.sequential();
            model.add(tf.layers.dense({units: 100, inputShape: 28*28}));
            model.add(tf.layers.dense({units: 10, activation: 'softmax'}));

            // load and set global weights here!
            let paramsArray = null;

            //serverから重みをloadする関数loadWeightsができたら、ここのfalseをtrueに。
            if (false) {
                paramsArray = new Float32Array(loadWeights());

                for (let i = 0; i < paramsArray.length; i++) {
                    paramsArray[i] /= this.weightScaler;
                }
            }
            else {
                paramsArray = new Float32Array(79510);
                for (let i = 0; i < paramsArray.length; i++) {
                    paramsArray[i] = Math.random();
                }
            }
            const weight_layer = [78400, 1000]; // number of weights per layer
            const bias_layer = [100, 10]; // number of biases per layer
            const weight_shapes = [[784, 100], [100, 10]];
            let scannedCnt = 0;
            for (let layerIdx = 0; layerIdx < 2; layerIdx++) {
                const wBegin = scannedCnt;
                const wEnd = wBegin + weight_layer[layerIdx];
                const bBegin = wEnd;
                const bEnd = bBegin + bias_layer[layerIdx];
                const w = tf.tensor(paramsArray.slice(wBegin, wEnd))
                            .reshape([weight_shapes[layerIdx][0], weight_shapes[layerIdx][1]]);
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
            let gradients = new Int32Array(79510);
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