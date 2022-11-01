<template>
    <div>
        <div class="predict-controls">
            <h2 class="section">Let's measure the model performance!</h2>
            <button class="button-wide" v-on:click="predict">Predict</button>
            <h2 class="section" v-show="donePredicting">You improved the model's accuracy by {{accImproved}} %!</h2>
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
import MNIST from '../assets/small_mnist.json'

export default {
    name: 'ModelInfer',
    data() {
        return {
            //mnist: MNIST,
            accImproved: 0,
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
        predict() {
            let imglist = [];
            let labellist = [];
            MNIST.forEach(e => imglist.push(tf.tensor(e.image).div(tf.scalar(255)).reshape([1, 28*28])));
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

            this.donePredicting = true;
            this.accImproved = (myAcc - gAcc).toFixed(1);
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