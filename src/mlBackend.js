import * as tf from '@tensorflow/tfjs'
tf.setBackend('cpu');

import web3Interface from './web3Interface'

const numParams = 2287;
const weightLayer = [14*14*11, 11*10];
const biasLayer = [11, 10];
const weightShapes = [[196, 11], [11, 10]];
const inputSize = 14; // input imageのreshape後の一辺の長さ
const weightScalar = 100000000;
const isDevelopping = false;

const models = {
    loaded: false,
    globalModel: tf.sequential(),
    updatedModel: tf.sequential()
}

const train = async (xs, ys) => {
    await models.updatedModel.fit(xs, ys, {epochs: 100, batchSize: 10});
    console.log("globalModel is ..");
    console.log(models.globalModel.getWeights()[0].dataSync());
    console.log("updatedModel is ..");
    console.log(models.updatedModel.getWeights()[0].dataSync());
}

function normalDistribution(mean, sd){
    var x = Math.random();
    var y = Math.random();
    var z = Math.sqrt(-2*Math.log(1 - x))*Math.cos(2 * Math.PI  * y);
    return z * sd + mean;
}

const loadModel = async () => {
    console.log("Model loading...");
    models.globalModel.add(tf.layers.dense({units: 11, inputShape: inputSize*inputSize, activation: 'relu'}));
    models.globalModel.add(tf.layers.dense({units: 10, activation: 'softmax'}));
    models.updatedModel.add(tf.layers.dense({units: 11, inputShape: inputSize*inputSize, activation: 'relu'}));
    models.updatedModel.add(tf.layers.dense({units: 10, activation: 'softmax'}));

    let paramsArray = null;
    let fetchedModel = null;
    if (isDevelopping) {
        fetchedModel = new Array(2287);
        let idx = 0;
        for (let _=0; _<14*14*11; _++) {
            const randomFloat = normalDistribution(0, Math.sqrt(2 / (14*14*11)));
            fetchedModel[idx] = parseInt(weightScalar * randomFloat);
            idx++;
        }
        for (let _=0; _<11; _++) {
            fetchedModel[idx] = 0;
            idx++;
        }
        for (let _=0; _<11*10; _++) {
            const randomFloat = normalDistribution(0, Math.sqrt(2 / (11*10)));
            fetchedModel[idx] = parseInt(weightScalar * randomFloat);
            idx++;
        }
        for (let _=0; _<10; _++) {
            fetchedModel[idx] = 0;
            idx++;
        }
    }
    else {
        fetchedModel = await web3Interface.fetchModel();
    }
    console.log('received weights:')
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
    models.loaded = true;
}

const setWeightsGrads = (oldWeights, newWeights, gradients) => {
    let wCounter = 0;
    for (let i = 0; i < models.updatedModel.getWeights().length; i++) {
        const gW = models.globalModel.getWeights()[i].dataSync();
        const lW = models.updatedModel.getWeights()[i].dataSync();
        for (let j = 0; j < gW.length; j++) {
            const int32grad = parseInt(lW[j]*weightScalar - gW[j]*weightScalar);
            gradients[wCounter + j] = int32grad;
            oldWeights[wCounter + j] = parseInt(gW[j]*weightScalar);
            newWeights[wCounter + j] = parseInt(lW[j]*weightScalar);
        }
        wCounter += gW.length;
    }
}

export default {
    numParams,
    inputSize,
    models,
    train,
    loadModel,
    setWeightsGrads
};
