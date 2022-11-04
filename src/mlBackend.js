import * as tf from '@tensorflow/tfjs'
tf.setBackend('cpu');

import web3Interface from './web3Interface'

const numParams = 2287;
const weightLayer = [14*14*11, 11*10];
const biasLayer = [11, 10];
const weightShapes = [[196, 11], [11, 10]];
const inputSize = 14; // input imageのreshape後の一辺の長さ
const weightScalar = 1;

const models = {
    globalModel: tf.sequential(),
    updatedModel: tf.sequential()
}

const train = async (xs, ys) => {
    await models.updatedModel.fit(xs, ys, {epochs: 50, batchSize: 10});
    console.log("globalModel is ..");
    console.log(models.globalModel.getWeights()[0].dataSync());
    console.log("updatedModel is ..");
    console.log(models.updatedModel.getWeights()[0].dataSync());
}

const loadModel = async () => {
    console.log("Model loading...");
    models.globalModel.add(tf.layers.dense({units: 11, inputShape: inputSize*inputSize}));
    models.globalModel.add(tf.layers.dense({units: 10, inputShape: inputSize*inputSize}));
    models.updatedModel.add(tf.layers.dense({units: 11, inputShape: inputSize*inputSize}));
    models.updatedModel.add(tf.layers.dense({units: 10, inputShape: inputSize*inputSize}));

    let paramsArray = null;
    const fetchedModel = await web3Interface.fetchModel();
    console.log(fetchedModel);
    paramsArray = new Float32Array(fetchedModel);
    for (let i = 0; i < paramsArray.length; i++) {
        paramsArray[i] /= weightScalar;
    }

    let scannedCnt = 0;
    for (let layerIdx = 0; layerIdx < weightLayer.length; layerIdx++) {
        const wBegin = scannedCnt;
        const wEnd = wBegin + weightLayer[layerIdx];
        const bBegin = wEnd;
        const bEnd = bBegin + biasLayer[layerIdx];
        const w = tf.tensor(paramsArray.slice(wBegin, wEnd))
                    .reshape([weightShapes[layerIdx][0], weightShapes[layerIdx][1]]);
        const b = tf.tensor(paramsArray.slice(bBegin, bEnd));
        models.globalModel.layers[layerIdx].setWeights([w, b]);
        models.updatedModel.layers[layerIdx].setWeights([w.clone(), b.clone()]);
        models.globalModel.layers[layerIdx].trainable = true;
        models.updatedModel.layers[layerIdx].trainable = true;
        scannedCnt = bEnd;
    }
    models.globalModel.compile({loss: 'categoricalCrossentropy', optimizer: 'adam'});
    models.updatedModel.compile({loss: 'categoricalCrossentropy', optimizer: 'adam'});
}

const uploadModel = () => {
    let wCounter = 0;
    let gradients = new Int32Array(numParams);
    for (let i = 0; i < models.updatedModel.getWeights().length; i++) {
        const gW = models.globalModel.getWeights()[i].dataSync();
        const lW = models.updateModel.getWeights()[i].dataSync();
        for (let j = 0; j < gW.length; j++) {
            const int32w = parseInt(lW[j]*weightScalar - gW[j]*weightScalar);
            gradients.set([int32w], wCounter + j);
        }
        wCounter += gW.length;
    }
    return gradients;
}

export default {
    inputSize,
    models,
    train,
    loadModel,
    uploadModel
};
