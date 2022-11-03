import * as tf from '@tensorflow/tfjs'

const numParams = 50;
const weight_layer = [40];
const bias_layer = [10];
const weightShapes = [[4, 10]];
const inputSize = 2; // input imageのreshape後の一辺の長さ
let model = tf.sequential();
let globalModel = tf.sequential();

function makeModel() {
    const model = tf.sequential();
    model.add(tf.layers.dense({units: 10, inputShape: inputSize*inputSize}));
    return model;
}

function logModels() {
    console.log(model);
}

export default {
    weight_layer,
    bias_layer,
    numParams,
    weightShapes,
    inputSize,
    model,
    globalModel,
    makeModel,
    logModels
};
