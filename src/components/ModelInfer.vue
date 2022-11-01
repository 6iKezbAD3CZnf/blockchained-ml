<template>
    <div>
        <div v-show="modelLoaded" class="predict-controls">
            <h2 class="section col-sm-1">Let's measure the model performance!</h2>
            <button class="button-wide" v-on:click="predict">Predict</button>
            <h2 class="section clo-sm-1" v-show="donePredicting">current accuracy is {{acc}} %!</h2>
        </div>
        <div>
            <table>
            <template v-for="tr in rows" :key="tr.index">
                <tr>
                <template v-for="cell in tr.cells">

                    <!--THの場合はthタグにする-->
                    <th v-if="cell.cell_type == 'TH'">
                    <p>{{ cell.val }}</p>
                    </th>

                    <!--TDの場合はthタグにする-->
                    <td v-else-if="cell.cell_type == 'TD'">
                    <p>{{ cell.val }} %</p>
                    </td>

                </template>
                </tr>
            </template>
            </table>
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
            modelLoaded: true,
            mnist: MNIST,
            acc: 0,
            donePredicting: false,

            rows: [
                {
                    "cells": [
                        {"cell_type": "TH", "val": ""},
                        {"cell_type": "TH", "val": "global model"},
                        {"cell_type": "TH", "val": "your model"},
                    ]
                },
                {
                    "cells": [
                        {"cell_type": "TH", "val": "accuracy of '0' "},
                        {"cell_type": "TD", "val": 0},
                        {"cell_type": "TD", "val": 0},
                    ]
                },
                {
                    "cells": [
                        {"cell_type": "TH", "val": "accuracy of '1' "},
                        {"cell_type": "TD", "val": 0},
                        {"cell_type": "TD", "val": 0},
                    ]
                },
                {
                    "cells": [
                        {"cell_type": "TH", "val": "accuracy of '2' "},
                        {"cell_type": "TD", "val": 0},
                        {"cell_type": "TD", "val": 0},
                    ]
                },
                {
                    "cells": [
                        {"cell_type": "TH", "val": "accuracy of '3' "},
                        {"cell_type": "TD", "val": 0},
                        {"cell_type": "TD", "val": 0},
                    ]
                },
                {
                    "cells": [
                        {"cell_type": "TH", "val": "accuracy of '4' "},
                        {"cell_type": "TD", "val": 0},
                        {"cell_type": "TD", "val": 0},
                    ]
                },
                {
                    "cells": [
                        {"cell_type": "TH", "val": "accuracy of '5' "},
                        {"cell_type": "TD", "val": 0},
                        {"cell_type": "TD", "val": 0},
                    ]
                },
                {
                    "cells": [
                        {"cell_type": "TH", "val": "accuracy of '6' "},
                        {"cell_type": "TD", "val": 0},
                        {"cell_type": "TD", "val": 0},
                    ]
                },
                {
                    "cells": [
                        {"cell_type": "TH", "val": "accuracy of '7' "},
                        {"cell_type": "TD", "val": 0},
                        {"cell_type": "TD", "val": 0},
                    ]
                },
                {
                    "cells": [
                        {"cell_type": "TH", "val": "accuracy of '8' "},
                        {"cell_type": "TD", "val": 0},
                        {"cell_type": "TD", "val": 0},
                    ]
                },
                {
                    "cells": [
                        {"cell_type": "TH", "val": "accuracy of '9' "},
                        {"cell_type": "TD", "val": 0},
                        {"cell_type": "TD", "val": 0},
                    ]
                },
            ]

        }
    },
    methods: {
        predict() {
            let imglist = [];
            let labellist = [];
            this.mnist.forEach(e => imglist.push(tf.tensor(e.image).div(tf.scalar(255)).reshape([1, 28*28])));
            this.mnist.forEach(e => labellist.push(e.label));

            const testSize = 100;

            const xs = tf.concat(imglist.slice(0, testSize), 0);
            const gPreds = ai.globalModel.predict(xs, {batchSize: 100}).argMax(-1).dataSync();
            const myPreds = ai.model.predict(xs, {batchSize: 100}).argMax(-1).dataSync();
            let gCorrects = 0;
            let myCorrects = 0;
            let gCorrect_label = new Array(10);
            let myCorrect_label = new Array(10);
            let label_nums = new Array(10);
            gCorrect_label.fill(0);
            myCorrect_label.fill(0);
            label_nums.fill(0);
            console.log(gCorrect_label);
            for (let i = 0; i < testSize; i++) {
                const gpred = gPreds[i];
                const mypred = myPreds[i];
                const truth = labellist[i];
                label_nums[truth]++;
                if (gpred == truth) {
                    gCorrect_label[gpred]++;
                    gCorrect_label[gpred]++;
                    gCorrects++;
                }
                if (mypred == truth) {
                    myCorrect_label[mypred]++;
                    myCorrect_label[mypred]++;
                    myCorrects++;
                }
            }
            console.log(gCorrect_label);
            console.log(label_nums);
            for (let i = 0; i < 10; i++) {
                this.rows[i+1].cells[1].val = gCorrect_label[i] / label_nums[i] * 100;
                this.rows[i+1].cells[2].val = myCorrect_label[i] / label_nums[i] * 100;
            }
            this.acc = corrects / testSize * 100;
            this.donePredicting = true;
        },
        loadModel() {
            const model = tf.sequential();
            model.add(tf.layers.dense({units: 100, inputShape: 28*28}));
            model.add(tf.layers.dense({units: 10, activation: 'softmax'}));
            // load and set global weights here!
            model.compile({loss: 'categoricalCrossentropy', optimizer: 'adam'});

            ai.model = model;

            for (let i = 0; i < ai.model.getWeights().length; i++) {
                var layer = ai.model.getWeights()[i].dataSync();
                ai.globalWeights.push(markRaw(layer));
            }
            this.modelLoaded = true;
        },
    },
}
</script>

<style scoped>
table {
    border-collapse: collapse;
}
tr:nth-child(odd) {
    background-color: #ddd
}
th {
    color: #000
}
th,td {
    padding: 5px 10px
}
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