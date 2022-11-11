// This file is MIT Licensed.
//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
pragma solidity ^0.8.0;
library Pairing {
    struct G1Point {
        uint X;
        uint Y;
    }
    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }
    /// @return the generator of G1
    function P1() pure internal returns (G1Point memory) {
        return G1Point(1, 2);
    }
    /// @return the generator of G2
    function P2() pure internal returns (G2Point memory) {
        return G2Point(
            [10857046999023057135944570762232829481370756359578518086990519993285655852781,
             11559732032986387107991004021392285783925812861821192530917403151452391805634],
            [8495653923123431417604973247489272438418190587263600148770280649306958101930,
             4082367875863433681332203403145435568316851327593401208105741076214120093531]
        );
    }
    /// @return the negation of p, i.e. p.addition(p.negate()) should be zero.
    function negate(G1Point memory p) pure internal returns (G1Point memory) {
        // The prime q in the base field F_q for G1
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0)
            return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }
    /// @return r the sum of two points of G1
    function addition(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {
        uint[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
    }


    /// @return r the product of a point on G1 and a scalar, i.e.
    /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
    function scalar_mul(G1Point memory p, uint s) internal view returns (G1Point memory r) {
        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require (success);
    }
    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bool) {
        require(p1.length == p2.length);
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[1];
            input[i * 6 + 3] = p2[i].X[0];
            input[i * 6 + 4] = p2[i].Y[1];
            input[i * 6 + 5] = p2[i].Y[0];
        }
        uint[1] memory out;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
        return out[0] != 0;
    }
    /// Convenience method for a pairing check for two pairs.
    function pairingProd2(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for three pairs.
    function pairingProd3(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](3);
        G2Point[] memory p2 = new G2Point[](3);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for four pairs.
    function pairingProd4(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2,
            G1Point memory d1, G2Point memory d2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p1[3] = d1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        p2[3] = d2;
        return pairing(p1, p2);
    }
}

contract BlockchainedML {
    uint64 private constant SIZE = 2287;

    uint blockNumber;
    uint modelHash;

    event Update(uint blockNumber);

    using Pairing for *;
    struct VerifyingKey {
        Pairing.G1Point alpha;
        Pairing.G2Point beta;
        Pairing.G2Point gamma;
        Pairing.G2Point delta;
        Pairing.G1Point[] gamma_abc;
    }
    struct Proof {
        Pairing.G1Point a;
        Pairing.G2Point b;
        Pairing.G1Point c;
    }
    function verifyingKey() pure internal returns (VerifyingKey memory vk) {
        vk.alpha = Pairing.G1Point(uint256(0x10bc22ae629c4ad38474d2cdebae0d9e8d226f3cb745699a0dcbac863e13e6f6), uint256(0x1cd134db21667b4aaa058cf638139fc9dc5dc347181e77ddbcd24381a103271e));
        vk.beta = Pairing.G2Point([uint256(0x29548a6795247c2a782b7f04262d1ed8bc67fbf5545ffb81ab0d4718450ee737), uint256(0x22fe3ac8e4b28481a552769f817847f112beed503f3c5ed6837bb8c4a1a8a651)], [uint256(0x16fbcd29f9d4dbfd3247f312e5eacfa9e89249c0c19904fb80b50d3f18abf800), uint256(0x1508e87dcacb84641df9dbda76138ae46b2a62453c200f740b64e110d893502e)]);
        vk.gamma = Pairing.G2Point([uint256(0x10d41f1eee718e927040705b96c9e43c0a000457c0de9a4363bb1ae59ec9cab4), uint256(0x03dc430de155f603cb8e465f5cca9c6a1cb6512ebcde4489fa363693a914af8e)], [uint256(0x0601df618e1d441693fd4537b0614dc4017311e972e0f3ac7d1e5d790a3d600e), uint256(0x0624fb19dd47fdcc23ef8c79deccbf1f7947efdb3c5662fe69a0936303981b85)]);
        vk.delta = Pairing.G2Point([uint256(0x19191f509b8183ad4f55fd627b7b0125bd0d5ef5adc0a53854d534eebb34518a), uint256(0x226c45d53ac2cba6dbc5adbc59c6abf74c2a4f8fd470b2c6c5ee1b5a06a90aea)], [uint256(0x12e1739bbc41284b408e06e9fff25654f40ad3379c4ee54bb0eb23a2d901afee), uint256(0x13a79206022c3f306da366daf04e306a0c78bccd9ede767fd6ab41551bf2ea00)]);
        vk.gamma_abc = new Pairing.G1Point[](145);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x26bf50b018fb97d56d8bf377b60da25e2113f88cbe8c72e1709d03dd05737d6e), uint256(0x106de85679fe15aff254585fc2e6d5663baa7a577e3e3abc17e6610b68e8961f));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x2f2f68198271e85bb342c507dba853f202781fe72753796cc6783bb15afbecc7), uint256(0x0046e660c961eb587a2d8888319eff3f9ce113b363e31905ef25dea59b3f3b43));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x2d39b3dc87af3b5a38310bc60555fdab932fa4cdc774bb8ac243e0d695071901), uint256(0x223a86e07bb7155afa4c6723e25305db7f03bc002fc97e7b77635c4ad22e42d6));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x1d55ea057c3a38921b3a93f081410b5c8d6cda2152d72c344ec2be9114ed209f), uint256(0x15287e959cf637aaab98fcacfece956729c0968b205ed24f6222f78410050fce));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x169b73b85e27ad296dd2978ca6f35362cfacc71656f3eb97da30a1af871b4692), uint256(0x251e375b5b4e1bbdc9e0d5665ed90d6d844e84c565f5e7c0d0f383234bab7ea0));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x2fc00b72a35908696e0923b1327386b335ef7392056c33cc2cd3eb1efc68ebf4), uint256(0x05ffaefd3978676b488dd96300fac5d7f1a1f9d07e9cbf6fcce891ebf0fb0397));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x0732d30d8be20c7432f6f311037e2addf2c2d7837162c6f3551118366b901cff), uint256(0x0640332de2b2ffd00758f45bcbc7f567233dca1b6e9dd95cf2ee08b23cc5b726));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x2e403c42fb772c5cdc9a0c37dc1ed9781defe3fb021c125a0ba6483aaacb86dc), uint256(0x0d4643da6e87537fec3bab93b3653d59848d5ffe8ea06d6dbe69cb51a1a46db3));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x0b667f81ffdd4c03620b31b5ab45add1f4225956cc446e548a1f1f26826f50a0), uint256(0x2908a4711ef49e573f6fd7b7ce24b20c679b82b53f35c190257c790f4eb2de2f));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x1662fbc5a2943c8d14a8fdb214e7aa593493c8dd9a717f193bfc30c00edc560e), uint256(0x0d37499500187887b605bc71e5abe839d9a0a0c4363102d84b80a833b6a3506d));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x1fd979ee6280610017d6a9ada85667517d233f2259c18bb95723fdf82d39f058), uint256(0x291a6287b998e6026b8eb198fc7b41db1481270f9d2d5a3b873223854ccd012d));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x137839bc09f41b7e013e8ba639cfa294a90284384036c539d470e90e990bde07), uint256(0x0c9d6be7623974cf2247c316e1377c40967840f663ffd5d874c21f0b2f28fdd3));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x0ec160cd3895e6b89603dc0ff31e043eef00d1aedff745ef72c1f897c95f7bf7), uint256(0x2a06b61f2c58c0c8ecc8d337d3895a67b7ad6cde251352e45296c31be01898b3));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x01b3c646e1f84643a954c5c61610c3f39f6d5c5bfb59da26838b5c96d8102cf4), uint256(0x229c012612d7a510683ba135f0baf60189e26a1266e25a4541e69fd3bc9b2d78));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x2b1cab8886e29765106129076d29cae3222e3ab1e2d872372411d766f1d7aa0d), uint256(0x231d8e6bebe061ccc3a0779f222f23ca5f1f6296b4bd1a6d6b40011980790ec3));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x28d97cf93e3640d36ce1b7f6a65d1f975076d7ad5d8c7d84b7fa2fde4141b8b2), uint256(0x0497c0d0891fb896f2a7376650185f24d3fa2e31c5eb1aff76bbd2e67ec02b85));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x105e254dffa8442f805bc4c35e07a662856b54239f68b7805bacfe6507d6ab37), uint256(0x0ce6dc1f8fe6c2d40b9c8778bffbde2b0eb5658fcb1570c0caf4cd513605b9d6));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x2763f00553bfcd1fa6bb3eb61e0a66808039d1bf98104a5900008add58bccf20), uint256(0x24cbe8a5616ff56ac0b831c1c4a6fea3cfa6fd9bbe1462f6915b6631fa06e9d5));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x04c57fb5574d76d60d3a8f3563ef364333ee55c80755fdfb679cd088da37d9f8), uint256(0x287c7d2c2de83634edab8917d240e93c1b8a9cd2591b29f00bec43267401746c));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x1eacfaf3907954e61117a1add396987dcc5d7286f4366334d5423f5d88b86d5e), uint256(0x29348f768aebbb6f7c5f3f89afd35198dd9bb5666d890f535469eae6a5de2c07));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x0693132e7ea625761d835ab708fb2444cdaea568ef4ade67acc790f3be3a0c14), uint256(0x1226195d5f310de8e57453b17ef7f575bb39deb76cae0b14e2e70e92e4d0bf80));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x1e7242ed58f3831a5270e16ae9e2f1a7b32e062bfe30338aabc005144e4556fd), uint256(0x22ceaced87efaa6722caee4efca58bb1717c9230e2441128a2d3135a4d30d547));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x0a58e5879db53844c2ad8530ecb9d109932cc18a9fe39e2c919b910f34c6f4bb), uint256(0x2b4803f808fe8f12086028c561e2fe1f28beb8d0291dec76228df794601eccd1));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x1b7f356de64053f24bcfd23e0a576bb66a35f6a6a9916e412bde6097e758cf6a), uint256(0x13a58795b873bcb7e4c05a0f5801e531b52ffc14987b570443cc35bd2097086e));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x0a1606d7f9159586c9a7871e97c64d6f533b3ef7b496f90f825294e1ddf7721d), uint256(0x2967c1289e8f3bd7e6460939989b26ee73f26d66ba52ab3c72091730446d693c));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x2baa79dbf68947799900c7849204e5bcedafc2bd8390ab8dbba88e81b0aa6aee), uint256(0x0d7a6bc6235e78de9198cd2e4e8efab81c3a75d410f67f416cac709f9b15f823));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x2f00e29eefd8178b0b5020c5fa6468c32c0ebe2de2ce91685352da94dea6e064), uint256(0x027a5c3a1927412397c5dd41a814226dc59a220584b79903b09949d6c0d7fce4));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x120fa18ea3ff6aa2b2c10bd698166b2a2f5c659d1f512fe4692cfd7ee7ec6c73), uint256(0x2c4150576378f01f2d6eab338bb86d3294aae66f676b3401415b043b6d7bea21));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x029e193f50e5c597c919bf4f47de9d9315cfa60c3c38463098ec9e148bc0188f), uint256(0x21821a5e7b8564a39734a96e6de77ed34595e5feda0b178a0783b8bc2a164e60));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x05c6b2c53ce7a54bb9a244e39d4636601d7285eecbdbb9760a2777924ca1e77e), uint256(0x2dad1e9c426e0ebc0e2c89c0be846912785334e5a49d890382f05f9531a427b0));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x039bb1a42b55ab680db1dfabedf12a19eda08a016b6408b6445b7325503009fc), uint256(0x0b48876b2004fa6a3e551b2ea2d24ec7fd5aa5acc3020f58a7fe08be43a72d15));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x04640e84d6926383b3ba32226c4c02973de685aeaeb6be97dd4fb42186559bf2), uint256(0x139cf8e732523200eaa2bde6fa329432dcc8c79ebbda98e7e1183cc090713be1));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x1337a6afbc5b7eaa1f9d2a75df33b5c945f5c1e9398291a81b5a51c1bbaa15b5), uint256(0x0068238ab63ca2d82f1c92ed4bc3fb32264f51051a6a672a9fe66a72574d9f51));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x1094473a68263d8c4a6d59451628f1c3bdd312e07187ba13716a1bd49872827b), uint256(0x011ddeb5cb0536c943e84086d22c44ca244692ed3a53fad2c488b06676160c11));
        vk.gamma_abc[34] = Pairing.G1Point(uint256(0x06c99c390b9c23548f66ebb2d20727d74ccc7bc6c5a6fae41e55fdae96ee12e9), uint256(0x1331edad2c9853920aaeed7f06c7d15805e5ef820a21858dc49c0a1d629ace16));
        vk.gamma_abc[35] = Pairing.G1Point(uint256(0x1d4012279f68ca63437661bf9134c079cd1cfd771debdd8e5a6ef12e3244ecb8), uint256(0x0fafdc55d9524e8feae054a0e21ed53da2b0fc1e4620e5e18c055c682e5de92f));
        vk.gamma_abc[36] = Pairing.G1Point(uint256(0x1e13889aa48f1e4b8cc29e14233154f9bcf15ce8767a2567f6ba4f358aa7ea4a), uint256(0x1ff75e47607729e28f7a96de7c697d584201af2f2680e36955ba16261684d06f));
        vk.gamma_abc[37] = Pairing.G1Point(uint256(0x12277f32d252424d6b555eb6c5bc445829b166c52458d17687db83fd8c8c0108), uint256(0x11b2f77318123e4cec7bd703914da84021454059a467d78afed4c16b3897f4d5));
        vk.gamma_abc[38] = Pairing.G1Point(uint256(0x12a26264ed89a0b44bbddc9ff0bd9e70d84ecf23bbd4cba30d82d57ec55ae4ee), uint256(0x009155a995e60cb2540c0322d7d3eb867d29066614f85e53a23a8400c1d018b1));
        vk.gamma_abc[39] = Pairing.G1Point(uint256(0x1e7988b56d388231ffb8085d88e28e2380006ff89bd62c2abae17fb02b655cf4), uint256(0x13042f94b0e0fac58b93609274a13bd9d3dad8c8987e65e0eb10038566e77cba));
        vk.gamma_abc[40] = Pairing.G1Point(uint256(0x14b5b140d6ff35a66cf435cb2d85850b7dfdd39e272f43a2dd8407baf8cbb117), uint256(0x0c01dad32ff86410a174d08ff7200d85bab01814e5c2f3271d5fdd958e6f8dad));
        vk.gamma_abc[41] = Pairing.G1Point(uint256(0x0a3d11f34ffbac4ddbf2837cf364a7845a4a0ccdcefa40d06aa84cd468868ede), uint256(0x080a76f6b5469073257f42981566a99aa3147858d4ea773f25bb50a12d4dccbe));
        vk.gamma_abc[42] = Pairing.G1Point(uint256(0x2828484736f8859a05a0d33834337795627914b4199574c532928bbe05ab4c76), uint256(0x2f6eb57ed472cbc5768c4e1bdaa40a932b1b2a71d99af9559dd56634b836d0f7));
        vk.gamma_abc[43] = Pairing.G1Point(uint256(0x1d34165612624c5f67ed56fb858faf3e49e057bad1de1498ada8d6655736bfb0), uint256(0x1c16b7d0be31a5a57444c5378755e6fe2861e7a30d9a59f2272c68c5cd3a5590));
        vk.gamma_abc[44] = Pairing.G1Point(uint256(0x1080063d730dddfcc883c4816642067ce9013662c8466c343247e475b07110ba), uint256(0x140ac6e9144d2cd62bfc891b880df90c9a6e35939f502be963bc1588d5e67860));
        vk.gamma_abc[45] = Pairing.G1Point(uint256(0x020bdc30bbd7493f4f3bc0b99a28f764530803e95bbee4c6cb8ec21e5a8059ef), uint256(0x03284050df6334b4848e1f706e78feb5a8131a82d42578652c6b88078230dcd6));
        vk.gamma_abc[46] = Pairing.G1Point(uint256(0x1a1404c78ad25c2d4f8344e162d53f7872b18327ff5697487d54bf1797e32003), uint256(0x001dcee0e68b8ca7ced2bdd42cd52f353dd629350530e3932e8795f1227792ab));
        vk.gamma_abc[47] = Pairing.G1Point(uint256(0x2f71fd8acf1a8c6d62050af05d0092fd1294bc71828d5db3e6cd5cce4a72e8fc), uint256(0x0576c89650064664919cb3bd28c0d5c63d49cc1b5c8f153464ea8f8c7b286c9e));
        vk.gamma_abc[48] = Pairing.G1Point(uint256(0x16bfc8873e296ac6703895f8856eb2523f969cc9431e80ddb20b05fc490fb3b4), uint256(0x20a26203cf00d0448a82b626751cb2ff6240bf66e13563cc166545290c70b4b2));
        vk.gamma_abc[49] = Pairing.G1Point(uint256(0x1930dffa21668acff9dbc88a988aee408623edbc7c8091a60c8c58186b4cb2ed), uint256(0x225a292531883a417b81de8165334cfea6cbec62a861fa86d4f9ebb6f0c8ed9c));
        vk.gamma_abc[50] = Pairing.G1Point(uint256(0x0e4a46382ff39cd3b570b11b23fa25f5c2a972bdfae6c8ae94114623d8f63784), uint256(0x2425ef30267e20e74b6419db6e53680345a18e961a0eb94ce73938a2f0d9ab76));
        vk.gamma_abc[51] = Pairing.G1Point(uint256(0x192dc89caa464efbeb4a946836ec8e25299229e0b7a212df400be9fa3676b268), uint256(0x1eb73ab78335956d861e3985fb50500b929ba3bbce83aad543aae1efcd1ec26f));
        vk.gamma_abc[52] = Pairing.G1Point(uint256(0x249da7ecda25db7dc41c86feb0ecf2897d7d53fe80733f73e3f7e8130bf90636), uint256(0x04d9d8939e0a86fdbb66629da59ce3f49027d3b2204bdef158299384a25f90c4));
        vk.gamma_abc[53] = Pairing.G1Point(uint256(0x257d55a547bb6ce84c3282da9b1859a9e12bfd66f8180ea5254c0a76af1c48e4), uint256(0x1e45f00b2f9afad2e6161b1081837c6a62e172277603e9d6cf0b1090645b50f0));
        vk.gamma_abc[54] = Pairing.G1Point(uint256(0x1c1ddd95a63c8e8f03108a14b62e3326da5bbe40cc93e395c8b8e9c18ee0c23c), uint256(0x0cb9ce4a08967123d8845cdc3ee9d8db06e368f559f84868f1c299a98817eeac));
        vk.gamma_abc[55] = Pairing.G1Point(uint256(0x01441dcbab80a8f92d5568b3a6189e100d69f298466e9b2cd254cc4705fc7ce1), uint256(0x0e960c3328be3c2cb4176363188bb1444169574e0fc464e9ff72371faf0e1e1c));
        vk.gamma_abc[56] = Pairing.G1Point(uint256(0x080e0889edfddb0f565c1b02e9b7ae3d2dc05f6fe8d2bb663f8b12db3d124044), uint256(0x056792885b6b250e31d850982dce943712cac994c4722e12a8f9d363f2ec1638));
        vk.gamma_abc[57] = Pairing.G1Point(uint256(0x03ffb15c027220164b802748d8a69ffdf7e2edded32928cccb591c0ab3c1c0bd), uint256(0x046e980145cd98b43a1243734010291233d76f48f35feebb68080475667d6337));
        vk.gamma_abc[58] = Pairing.G1Point(uint256(0x071a460e664ce7049ec479f46bf0779deb189010a764d12f02b382d894e52bdc), uint256(0x16f80cb37144d749f21d70e44048964c47542c746506f3d8ccb32e26871fb576));
        vk.gamma_abc[59] = Pairing.G1Point(uint256(0x1e91a0f652901baaf78ee272f28b178271fd4a66055ae14fdf27e2c93aa0e11f), uint256(0x1793d6a7aa1f78ff7eb4f5c916604cdf4d8360d3a0fe38826fbc00f9c2ccfbb1));
        vk.gamma_abc[60] = Pairing.G1Point(uint256(0x05b19df396a582b616b155acbf2c2394643d5436cd14b86106c7116649b032ec), uint256(0x1b4cc717860b03c201fcb06b6e58b426efdc9c9f7cfecbd011e1e1bd69e69a15));
        vk.gamma_abc[61] = Pairing.G1Point(uint256(0x2365287e1195c4ea960c593fab35ac2f1bfdc061c1528de2ad66fa5b79b5f883), uint256(0x0e16a330fc8d096c55f835d8dcc600272624da34abbf14a7a1da93434cbb8023));
        vk.gamma_abc[62] = Pairing.G1Point(uint256(0x02458818928f9c55fa2ac1e173a87f424ec264e0ca51497ae7d5543c1b3cf40f), uint256(0x1cf39f363a44b7b0580801cd71ee376f5b51a11a92b4557abaecdab608ef00d4));
        vk.gamma_abc[63] = Pairing.G1Point(uint256(0x0114c468ceaf4825708ba472f911015da7c9bb89cd3d7f3f3850ec5d1bd3bc5a), uint256(0x0026f903bb6dd43e5f558ae2b67c7cabe2080ad53524e4872d79f7afb6d0f28a));
        vk.gamma_abc[64] = Pairing.G1Point(uint256(0x19b57bee9cd132ab9630c18eb3cab6c275ada25f5989073e904117a7eb917273), uint256(0x003aed1f6a85de7f4c2af45203316308406bb5b69226f2b5ea5c035dc4fa4b31));
        vk.gamma_abc[65] = Pairing.G1Point(uint256(0x2c1ed14cfed6794b45608b6f57a897f94bf80e30a4e33f2bb34bfb5a17879f45), uint256(0x1a59bbf5f9c57246634f347b8454f84a58e057f76ee658ef461ba63d350383da));
        vk.gamma_abc[66] = Pairing.G1Point(uint256(0x223368426d35474601671ce44b4d22341f62831759764938d6f932afa55624cd), uint256(0x06053291e832eb1c4f04ab45bc997f4a09860506789497f8f142c725d2d2da02));
        vk.gamma_abc[67] = Pairing.G1Point(uint256(0x04afd85efbc8fc8eec4dc1c67f68bff2274a147eddc4a7e8c13edc0ac378fa00), uint256(0x1aa100c46c507930767a7dd1e6249b8f9e370280e23c19cadc691586fa4bb603));
        vk.gamma_abc[68] = Pairing.G1Point(uint256(0x2b5a111e42ddf5d51151beae8fbf3c1a45893210afa40c030c77bca4a2c1dced), uint256(0x08e0d8c62575c025986b71d6cf0da5c3de7936a75aa104b40b6bab5e254d61d4));
        vk.gamma_abc[69] = Pairing.G1Point(uint256(0x25ae52abcc5a514831e6cd246aa06fe0350a0942503e742d0bc32216df2c00ab), uint256(0x00f12b7d332ee31799e02e7f124a47c575518ba5e571490c1501e9f78b65b301));
        vk.gamma_abc[70] = Pairing.G1Point(uint256(0x22bdee2db8f6d4a7a84a3f96e71485e1ab5c37a381e0df6258507a421ef82899), uint256(0x29f1772dad4bf56d3e8aa1cdb10707cf63cb55d619ba71e81372c3a0227c0708));
        vk.gamma_abc[71] = Pairing.G1Point(uint256(0x1ef8bb24be41177b2ce2c80851bd49d0c10a8231c6d7c9834b2609d94d902fc5), uint256(0x0debd019f2c048ccf9dbe54679df8da25002ac971acadedd9b524dd9da7dec82));
        vk.gamma_abc[72] = Pairing.G1Point(uint256(0x2e2e09cbf6a5cdf98b546239f3755c8a23423b20087eba1dc12d0930a6e1166c), uint256(0x24d29374ff7cf3273f927f855a45244255ecea54b067f697596612ce8c41f2a1));
        vk.gamma_abc[73] = Pairing.G1Point(uint256(0x2b2cd458c4d0d66ddfb1bfa3659c3d1df9053ef03ff8ffd5791987ba43fe66ad), uint256(0x26feb05718d1537bedb4737d93d6539024b4e46826ef16969b36c06d77e3cae9));
        vk.gamma_abc[74] = Pairing.G1Point(uint256(0x1680fd8d040d5527ffbd7cd568adbbe672232c4518c502aa6e6c79cf384da75a), uint256(0x05bb0292e3476b6bff918d460f77db7b85c91348c8b6e99f9dd0d531387f737f));
        vk.gamma_abc[75] = Pairing.G1Point(uint256(0x1a11c778cfc0a27c2663d78928b1bff61bb55e6cc8e406df9736482e883a936e), uint256(0x1ab98d82c6682fa95c7164166cbc61f10ac2039564b9639b67397636bc1e50a8));
        vk.gamma_abc[76] = Pairing.G1Point(uint256(0x20428409679d0bf0c418cc9f41b84ef050643b0c0572fd0553cc37c4bd883106), uint256(0x2e2ddf803ca17e76e6dcf5f4536e5b814d05a97828071aabac1b78b67a37c26a));
        vk.gamma_abc[77] = Pairing.G1Point(uint256(0x275c4685d1dd44ac79c7ae808b9a798c3997a34e3e53003df762a752e5458e73), uint256(0x0f4e6fd5357f30b049dee320836dd2bcfe4ce471aa52cf0e4ac083c66681af65));
        vk.gamma_abc[78] = Pairing.G1Point(uint256(0x0410fe622c6cc80bdf87a75a7aa9485c147dd67fac31ca5ffddc6a208e8950f3), uint256(0x0c875aeb19295210121e35997a95c8a09941c1f6686e53637ffa8bc779baa7ec));
        vk.gamma_abc[79] = Pairing.G1Point(uint256(0x23397044ba88e7301bbd9b9df7550349a115762832dde39b130ebfce73f6558d), uint256(0x2214cbd7e7d245ff3a0edd6951c21808571485fa914157f0e75dea208ea2ab10));
        vk.gamma_abc[80] = Pairing.G1Point(uint256(0x04d1cf85f7bc724c8e4a1445045b7b3fd595633ec91c7c2b05f653385bfa305b), uint256(0x247555d6fd2f9f0ac1f047d6dc731b5289587565021dc25ab5f864e9a0136e26));
        vk.gamma_abc[81] = Pairing.G1Point(uint256(0x02d62d1e1ea96b12834987c892234945efed70e210eca51d1fce01bfd91d35f2), uint256(0x1f73f080e680dd5d594cf6d1e9c87b834a8e4f0c96198c6d2f0c9edd05d3942b));
        vk.gamma_abc[82] = Pairing.G1Point(uint256(0x08512a8564cb19ba123f094d43b16be4bef4b263e56894810338a4cc321aefe1), uint256(0x01b3cb17cdccb9e72cd23eb6328c3db6ef5f5ca1e0572f50da70cdde65cd0068));
        vk.gamma_abc[83] = Pairing.G1Point(uint256(0x2562de714bd14dacd43cdc073a1849dda33d79de2f894a9e8b5645aee89fa36a), uint256(0x2548eeee95a06aaba608073cdc1775b61241a935fda8bcb0e7a4f63475bf9347));
        vk.gamma_abc[84] = Pairing.G1Point(uint256(0x1d617a8e07c7e6f65d64ca6fe26140c70b9b21ba4488d7de0f2682e59c3aa868), uint256(0x22f8877ab85c091315a6d6a9c749e509b69945dd672545f2ae02283fdfa15909));
        vk.gamma_abc[85] = Pairing.G1Point(uint256(0x2a01d1354c8a96cca40443349d7418be00d78e1952a8d1cf89213f5a8d30b0e9), uint256(0x2df8822bde04d1588bbeddf5bcd89e2fb890f7258c47eb0b2664962ef84630fd));
        vk.gamma_abc[86] = Pairing.G1Point(uint256(0x06a305bfff80e47a17503f44bc3e4857cafe57a763cb1a9919c851f342745587), uint256(0x16c7ac09ab474004d1137ffe50d3763c329f93c0f5fb9c34eeae206acb5c387b));
        vk.gamma_abc[87] = Pairing.G1Point(uint256(0x079e12ee7ef08ee61bd0f9ca0019d079be39b1e1e9d6f0c6e05070cb8ce958d8), uint256(0x000e9f9b825dce79e7cc8d0a49519462fe8e91eb9bfc4b1fa1a63dc811e834f5));
        vk.gamma_abc[88] = Pairing.G1Point(uint256(0x2174fc3692e933ef6abfa5dad1be3f8e69f9499508f6c952606350f9259415e2), uint256(0x239a202c06cefc89d0d0325ca718d7d3adc1944b66d3119abc30f2b3776a1fb0));
        vk.gamma_abc[89] = Pairing.G1Point(uint256(0x2c78b551ffd453d8a70aded1d91d0c574479b81172a67fe14f2d7ea98ebfb845), uint256(0x29a0208a9ad7b79e4fcacc012f3f680e876d95c6578b3ef5dc6fb13c2dcd3346));
        vk.gamma_abc[90] = Pairing.G1Point(uint256(0x03e77a5ef48bef9a68b75dddc0ca2f653c5d58544ef7abd607dc944997ea12dc), uint256(0x21b9f86ede025c626cf506efd3636e3a3cfdbc1ac4ad5cb949fd8e9a3ffd78f8));
        vk.gamma_abc[91] = Pairing.G1Point(uint256(0x168c23309db31fd160afc38dcd624143bb9f5c49146000f8d9fcb2d62607eaf7), uint256(0x031dd0b379a3da80a93db9c3cdfc68473dfd5b1dd72b4a3d3abe48fb0f327618));
        vk.gamma_abc[92] = Pairing.G1Point(uint256(0x21ceec55325bb0e72def749532952b5909f300b9e438b6e09038404efb6b1057), uint256(0x064efcdf904f465be40763c47e7a8c00178aec7fa53bdf8ebaf70674407ccd62));
        vk.gamma_abc[93] = Pairing.G1Point(uint256(0x2a0baabc9f22a537058512df298cedf52ecfc5f96a09bd0aafad405e7ec65543), uint256(0x06e92a51477adbc534cc0779f4807bf3accce787d5d1c421368b7ec9323fa796));
        vk.gamma_abc[94] = Pairing.G1Point(uint256(0x0fa6b2e0c4d8ad50f1e6462bed07b4db847222d2d4f30cb9b39883cdcd63e169), uint256(0x18239b014954ffbb4b554a36dd54f0c185bc3095ae52d9cfe9f0bbb00803cf97));
        vk.gamma_abc[95] = Pairing.G1Point(uint256(0x168dd6d2cae809f4dfea80274e4c917bb6271655a4a3bae73ecbedf4f30e222a), uint256(0x2dddd0f36ec53ab44854178fa274e55218f09524a7cc766bc283036056086e0e));
        vk.gamma_abc[96] = Pairing.G1Point(uint256(0x1caad89a78a08aae4a4ed7c2b94e1ffd23c6c6cad47a015f1bd1c4b5b4180ce2), uint256(0x0aa06f0d4e0d162f1dde6b64ac3c8dda037030bcd5bc7db3f1fb9bb696a8dd1b));
        vk.gamma_abc[97] = Pairing.G1Point(uint256(0x1211f7a9c8ea38135e4c86c31d451d1219befdf0de1a03b2ec93d8fb28c2f29e), uint256(0x081b882da9650ed1b609d67571db5bd38744c31a7de4e53a177f5a4f405bbd4e));
        vk.gamma_abc[98] = Pairing.G1Point(uint256(0x0ddb1c65afc07a2423b484d13b4a711fc40a22635a00a7a793c5c89f9d8e7837), uint256(0x2ad994d1d8418cfa48cddc57aadc0249c8fdbd35deb912d3dfbe83fb9b1fd57a));
        vk.gamma_abc[99] = Pairing.G1Point(uint256(0x246761890a268b93fd144f73281cb3a2babd76babd180355dab950f186653679), uint256(0x1d0145d51c55968eb062e1d222e12dd2611b92c1533e8473fd96f8e831a524b4));
        vk.gamma_abc[100] = Pairing.G1Point(uint256(0x24ea55f77526c051818bfaa9bd00e1e7e2e996222e9535735ce11b22c43397b2), uint256(0x1ddff18266bd602ccc4afe8e99a20abde79e4971299863ae7fc5a5c9a82fcec0));
        vk.gamma_abc[101] = Pairing.G1Point(uint256(0x2f92841a3ea3df73997f870993e09748eb2f926819ee1f552040aa063b354949), uint256(0x11b010b6aa3ff398438acbed55a6e92289ce1b8dc6517d133be762d42c59f608));
        vk.gamma_abc[102] = Pairing.G1Point(uint256(0x289fb47bdccfbbd10797d995e037b5ca0b60ed2ea39d5dfbe76d363738ec7d45), uint256(0x04043a80aaa023c30b8da0782ce63bc61aac353b2c1abfb41a5685ba2be97c07));
        vk.gamma_abc[103] = Pairing.G1Point(uint256(0x08c211be410053ef7cf876b9599802723b10cd9529a654c0a714da4632cc9055), uint256(0x148b13b97b4ecf4545ae3cb8981573aee944c84a64b4fe9dd837ad431383b70d));
        vk.gamma_abc[104] = Pairing.G1Point(uint256(0x10b21cf2e086cd9a488ce4c4868183b337da405b3f101e47304e9614ffaa6ea2), uint256(0x0680979602fde4943db419b7e89903dc9f37e53da7ef267e98a4fef5956a9a93));
        vk.gamma_abc[105] = Pairing.G1Point(uint256(0x303714f0919d94ba30e7c102c31db3bea34ade44b7158cc364db955d0a2e2b51), uint256(0x273c850ebf3f7ddfcef6292b030900a839616ecbc5771e5fcfc37055d5734683));
        vk.gamma_abc[106] = Pairing.G1Point(uint256(0x0caac610864aa36e197543f63075d56615a8620a8880c12aafa66b3be79d0f20), uint256(0x1237df723f31816631bbcd5754f02f93dd8fbf8da7c14cf0a22885a8c33d8388));
        vk.gamma_abc[107] = Pairing.G1Point(uint256(0x284e4473eaad42a80d2577c5d321c9d177d6e3eeb3b301d7d98236842af36991), uint256(0x0205001824793b102963465a97beb44b7faba938cb98423b33233ebe5bfcbcae));
        vk.gamma_abc[108] = Pairing.G1Point(uint256(0x2fb9e96cd21559daef7823756bc4aa4d8c0c5efdc506d626258b8083bccb66a2), uint256(0x12372661888d4b0300cf6437a1be18803d9d622fa54dd0905ae15f34ab280677));
        vk.gamma_abc[109] = Pairing.G1Point(uint256(0x0b5c3a473ca265657d7799f353ba3eccf0e8f7f20cb76ec46b889fdf420a1f6b), uint256(0x141db034e2fb98c380b9b9939cf5535dc0f6a83e54aeab582c95a298097ab46a));
        vk.gamma_abc[110] = Pairing.G1Point(uint256(0x1add17b6c831bd6015050c7bb85e0c7bb91bf9384f7f1ac54e376925ca6a2e30), uint256(0x284923205cee767e63355fc55cb5e5fca3d9f3cbba68ce52bdb2004ef0ebd390));
        vk.gamma_abc[111] = Pairing.G1Point(uint256(0x0b6dd2f31575c3ef699955fc6f99a0951e1b7f3db55d89058798a6393cf98d90), uint256(0x0f3a69e7ca37d8a00810a43c4d638f82fa4816c6d0202bb92abbf51e441cea38));
        vk.gamma_abc[112] = Pairing.G1Point(uint256(0x153eeefc430ad9413b14350d01d699199e7db6e7887a31a555fba05e428af2c4), uint256(0x1d3a373979bf53374096b2f8699a95e9e38dfc9805894a2f111bcec5cfaa4a14));
        vk.gamma_abc[113] = Pairing.G1Point(uint256(0x190692ebe586cdd7cef06bea159e6ce30e0a729c6d4b499a4d8a271a921544b8), uint256(0x305bc63d2f811a1130c68a8b17fd5fe33768c3f3c34f3134b2394077ee8e867e));
        vk.gamma_abc[114] = Pairing.G1Point(uint256(0x094c1c48294913d9710c99b6e81c87c03e363eef4bc2a99115305b586d706464), uint256(0x105efec901953539a02c3258dfe08c082df554783db38affae6d26e2b61fd01d));
        vk.gamma_abc[115] = Pairing.G1Point(uint256(0x2b180a57e27d449d4772e0514719d314eb89c029719614c886e1aa7c83b42b57), uint256(0x00248af7ef98c29b0ade7ab1f3b072a275c128f84029c7124517a437d1392f8f));
        vk.gamma_abc[116] = Pairing.G1Point(uint256(0x0d0f1da82f1bbbd0f1fe96baff7fb10517d3427c1c5cbabea914a3eec57b251d), uint256(0x08cf2fa9688231db04ba8810d3d55ca381908ae07e81a0e6a66459423ebda780));
        vk.gamma_abc[117] = Pairing.G1Point(uint256(0x029936eb88d913a6d40fb023a3130b4e58836f3c3624019c8626e82791c43b50), uint256(0x140510205e2280d06f026faad3503f90bc514bef6c4cb9aeadd2785e30569f83));
        vk.gamma_abc[118] = Pairing.G1Point(uint256(0x0664233ed3a6fc7d1f6fabefd2f3798dffd25a11c31c5bd594c2fc10894445c6), uint256(0x25fb9495a6b9bdca0b6d1ab6d249c309a19e9b6e5a8a62840ff7e506a5d73a04));
        vk.gamma_abc[119] = Pairing.G1Point(uint256(0x2dcd4ed9130f15807585ab6f3f07b38390fd0c1da4c5910369f8c14c8ccd275c), uint256(0x0538d95f39cde023bd64a0871d592f4d24a382e12f744f5e6623162c10308809));
        vk.gamma_abc[120] = Pairing.G1Point(uint256(0x0c261b88136042e64fd674191c6e4eb1a87a7f7dfaca333400fae5e71e225851), uint256(0x1c8a00954e8c27bcb8e4befac24364050fe710c35cefadef8cb81ba802e5791e));
        vk.gamma_abc[121] = Pairing.G1Point(uint256(0x04cc2da1f82d451e0d1b33aa82a39c67915e3d6a45255f658c3f7ed11541c7c2), uint256(0x1e7360a4d7b97e9a60f1f0a7a1d404fdbe6a59cb44be14ba7189caa476d760ab));
        vk.gamma_abc[122] = Pairing.G1Point(uint256(0x2b229bd7640acf00d5508eae615f76f2a9067263c7525933f50df7dc2ab2f946), uint256(0x1538c53bd823c19d59093a5e0dd14ab0ed25f927ad2b8d3dadc8015de4e8ad5a));
        vk.gamma_abc[123] = Pairing.G1Point(uint256(0x12a8c1744d520f26d1457f6722c36ea55c40ef106b5d61db7ea35e4232fd63a7), uint256(0x039fa9b5419cec7aa8a1cac0e47a898a9260d26e028f4268c4d5f141f5c6921f));
        vk.gamma_abc[124] = Pairing.G1Point(uint256(0x23f6fce16e77f65ce2324bbd6e93a6add1df39dccb8ef7dead5c918293b95720), uint256(0x20548c9ecc547eb812ee533d0f4a834db5a7511b1a794ee6fce68102a074cc31));
        vk.gamma_abc[125] = Pairing.G1Point(uint256(0x01e4de79f55354fc6dd20e7d744e8a1697972b35152006ea0c2655c809c8ac7d), uint256(0x211c2a0cb43b4f93b8302d968bc870c040764532fdf9025efcdf5b796c21f562));
        vk.gamma_abc[126] = Pairing.G1Point(uint256(0x0734a91a7847fe30bcdd702c451c25de46e79f2668a1af7e2ebd8dc2677087cd), uint256(0x27e6c30b0a4ba3a2dbc8937c3521e4a6d07357207a05c9d53b42181de89a8614));
        vk.gamma_abc[127] = Pairing.G1Point(uint256(0x0ae55836e2394dab311c220265ebb1f76369593c73bfef2abe9b11b4466e078b), uint256(0x2717268ec9ed5ff4bb341e5d5368fa1acb72e16a68c1c3dd8313ad933aa4a64f));
        vk.gamma_abc[128] = Pairing.G1Point(uint256(0x08b8fa73c6fee4f6c24c27442cb30749d10be507bc226fceb897095f6226f4e1), uint256(0x1f77ed8250c93c0f90abdbb3986cae6338b64dc4c98ce9743f17d5b33dc7ca8d));
        vk.gamma_abc[129] = Pairing.G1Point(uint256(0x1e4e6da8555f5f334d3350662f4540823089f6f059d3632d18b16482b9446388), uint256(0x116a66975f69d521e5a2dbcf562ca01603767ad4b46b7ad8b1a0cc5fca00ae46));
        vk.gamma_abc[130] = Pairing.G1Point(uint256(0x124fdcfaf8665185a8ac8eded1f636aac899ffa149805a6ad8b5dadd4d9bcc60), uint256(0x19117c9a4032708f88a4ef91daa94f0e0357ac51f2602a008508a959c1a2b08d));
        vk.gamma_abc[131] = Pairing.G1Point(uint256(0x0ed58156b73689a4f1db5961cf58506987f2e86c0192563b72ac77bfd48b22f1), uint256(0x0587d997046e9bb0c6977114d830728f1aea90142d363b3463bf45f65da6d33d));
        vk.gamma_abc[132] = Pairing.G1Point(uint256(0x017bcb7ba743be75cb82b71d31b567f8c0a088a541389011e2cd285b041c06e0), uint256(0x0b7b34167ece62ddeb77f7f0410f424ee6e64a011682e7bffc2342bf708804f4));
        vk.gamma_abc[133] = Pairing.G1Point(uint256(0x243d9a347abdb4413c6293ca263168dde1f74b3597fba2874ee2dd2074fdc123), uint256(0x12da504b9798855a47c14cf137829014d59af1ea4527ebb2ef61a1febfabb51f));
        vk.gamma_abc[134] = Pairing.G1Point(uint256(0x165ee17b19a828e03cfca56d564239866aff4f2adaeb5d567feb82e336fccd67), uint256(0x0c5e383e83a95e03492a14b9f8466b52123018e3ffdc549e5caeaf327a52c375));
        vk.gamma_abc[135] = Pairing.G1Point(uint256(0x032ad33c4b2f0b847cf143ee7ca00b0e2ca3dceaca4894bebbae5fd74e13a1d5), uint256(0x20dfac6bac655cdc4d8120a971c78b7a85f3bc081734c541104d5344bb39f8c9));
        vk.gamma_abc[136] = Pairing.G1Point(uint256(0x301b81b6ae78dda348f75d13e96e36000892b770848162f1a50c11d5cfad074c), uint256(0x03cff4f4614366b658e67672a3994314b9bd8d040f084df285e681c3397af0fb));
        vk.gamma_abc[137] = Pairing.G1Point(uint256(0x139ebfa3a30db7d5a1b95a71eac6fb5343240f2b473ec6d35e809ed7ad99415e), uint256(0x260e82b7d517a1aecfa24fdc7cb8a06ac6e998b1d88db34199dcaaf6214fa942));
        vk.gamma_abc[138] = Pairing.G1Point(uint256(0x2e9ea3ea6edf42ebd9897cde4de125c41c2789723710815b54c9587cc6c49999), uint256(0x24447cf747242db2a52aa3040cf90759a107c9bea7077a03202f30a33e05755f));
        vk.gamma_abc[139] = Pairing.G1Point(uint256(0x2a8ff3f7037d62e54bac1a74fb5810a0b69730aef495e7b17062552f1c404714), uint256(0x08521b17af591b85de6262d9815c374967b1bad2e75ddb5906071b28da659394));
        vk.gamma_abc[140] = Pairing.G1Point(uint256(0x1ed35725d7d2c61db8ee75e042dd69eb9f063ba05e7132b1792b02e3b1e5633c), uint256(0x0a170d78e874ee8f65fd1691cc37779c2c4f267ea7254ac25a660c9ccf5ee795));
        vk.gamma_abc[141] = Pairing.G1Point(uint256(0x2833b1abfb9c3a1cc522ea68d3432fdcd50e20c2827d6ccab25c94a92a7c2d4d), uint256(0x05caa6cbe8e01666bc233bb13fe30976184ae5958262abc70b7023efe5cd66c0));
        vk.gamma_abc[142] = Pairing.G1Point(uint256(0x2cb7675d6ce2382d5006c8905f969f8b1e2a7a9e680a8e7a71d30915b893462c), uint256(0x196552bb3bc98f5a18deb02b5ea3b78b81ab092988573d3b65ab4ec89f89d7ae));
        vk.gamma_abc[143] = Pairing.G1Point(uint256(0x16e695cc0c7702e026736e3c106d26cf08c0bb072ba3ab25228c8f35507897ad), uint256(0x273627de5753f7057c081410251ad66cc428194f1ce32aa99193ab90b1e92f4b));
        vk.gamma_abc[144] = Pairing.G1Point(uint256(0x2a7e159b87ea0a6cf3dbae208a20a3ab5386b38af086e22bf9841dc29ab00a97), uint256(0x008a80b7d48bf1c639ef38b72656547e94f444c6b0898bb54f09a35b1ad368c8));
    }
    function verify(uint[] memory input, Proof memory proof) internal view returns (uint) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.gamma_abc.length);
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++) {
            require(input[i] < snark_scalar_field);
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.gamma_abc[i + 1], input[i]));
        }
        vk_x = Pairing.addition(vk_x, vk.gamma_abc[0]);
        if(!Pairing.pairingProd4(
             proof.a, proof.b,
             Pairing.negate(vk_x), vk.gamma,
             Pairing.negate(proof.c), vk.delta,
             Pairing.negate(vk.alpha), vk.beta)) return 1;
        return 0;
    }
    function verifyTx(
            Proof memory proof, uint[144] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](144);

        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }

    function update(int32[SIZE] calldata weights, Proof memory proof, uint[144] memory input) public {
        if (verifyTx(proof, input)){
            blockNumber = block.number;
            modelHash = input[142];
            emit Update(blockNumber);
        }
    }

    function getBlockNumber() public view returns (uint) {
        return blockNumber;
    }

    function getModelHash() public view returns (uint) {
        return modelHash;
    }
}
