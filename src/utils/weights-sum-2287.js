import { initialize } from 'zokrates-js'
import input from './input-2287.js'

const generateProof = async () => {
    await initialize().then((zokratesProvider) => {
        const source =
            `def main(private u32[2287] weights) -> u32 {
                u32 mut res = 0;
                for u32 i in 0..2287 {
                    res = res + weights[i];
                }
                return res;
            }`;
        const artifacts = zokratesProvider.compile(source);
        const { witness, output } = zokratesProvider.computeWitness(artifacts, [input]);
        const keypair = zokratesProvider.setup(artifacts.program);
        const proof = zokratesProvider.generateProof(artifacts.program, witness, keypair.pk);
        console.log(proof);
    });
}

generateProof();
