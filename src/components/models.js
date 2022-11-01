import * as tf from '@tensorflow/tfjs'

let model = tf.sequential();
let globalModel = tf.sequential();

export default {
    model,
    globalModel,
};