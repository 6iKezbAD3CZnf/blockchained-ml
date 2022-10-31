import * as tf from '@tensorflow/tfjs'

const weightNum = 79510;
let model = tf.sequential();

let globalWeights = [];
let localWeights = [];
let gradients = new Float32Array(weightNum);

export default {
    model,
    globalWeights,
    localWeights,
    gradients,
};