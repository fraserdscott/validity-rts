import { BarretenbergWasm } from '@noir-lang/barretenberg/dest/wasm';
import { SinglePedersen } from '@noir-lang/barretenberg/dest/crypto/pedersen';

export const ZERO = Buffer.from("0000000000000000000000000000000000000000000000000000000000000000", "hex");

let barretenberg: BarretenbergWasm;
let pedersen: SinglePedersen;

async function hashEvent() {
    barretenberg = await BarretenbergWasm.new();
    await barretenberg.init()
    pedersen = new SinglePedersen(barretenberg);

    // TODO: get eventHash from process.argv[2]
    const eventHash = ZERO;

    let newEventHash = pedersen.compressInputs([eventHash, ZERO, ZERO, ZERO, ZERO, ZERO]);

    console.log(newEventHash.toString('hex'));
}

hashEvent().then(() => process.exit(0)).catch(console.log);