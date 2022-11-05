import { initialize } from 'zokrates-js'

const generateProof = async () => {
    await initialize().then((zokratesProvider) => {
        const source =
            `def main(private u32[4] weights) -> u32 {
                u32 mut res = 0;
                for u32 i in 0..4 {
                    res = res + weights[i];
                }
                return res;
            }`;
        const artifacts = zokratesProvider.compile(source);
        const { witness, output } = zokratesProvider.computeWitness(artifacts, [["1", "2", "3", "4"]]);
        const keypair = zokratesProvider.setup(artifacts.program);
        console.log(artifacts.program);
        console.log(witness);
        console.log(keypair.pk);
        const proof = zokratesProvider.generateProof(artifacts.program, witness, keypair.pk);
        console.log(proof);
    });
}

generateProof();
