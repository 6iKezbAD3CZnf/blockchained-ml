<template>
    <div>
        <div v-show="!modelLoaded">
            <h2 class="section clo-sm-1">Please load the latest model from here</h2>
            <button class="button-wide" v-on:click="loadModel">load model!</button>
        </div>
        <div v-show="modelLoaded">
            <div class="train-controls">
                <h2 class="section clo-sm-1">Please draw {{numWritten}} here!</h2>
                <div class="pair input">
                    <div>
                        <canvas
                            ref="canvas"
                            class="canvas"
                            :width="size.width"
                            :height="size.height"
                            @mousedown="handleMouseDown"
                            @mouseup="handleMouseUp"
                            @mousemove="handleMouseMove"
                        ></canvas>
                    </div>
                </div>
            </div>
            <button class="button-wide" v-on:click="addItem">draw next</button>
            <button class="button-wide" @click="clear">clear</button>
            <button class="button-wide" v-show="has10img" v-on:click="train">Train</button>
        </div>

    </div>

</template>


<script>
import * as tf from '@tensorflow/tfjs'
import ai from './models'
import MNIST from '../assets/test_mnist.json'
import { markRaw } from 'vue';

export default {
    name: 'TensorFlowExample',
    data() {
        return {
            trained: false,
            xValues: markRaw([]),
            yValues: [],
            has10img: false,
            numWritten: 0,
            modelLoaded: false,
            mnist: MNIST,
            acc: 0,
            donePredicting: false,

            size: {
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
    mounted() {
      //this.clear();
    },
    methods: {
        addItem() {
            const x = tf.browser
                .fromPixels(this.$refs.canvas, 1)
                .toFloat()
                .resizeNearestNeighbor([28, 28])
                .div(tf.scalar(255))
                .expandDims()
                .reshape([1, 28*28])
            this.xValues.push(markRaw(x));
            this.yValues.push(this.numWritten);
            this.clear()
            this.numWritten++;
            if (this.numWritten >= 10) {
                this.has10img = true;
                this.numWritten -= 10;
            }
        },
        train() {
            const xs = tf.concat(this.xValues, 0);
            const ys = tf.oneHot(this.yValues, 10);
            ai.model.fit(xs, ys, {epochs: 50, batchSize: 10}).then(() => {
                this.trained = true;
                this.submitGrad();
            });
        },
        predict() {
            let imglist = [];
            let labellist = [];
            this.mnist.forEach(e => imglist.push(tf.tensor(e.image).div(tf.scalar(255)).reshape([1, 28*28])));
            this.mnist.forEach(e => labellist.push(e.label));

            const testSize = 100;

            const xs = tf.concat(imglist.slice(0, testSize), 0);
            const preds = ai.model.predict(xs, {batchSize: 100}).argMax(-1).dataSync();
            let corrects = 0;
            for (let i = 0; i < testSize; i++) {
                if (preds[i] == labellist[i]) {
                    corrects++;
                }
            }
            this.acc = corrects / testSize * 100;
            this.donePredicting = true;
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
        clear() {
            const ctx = this.$refs.canvas.getContext('2d');
            ctx.clearRect(0, 0, this.size.width, this.size.height);
            ctx.beginPath();
        },
        loadModel() {
            const gModel = tf.sequential();
            gModel.add(tf.layers.dense({units: 100, inputShape: 28*28}));
            gModel.add(tf.layers.dense({units: 10, activation: 'softmax'}));
            // load and set global weights here!
            gModel.compile({loss: 'categoricalCrossentropy', optimizer: 'adam'});

            const model = tf.sequential();
            model.add(tf.layers.dense({units: 100, inputShape: 28*28}));
            model.add(tf.layers.dense({units: 10, activation: 'softmax'}));
            // load and set global weights here!
            model.compile({loss: 'categoricalCrossentropy', optimizer: 'adam'});

            ai.model = model;
            ai.globalModel = gModel;
            console.log(ai.model === ai.globalModel);

            for (let i = 0; i < ai.model.getWeights().length; i++) {
                var layer = ai.model.getWeights()[i].dataSync();
                ai.globalWeights.push(markRaw(layer));
            }
            ai.modelLoaded = true;
            this.modelLoaded = true;
        },
        submitGrad() {
            let wCounter = 0;
            for (let i = 0; i < ai.model.getWeights().length; i++) {
                const gW = ai.globalWeights[i];
                const lW = ai.model.getWeights()[i].dataSync();
                for (let j = 0; j < gW.length; j++) {
                    ai.gradients.set([lW[j] - gW[j]], wCounter + j);
                }
                wCounter += gW.length;
            }
        }

    },
}
</script>

<style scoped>

.pair {
    display: flex;
}
.canvas {
    background-color: #000; /*黒背景*/
    width: 250px;
    height: 250px;
}
.field, .field-label {
    height: 30px;
    padding: 0px 15px;
    float: left;
    width: 50%;
}
.button-label {
    background: #150f81;
    width: 100px;
    height: 100px;
    color: #f6f6f5;
    display: inline;
}
.button-labels {
    background: #150f81;
    width: 100px;
    height: 100px;
    color: #f6f6f5;
    display: inline;
}
.button-wide {
    background: #150f81;
    width: 200px;
    height: 60px;
    color: #f6f6f5;
}
.data-y {
    display: flex;
}
</style>