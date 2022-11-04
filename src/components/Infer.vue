<template>
    <div class="container ct-example-row">
        <div class="row">
            <div class="col">
                <div class="text-center pt-lg">
                    <div class="infer-handwrite">
                        <h2>AIの予測精度を測ってみましょう！</h2>
                        <Canvas/>
                        <base-button class="button-wide" v-on:click="predictCanvas">キャンバスの数字を予測</base-button>
                        <base-button class="button-wide" @click="clear">書き直す</base-button>
                        <h2 v-show="doneCanvasInfer">loadしてきたAIの予測結果: '{{globalInferDigit}}'</h2>
                        <h2 v-show="doneCanvasInfer">あなたが今成長させたAIの予測結果: '{{myInferDigit}}'</h2>
                    </div>
                </div>
            </div>
            <div class="col">
                <div class="text-center pt-lg">
                    <div class="infer-testdata">
                        <base-button class="button-wide" v-on:click="predictTest">Test</base-button>
                        <h2/>
                        <!--
                        <h2>あなたのお陰で、AIの予測精度は{{accImproved}} %上昇しました!</h2>
                        -->
                        <table class="table table-sm">
                          <thead>
                            <tr>
                              <th scope="col">#</th>
                              <th scope="col">Global Model</th>
                              <th scope="col">Updated Model</th>
                            </tr>
                          </thead>
                          <tbody>
                            <tr>
                              <th scope="row">Total</th>
                              <td>{{ rows[1].cells[1].val }}</td>
                              <td>{{ rows[1].cells[2].val }}</td>
                            </tr>
                            <tr>
                              <th scope="row">0</th>
                              <td>{{ rows[2].cells[1].val }}</td>
                              <td>{{ rows[2].cells[2].val }}</td>
                            </tr>
                            <tr>
                              <th scope="row">1</th>
                              <td>{{ rows[3].cells[1].val }}</td>
                              <td>{{ rows[3].cells[2].val }}</td>
                            </tr>
                            <tr>
                              <th scope="row">2</th>
                              <td>{{ rows[4].cells[1].val }}</td>
                              <td>{{ rows[4].cells[2].val }}</td>
                            </tr>
                            <tr>
                              <th scope="row">3</th>
                              <td>{{ rows[5].cells[1].val }}</td>
                              <td>{{ rows[5].cells[2].val }}</td>
                            </tr>
                            <tr>
                              <th scope="row">4</th>
                              <td>{{ rows[6].cells[1].val }}</td>
                              <td>{{ rows[6].cells[2].val }}</td>
                            </tr>
                            <tr>
                              <th scope="row">5</th>
                              <td>{{ rows[7].cells[1].val }}</td>
                              <td>{{ rows[7].cells[2].val }}</td>
                            </tr>
                            <tr>
                              <th scope="row">6</th>
                              <td>{{ rows[8].cells[1].val }}</td>
                              <td>{{ rows[8].cells[2].val }}</td>
                            </tr>
                            <tr>
                              <th scope="row">7</th>
                              <td>{{ rows[9].cells[1].val }}</td>
                              <td>{{ rows[9].cells[2].val }}</td>
                            </tr>
                            <tr>
                              <th scope="row">8</th>
                              <td>{{ rows[10].cells[1].val }}</td>
                              <td>{{ rows[10].cells[2].val }}</td>
                            </tr>
                            <tr>
                              <th scope="row">9</th>
                              <td>{{ rows[11].cells[1].val }}</td>
                              <td>{{ rows[11].cells[2].val }}</td>
                            </tr>
                          </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import * as tf from '@tensorflow/tfjs'
import MNIST from '../assets/small_mnist.json'
import mlBackend from '../mlBackend'
import Canvas from './Canvas'

export default {
    name: 'Infer',
    components: {
        Canvas
    },
    data() {
        return {
            accImproved: 0,
            doneTestInfer: false,
            doneCanvasInfer: false,
            globalInferDigit: 0,
            myInferDigit: 0,

            clear: Canvas.methods.clear,

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
                        {"cell_type": "TH", "val": "total accuracy "},
                        {"cell_type": "TD", "val": 0},
                        {"cell_type": "TD", "val": 0},
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
        async predictCanvas() {
            const canvasElement = await document.getElementById('mnistCanvas');
            const input = tf.browser
                .fromPixels(canvasElement, 1)
                .toFloat()
                .resizeNearestNeighbor([mlBackend.inputSize, mlBackend.inputSize])
                .div(tf.scalar(255))
                .expandDims()
                .reshape([1, mlBackend.inputSize*mlBackend.inputSize])

            const gpred = mlBackend.models.globalModel.predict(input).argMax(-1).dataSync();
            const mypred = mlBackend.models.updatedModel.predict(input).argMax(-1).dataSync();

            this.globalInferDigit = gpred;
            this.myInferDigit = mypred;
            this.doneCanvasInfer = true;
        },
        predictTest() {
            let imglist = [];
            let labellist = [];
            const originSize = 28;
            MNIST.forEach(e => imglist.push(
                                        tf.tensor(e.image)
                                        .reshape([originSize, originSize, 1])
                                        .resizeNearestNeighbor([mlBackend.inputSize, mlBackend.inputSize])
                                        .div(tf.scalar(255))
                                        .reshape([1, mlBackend.inputSize*mlBackend.inputSize])));
            MNIST.forEach(e => labellist.push(e.label));

            const testSize = 100;

            const input = tf.concat(imglist.slice(0, testSize), 0);

            // g: global model, my: my model
            const gPreds = mlBackend.models.globalModel.predict(input, {batchSize: 100}).argMax(-1).dataSync();
            const myPreds = mlBackend.models.updatedModel.predict(input, {batchSize: 100}).argMax(-1).dataSync();

            let gCorrects = 0; // 総正解数
            let myCorrects = 0;

            let gCorrect_label = new Array(10); // labelごとの正解数
            let myCorrect_label = new Array(10);
            let label_nums = new Array(10); // test data中のlabelごとのデータ数
            gCorrect_label.fill(0);
            myCorrect_label.fill(0);
            label_nums.fill(0);

            for (let i = 0; i < testSize; i++) {
                const gpred = gPreds[i];
                const mypred = myPreds[i];
                const truth = labellist[i];
                label_nums[truth]++;

                if (gpred == truth) {
                    gCorrect_label[gpred]++;
                    gCorrects++;
                }
                if (mypred == truth) {
                    myCorrect_label[mypred]++;
                    myCorrects++;
                }
            }
            for (let i = 0; i < 10; i++) { //正解率を計算して表のセルに代入
                this.rows[i+2].cells[1].val = (gCorrect_label[i] / label_nums[i] * 100).toFixed(1);
                this.rows[i+2].cells[2].val = (myCorrect_label[i] / label_nums[i] * 100).toFixed(1);
            }

            const gAcc = gCorrects / testSize * 100;
            const myAcc = myCorrects / testSize * 100;

            this.rows[1].cells[1].val = gAcc.toFixed(1);
            this.rows[1].cells[2].val = myAcc.toFixed(1);

            this.doneTestInfer = true;
            this.accImproved = (myAcc - gAcc).toFixed(1);
        },
    }
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
.button-wide {
    background: #150f81;
    width: 200px;
    height: 60px;
    color: #f6f6f5;
}
</style>
