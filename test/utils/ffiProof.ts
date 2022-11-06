import { acir_from_bytes } from '@noir-lang/noir_wasm';
import { setup_generic_prover_and_verifier, create_proof } from '@noir-lang/barretenberg/dest/client_proofs';
import path from 'path';
import { readFileSync } from 'fs';
import { BarretenbergWasm } from '@noir-lang/barretenberg/dest/wasm';
import { SinglePedersen } from '@noir-lang/barretenberg/dest/crypto/pedersen';

export const ZERO = Buffer.from("0000000000000000000000000000000000000000000000000000000000000000", "hex");
export const N_EVENTS = 3;

let barretenberg: BarretenbergWasm;
let pedersen: SinglePedersen;

function path_to_uint8array(path: string) {
    let buffer = readFileSync(path);
    return new Uint8Array(buffer);
}

async function generateProof() {
    barretenberg = await BarretenbergWasm.new();
    await barretenberg.init()
    pedersen = new SinglePedersen(barretenberg);

    let eventHash = ZERO;
    for (let i = 0; i < N_EVENTS; i++) {
        eventHash = pedersen.compressInputs([eventHash, ZERO, ZERO, ZERO, ZERO, ZERO]);
    };
    const eventHashStr = `0x` + eventHash.toString('hex');

    let acirByteArray = path_to_uint8array(path.resolve(__dirname, `../../circuits/build/${process.argv[2]}.acir`));
    let acir = acir_from_bytes(acirByteArray);

    let abi = {
        eventFactions: ["0x0000000000000000000000000000000000000000000000000000000000000000", "0x0000000000000000000000000000000000000000000000000000000000000000", "0x0000000000000000000000000000000000000000000000000000000000000000",],
        return: [eventHashStr, parseInt(process.argv[3])]
    }

    let [prover] = await setup_generic_prover_and_verifier(acir);
    const proof = await create_proof(prover, acir, abi);
    // simple output -> easy to use by ffi
    console.log(proof.toString('hex'));
}

generateProof().then(() => process.exit(0)).catch(console.log);