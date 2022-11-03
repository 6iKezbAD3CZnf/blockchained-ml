<template>
    <div>
        <div class="infer-handwrite">
            <h2>AIの予測精度を測ってみましょう！</h2>
            <canvas
                ref="canvas"
                class="canvas"
                :width="canvasSize.width"
                :height="canvasSize.height"
                @mousedown="handleMouseDown"
                @mouseup="handleMouseUp"
                @mousemove="handleMouseMove"
            ></canvas>
            <button class="button-wide" v-on:click="predictCanvas">キャンバスの数字を予測</button>
            <h2 v-show="doneCanvasInfer">loadしてきたAIの予測結果: '{{globalInferDigit}}'</h2>
            <h2 v-show="doneCanvasInfer">あなたが今成長させたAIの予測結果: '{{myInferDigit}}'</h2>
        </div>
        <div class="infer-testdata">
            <button class="button-wide" v-on:click="predictTest">100枚のテストデータで予測</button>
            <h2 v-show="doneTestInfer">あなたのお陰で、AIの予測精度は{{accImproved}} %上昇しました!</h2>
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
import MNIST from '../assets/small_mnist.json'

export default {
    name: 'ModelInfer',
    data() {
        return {
            accImproved: 0,
            doneTestInfer: false,
            doneCanvasInfer: false,
            globalInferDigit: 0,
            myInferDigit: 0,

            canvasSize: {
                width: 250,
                height: 250,
            },

            mouse: {
                x: 0,
                y: 0,
                down: false,
            },

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
        predictCanvas() {
            const input = tf.browser
                .fromPixels(this.$refs.canvas, 1)
                .toFloat()
                .resizeNearestNeighbor([ai.inputSize, ai.inputSize])
                .div(tf.scalar(255))
                .expandDims()
                .reshape([1, ai.inputSize*ai.inputSize])

            const gpred = ai.globalModel.predict(input).argMax(-1).dataSync();
            const mypred = ai.model.predict(input).argMax(-1).dataSync();

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
                                        .resizeNearestNeighbor([ai.inputSize, ai.inputSize])
                                        .div(tf.scalar(255))
                                        .reshape([1, ai.inputSize*ai.inputSize])));
            MNIST.forEach(e => labellist.push(e.label));

            const testSize = 100;

            const input = tf.concat(imglist.slice(0, testSize), 0);

            // g: global model, my: my model
            const gPreds = ai.globalModel.predict(input, {batchSize: 100}).argMax(-1).dataSync();
            const myPreds = ai.model.predict(input, {batchSize: 100}).argMax(-1).dataSync();

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