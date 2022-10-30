<template>
    <div>
        <div>
            <div class="train-controls">
                <h2 class="section clo-sm-1">Please write digits with your mouse!</h2>
                <h2 class="section clo-sm-1">You've already drawn {{numWritten}} images</h2>
                <div class="pair input">
                    <div>
                        <canvas
                            ref="canvas"
                            class="canvas"
                            :witdth="size.width"
                            :height="size.height"
                            @mousedown="handleMouseDown"
                            @mouseup="handleMouseUp"
                            @mousemove="handleMouseMove"
                        ></canvas>
                    </div>
                    <div>
                        <div>
                            <div class='button-labels' v-for="i in [0,1,2,3,4]" v-bind:key="i">
                                <button class='button-label' @click="selectLabel(i)">{{i}}</button>
                            </div>
                        </div>
                        <div>
                            <div  class='button-labels' v-for="i in [5,6,7,8,9]" v-bind:key="i">
                                <button class='button-label' @click="selectLabel(i)">{{i}}</button>
                            </div>
                        </div>

                    </div>
                </div>
            </div>
            <button class="button-add-example" v-on:click="addItem">draw next</button>
            <button class="button-train" v-on:click="train">Train</button>
            <button class="button-clear" @click="clear">clear</button>
        </div>

        <div class="predict-controls">
            <h2 class="section col-sm-1">Predicting</h2>
            <input class="field element" v-model.number="valueToPredict" type="number" placeholder="Enter an integer number"><br>
            <div class="element">{{predictedValue}}</div>
            <button class="element button--green" v-on:click="predict" :disabled="!trained">Predict</button>
        </div>
    </div>

</template>

<script>
import * as tf from '@tensorflow/tfjs'
//import DigitCanvas from './DigitCanvas.vue'

export default {
    name: 'TensorFlowExample',
    data() {
        return {
            trained: false,
            xValues: [],
            yValues: [],
            x: null,
            y: 0,
            predictedValue: 'Click on train!',
            valueToPredict: '',
            numWritten: 0,

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
      this.clear();
    },
    compress(canvas) {
        const input = tf.browser.fromPixels(this.$refs.canvas, 1)//.toFloat().resizeNearestNeighbor([28, 28])
        console.log(input.shape);
    },
    methods: {
        onImageUploaded(e) {
            const target = e.target;
            const files = target.files;
            if (files && files.length > 0) {
                const file = files[0];
                console.log("file =", file);

                var reader = new FileReader();
                reader.readAsArrayBuffer(file);
                reader.onloadend = function (evt) {
                    if (evt.target.readyState === FileReader.DONE) {
                        const arrayBuffer = evt.target.result;
                        const array = new Uint8Array(arrayBuffer);
                        console.log("array =", array);
                        console.log("array.length =", array.length);
                        console.log("array.byteLength =", array.byteLength);
                    }
                };
            }
        },
        addItem() {
            //this.xValues.push(0);
            const x = tf.browser
                .fromPixels(this.$refs.canvas, 1)
                .toFloat()
                .resizeNearestNeighbor([28, 28])
                .div(tf.scalar(255))
                .expandDims()
                .reshape([1, 28*28])
            this.xValues.push(x);
            this.yValues.push(this.y);
            console.log(this.xValues);
            console.log(this.yValues);
            this.clear()
            this.numWritten++;
        },
        train() {
            const input = tf.browser
                .fromPixels(this.$refs.canvas, 1)
                .toFloat()
                .resizeNearestNeighbor([28, 28])
                .div(tf.scalar(255))
                .expandDims()
                .reshape([1, 28*28])
            
            const model = this.model = tf.sequential();
            model.add(tf.layers.dense({units: 100, inputShape: 28*28}));
            model.add(tf.layers.dense({units: 10,
                                        activation: 'softmax'}));
            model.compile({loss: 'categoricalCrossentropy', optimizer: 'adam'});


            const xs = input;
            const ys = tf.oneHot(this.yValues, 10);
            console.log('ys')
            console.log(ys.shape)
            
            model.fit(xs, ys, {epochs: 50}).then(() => {
                this.trained = true;
                this.predictedValue = 'Ready for predictions';
            });
        },
        predict() {
            const outputTensor = this.model.predict(tf.tensor2d([this.valueToPredict], [1, 1]));
            this.predictedValue = outputTensor.dataSync()[0];
            console.log(outputTensor.dataSync());
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

            console.log('in handleMouseDown')
            console.log(this.$refs.canvas.getContext('2d'))
  
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
        selectLabel(y) {
            this.y = y;
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
.button-train {
    background: #150f81;
    width: 200px;
    height: 60px;
    color: #f6f6f5;
}
.button-label {
    background: #150f81;
    width: 100px;
    height: 100px;
    color: #f6f6f5;
    display: inline;
}
.button-add-example {
    background: #150f81;
    width: 200px;
    height: 60px;
    color: #f6f6f5;
}
.button-labels {
    background: #150f81;
    width: 100px;
    height: 100px;
    color: #f6f6f5;
    display: inline;
}

.button-clear {
    background: #150f81;
    width: 200px;
    height: 60px;
    color: #f6f6f5;
    display: inline;
}
.data-y {
    display: flex;
}
</style>