import { acir_from_bytes, compile } from '@noir-lang/noir_wasm';
import { setup_generic_prover_and_verifier, create_proof, verify_proof } from '@noir-lang/barretenberg/dest/client_proofs';
import path from 'path';
import { readFileSync } from 'fs';
import { expect } from 'chai';
import { ethers } from "hardhat";
import { Contract, ContractFactory } from 'ethers';

const BUILD = "build1";
const ZERO = Buffer.from("0000000000000000000000000000000000000000000000000000000000000000", "hex");
const N_EVENTS = 10;


describe('Using the solidity verifier', function () {
    let Verifier: ContractFactory;
    let verifierContract: Contract;

    before(async () => {
        Verifier = await ethers.getContractFactory("TurboVerifier");
        verifierContract = await Verifier.deploy();
    });

    it("Should verify using proof generated by typescript wrapper", async () => {
        let acirByteArray = path_to_uint8array(path.resolve(__dirname, `../circuits/build/${BUILD}.acir`));
        let acir = acir_from_bytes(acirByteArray);

        // because of basic hash fn, eventHash is 0
        const eventHash = ZERO;
        let eventFactions: Array<string> = [];
        for (let i = 0; i < N_EVENTS; i++) {
            eventFactions.push("0x0000000000000000000000000000000000000000000000000000000000000000");
        };
        const eventHashStr = `0x` + eventHash.toString('hex');

        let abi = {
            eventFactions,
            return: [eventHashStr, "0x0000000000000000000000000000000000000000000000000000000000000000"]
        }

        let [prover, verifier] = await setup_generic_prover_and_verifier(acir);

        const proof = await create_proof(prover, acir, abi);

        const verified = await verify_proof(verifier, proof);
        expect(verified).eq(true);

        const sc_verified = await verifierContract.verify(proof);
        expect(sc_verified).eq(true);
    });

});

function path_to_uint8array(path: string) {
    let buffer = readFileSync(path);
    return new Uint8Array(buffer);
}