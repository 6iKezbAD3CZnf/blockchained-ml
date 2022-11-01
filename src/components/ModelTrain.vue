<template>
    <div>
        <div v-show="!modelLoaded">
            <h2 class="section">Please load the latest model from here</h2>
            <button class="button-wide" v-on:click="loadModel">load model!</button>
        </div>
        <div v-show="modelLoaded">
            <div class="train-controls">
                <h2 class="section">Please draw {{digitToWrite}} here!</h2>
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
            <button class="button-wide" v-on:click="drawNext">draw next</button>
            <button class="button-wide" @click="clear">clear</button>
            <button class="button-wide" v-show="has10img" v-on:click="train">Train</button>
        </div>
    </div>
</template>


<script>
import * as tf from '@tensorflow/tfjs'
import ai from './models' // global variables
import { markRaw } from 'vue';

export default {
    name: 'TensorFlowExample',
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
            // load and set global weights here!
            gModel.compile({loss: 'categoricalCrossentropy', optimizer: 'adam'});

            // making local model
            const model = tf.sequential();
            model.add(tf.layers.dense({units: 100, inputShape: 28*28}));
            model.add(tf.layers.dense({units: 10, activation: 'softmax'}));
            // load and set global weights here!
            model.compile({loss: 'categoricalCrossentropy', optimizer: 'adam'});

            // share them as global variables
            ai.model = model;
            ai.globalModel = gModel;

            //for (let i = 0; i < ai.model.getWeights().length; i++) {
                //var layer = ai.model.getWeights()[i].dataSync();
                //ai.globalWeights.push(markRaw(layer));
            //}
            this.modelLoaded = true;
        },
        submitGrad() {
            //let weightCounter = 0;
            //for (let i = 0; i < ai.model.getWeights().length; i++) {
                //const gW = ai.globalWeights[i];
                //const lW = ai.model.getWeights()[i].dataSync();
                //for (let j = 0; j < gW.length; j++) {
                    //ai.gradients.set([lW[j] - gW[j]], wCounter + j);
                //}
                //wCounter += gW.length;
            //}
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