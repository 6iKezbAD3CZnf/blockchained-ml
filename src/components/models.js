import * as tf from '@tensorflow/tfjs'

const weightNum = 79510;
let modelLoaded = false;
let model = tf.sequential();
let globalModel = tf.sequential();

let globalWeights = [];
let localWeights = [];
let gradients = new Float32Array(weightNum);

export default {
    modelLoaded,
    model,
    globalModel,
    globalWeights,
    localWeights,
    gradients,
};