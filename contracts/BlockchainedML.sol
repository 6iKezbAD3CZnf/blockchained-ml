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
        vk.alpha = Pairing.G1Point(uint256(0x0f149c5d9388eb9f3f4c4d027b4b9e93c4b64802368fa4ac454068cdbee2df91), uint256(0x1e07a859eaf343d3b320e18f44e112be39e97a159acadfdb793065eded749888));
        vk.beta = Pairing.G2Point([uint256(0x2f154959d235e83d07ae52cbd981e486f6c774736a56b841ff24d940960d2e3a), uint256(0x1de96852bc94e794cd08dcdb3b0216c5e6cd6ec4335a7acb2cf2610ef24d4a83)], [uint256(0x06b0bdb6ab52f87fb029eb5b9f948a28fb034a09a0520c8182ed403d51ee2598), uint256(0x2cedcd90b570fcf54343836809cf0a9b1a591abe193cff5950f1248fb2079941)]);
        vk.gamma = Pairing.G2Point([uint256(0x1f5585c4a653a755f5fdd10a428f19f4b3fcb117f50405697bbdb530c9183290), uint256(0x04fe5dd8fd8269e608043d28b58d743601a35d115223c65b8fad7344bb9af4e6)], [uint256(0x0784c820f4f0b45e006f328ae77bf297389214754fb61ddd34bdf505220b0247), uint256(0x1998fa51f6250f68509555719abfb566f1d54aa2a58acb969ccc179422c569ec)]);
        vk.delta = Pairing.G2Point([uint256(0x297296b360f8dd2de96d8bf884eab60279540e0924ff1a04bdd2af351fc714cd), uint256(0x16a455596fe7351563d11c2d6b34de2b85d6ef03cd6035eb02cb406721ba89eb)], [uint256(0x2637c1a16500012369c77dcf2951cc5f6ad6e0e48c5410149c5a8dc04842ce12), uint256(0x148c498b5b467aa1695604372079e6500eff31992761d68feaad56f752a2f792)]);
        vk.gamma_abc = new Pairing.G1Point[](73);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x137b79ce2facdd8a6f32ecceb1a77a80c77c7f9c0abce528930815f84dddb7f4), uint256(0x146207c711bb9063cd56d9a70811686d9008cc2b965442db06a92cf09c5c03c7));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x00835d98826280d9905308659fac3d6c9b8c6e07c58c2ca8c33894bed197288b), uint256(0x0da850d9039a758822894b69876a7da3f45662f468266ac287d4e735b9af3e00));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x2f276f01c7ef60d2c1f98b87117afdc7fe205ce3bd818a0fb2310e448624bd1a), uint256(0x03a59f8bdb10c9c11227413cae5f7b0a9356a45e52e3b9606c8285f43add9410));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x2280f2d634227cac0ee09b9540c724c48f0c0ec874e537b26ded711226709aa7), uint256(0x1967fef4bc04dcc34da1d04ba06e315c70f8fc6385969dd7c39bc636f1c675f0));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x0bb081daa30f59d0788583a5363601461ae6562d7885e12647ef7ecfeb68931f), uint256(0x30454afbe058b9515900287f2670df864446ac584492e8a964f691bae9e5e2e6));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x1446cb68ad1b065f6ba4ce3639b1d0b5fb8c72768b8ab86d3ce60bc8c22ff21c), uint256(0x20143753319092aa8d858cfc7bcb030d664997f8745d910f6dc91676ea8a0c6e));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x2fbb5bdb1a2f69942a9c14c43f42c1f8f993d7e6f91fd4f3daa1cf5c0ee4caa0), uint256(0x0cf46e4002fac7e9f868e97779a48240356e306f07b930a8340d7e9d6232bf07));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x0cd71ad2dd39043458ff0f6b394df7cd8ade8e7b9c8bf29e70e08b52d4858971), uint256(0x180b01b858c304ba2d4b307b70b99a3b51d2dcf6f5d251176127c3e36c8ffa0a));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x01c1fabd44ab4db6df2147849b63ab17d1ccffc8a518150876fd62638d0b83e5), uint256(0x0f653e1d2f9a0dd87539fa93f032c9d79bf30065263343b4601224c1da01df8c));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x27541d5519032fa29b5a87d5875e0150ae1e0b067e7fedb37ad196297e9e2e68), uint256(0x09f9a4485d78ecb7c0b7bb0fd195020d1d8389f90df98a9a8ce1bc7f860edfdd));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x2c856e8f3a3d7ca970ac53be8c95de54b48c758d39fdb6d3ca27978cb0056c1d), uint256(0x1301093318a92b013009d1a8e2183aca89d69c9a286f86ca897449930d0cf857));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x188da811831e802d6321ef804ec77eb59e4dbed938f8857c1671c82f32bb45ba), uint256(0x0ae74331abaffa526f71b0862c4c67f5252d7c44d2f9ecaea364bfc14176dff5));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x22cd80d7cc66cc120cc7ade96519d202660101cef0a826d9ec78e3d19d5ca4a6), uint256(0x1b4cbff823e84df15d3129a1d3f76c4a60fac89544699a7392070424064bc20e));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x2bc94bce3abb3cf4cce670c6d44f5139b1e7ee9081b4fa9f14398354daaafed8), uint256(0x08162d4b932859eafaff6bccf88927fb08ebbd11342cca0ca86ed74a4f0b096a));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x15cd09eb25a0601c0199a4dfc7bcf30759d81b11646447d9198c82d76bfe8ea9), uint256(0x163c2fb8ad84998a0837face28291944bfc41f051c3f67f5e97d18c52ce6cba5));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x29d740be37733f936e260b832f7ee32363197b8746f6e7bb7475b6b97b345d2e), uint256(0x1f82a3869529c0ba357af38eac70eb844723c9234e9a57e72ab472211b9bd695));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x1283b4f238da98912403eb26cd3834880fb090ce3b3bf8c7462066693d3f6ff4), uint256(0x0e1fc7dba075a083cad9f8a51dac7e6e2a0001f475f29b35da85121f8633c4f0));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x0b6d1fab2d9867f53a1625d098741e90dc5db5a583ab5a98745ca644b00bcbab), uint256(0x083177392c6c5b4f126c529daf404b225509c18f5925db2b030d93b74166ea15));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x005ca6c821dbd737795ebe64cdfa91c974595f5c6f05c859e9be70fb262926c6), uint256(0x2677d253fae84589c071b61ebb4e22c8135ba69d7982b2775d9eec7634a639d8));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x29075510c95861a33905a312a9f14e4ac778e3880ce170ce1f1787ff23027196), uint256(0x17d0aecd1ce4541408435691eac14bf9e108d1a611ce8c86483b16b7475c0595));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x276a45132e3e639e6c0916e15d73c4c5aa9325594a1de5bb8d3d1eca72d11ab1), uint256(0x233c77827ffd42fb5e97263810e3d1b3ae78a9947b0412c6fa960baab61e0f4e));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x12441b92da207d87338835731eb1ed1e9ab3e472edd91d3bd68938e4cac25a91), uint256(0x25ece9e4f7b7c3faf3c72320a50598ff12c55d53112ee418f53c2c007e4847b1));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x0f3e2f003f9dd18c8fdbe070d1ae0281cd4127aa3abbf0491aea196fc8de9095), uint256(0x1a03e6f811c22b441c10bf6081a59a131afd7e76bd354f4e3a1809b7c165046c));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x13f95da302ee5d4af68b8b99a376f3c2a90c2421ae4d8bd0b10d6a70fe7aa693), uint256(0x17f43191577e0ae87b324227d91d76b79b87cad4edb0d74ab35cc2ec5b9edbc5));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x27e29813a9e2ec28090dc4282bfd355065cd2f446716c423b1270454f7b3f3cd), uint256(0x1f8cf28c5ab07b4011d106bf7c0f571fbe82751e4beaa1d1ee78329c7638f028));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x2712a7528ec94031834dfd2c5fd799007b4901a9dfb8ac8f1083de59da24bee4), uint256(0x25d25672e71650969240592d0e7e145a9cf143a226f6b886990df0df7f154ba7));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x1310b8e45c54d8b5b810df25552ac13c4a080d6d2776fe6184586840019c8356), uint256(0x2013532939c9f6c3de69ef6932e8ca79917bc52c19ccefd664b5ccdbf092e4de));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x261f583b08e4418dbad78ed2e80d3af08a583555509d2bf5f8370987d031b446), uint256(0x140e2a5f6b0be67b1ec2d24a04c9bac6fdb68f43c5538501f0bee98bf98abbb3));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x0ebb6b0c3b287cef0f335f7ed68595012f5d57e999259a0bc0dd03cd3093666c), uint256(0x2e78379ccecebe690990383e001120150014fff622cf73bbd63a04fe8717aee0));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x1ef423cc1fbb4337c0ecdca9e9a1a779050d18463bb9c165562b962bda459040), uint256(0x119087cb804057634d7a90c234e346045c5bece8a68deee37dbf8a21a04c2cad));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x2afe855ee272fe07f420e64c1649a0b97dc645a92e377c9e6b2d2f3795e6c5da), uint256(0x012d327f23745ea016cc31246ef59976d292ac21224442a1cc6b6303b19b8333));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x2892d79c93a597604cf31edfcc2cd5727537148b50832cb63f046f2afa1d808a), uint256(0x2039a0a36feea1f29f60c6d242ff1ff28385f81fb40093b6dbe287ae8cd7c24e));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x030a3c35b3593fb7058fdb1aae1513c082144c21d57cf8a7700f502a441d3ed3), uint256(0x23a6ff10df817bb4b01eff8cfa706ed31291c53d6232ebd91dcef507869ecd2d));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x08c387d49752f7ed0ca1507556372bdf79d1ea660b04e9f50a9f1810aea782fd), uint256(0x2bbd8a92fee30858184b2a5460955bc837c79add11193dd9a4477c99bda0df73));
        vk.gamma_abc[34] = Pairing.G1Point(uint256(0x0c5a55ac3f954328b769b4030071c83d1a7db6d1da5d900dd899f699d8de7f36), uint256(0x0c310dcad5e0ae25ac5cffdd22c0d6286b04daaf9f03055041cde38be8a174cf));
        vk.gamma_abc[35] = Pairing.G1Point(uint256(0x2fd665a7e211b488f53a3a1007b86d20414a37ca6eb7eed1e30bc1e67cb072cd), uint256(0x27f8e6326aed8b7e1ad5c76ff3adedb691d6f44a6cf5e3b848db807a09e007aa));
        vk.gamma_abc[36] = Pairing.G1Point(uint256(0x127da94d6a62d853859f651c0e7f5f088806aaa0377642d69f4744dee06b3ede), uint256(0x023f365080dfc57736b314499b2fbbb03f28837e588d09e24335bb4cb2a2ed80));
        vk.gamma_abc[37] = Pairing.G1Point(uint256(0x27d341fda6e0cd1da411634cd87adfff219e9b8e1be845251b9563bf6e5abd54), uint256(0x1d424fe3166d6da45628e39b68dc88401a8b55ed59072da0fa811d69545f013f));
        vk.gamma_abc[38] = Pairing.G1Point(uint256(0x1273e74f94d6ed45387307497253c25f010d1c5e3124544227e0a0964028f277), uint256(0x15aba2a6b5a30b2eabb773e53bdeb275d4c4e219904fc4694600eb445c125095));
        vk.gamma_abc[39] = Pairing.G1Point(uint256(0x08ba182322ca419d2fcd005b746fed38e53e73fa7e111e16fa79fe25bd6dbfdd), uint256(0x0d68aeb2a4e3da8c1600397fa78819aefb47009b2359dc197c6dc12b50f4fa26));
        vk.gamma_abc[40] = Pairing.G1Point(uint256(0x099d21ccb3ca37ece4ab66b87767b0c8af860efa46f363f4a84fc606bdc89892), uint256(0x29ceff1c52067ba2261f42ad55462d92b33958475faf40bd5f880f522f4412fb));
        vk.gamma_abc[41] = Pairing.G1Point(uint256(0x1311b1c11ed8820f13aa597295bb3977256cb4774f00b7316521a7c9cf8018e2), uint256(0x18902eb50daa32e17723f83c08669180b5c66cf3373e688be0995f64bceb0065));
        vk.gamma_abc[42] = Pairing.G1Point(uint256(0x2c34ac9e11ed26d21a20f683d9969b57abd66124a8172b0adfbae6ebc7dd5f6e), uint256(0x077e47a65d15c432ac51dfd45960e9b7e591c8660313bbb216e22dc01c7544a1));
        vk.gamma_abc[43] = Pairing.G1Point(uint256(0x1e958f44325f9ef361c724151ea881086a4ed72aba86ce9d8a6d018f99ae96f7), uint256(0x131937def10ea9aab1a462ed2ca8988f28bb35652896170e62e14808e22169c9));
        vk.gamma_abc[44] = Pairing.G1Point(uint256(0x17c94d8e1d3e3d0e81f0505a4ee7b4eb00e7a43e72a1aa7ef49855ec9c5780f1), uint256(0x24c8133f5fcad6bf4bfc9aa0d128546b3c06a86ae4263f5d1aaedc38d839c441));
        vk.gamma_abc[45] = Pairing.G1Point(uint256(0x2aaad685cbc053aa521364d9b72800db22213f6e0acf6768f59283744a4433af), uint256(0x1e311f5200187dc17aaeb967ee945085bff07c0b94750cd2008e293d8ff00f82));
        vk.gamma_abc[46] = Pairing.G1Point(uint256(0x0aebfd78d25d9fc1547e255a1a6035997f243d36265de1f45ccb500601ffa2a6), uint256(0x0942e7e61f14e9566b0ed0f510b25b4499a38f3efa3210d3525f5e3080cfa397));
        vk.gamma_abc[47] = Pairing.G1Point(uint256(0x0e4323d828bffa1723f6bf8eb18788d0dd6968a832cef98dbe0521335a962faf), uint256(0x14f4c15e5572002347627f439b0b892bf80c24df14b4426b7f4b4a536f6aa9aa));
        vk.gamma_abc[48] = Pairing.G1Point(uint256(0x0e5272ef17dc993c739d0d23f0a303c141b5ff934335cbebbd02b3a1df76de05), uint256(0x227bbc337a8812bc47a92c45cbec872b8db04c35679102d2452b6462608358d0));
        vk.gamma_abc[49] = Pairing.G1Point(uint256(0x137e1979721198ca4953243647d3b9574d9600b0c77ad68476c6a6d9f167cde6), uint256(0x07d85761aae0096e330a525de9b83af0c4bff6c829261a94a8a3be4c90acef5d));
        vk.gamma_abc[50] = Pairing.G1Point(uint256(0x1ada3b74ec5d1cc928f15a8e128a9644690ac0824621b684f877ab11cbe68c36), uint256(0x0fc00056ac9b68194f517aa5979eb7cfd92b1b99985464c46c61c52ac07b383e));
        vk.gamma_abc[51] = Pairing.G1Point(uint256(0x252e2109c319a3bbfed7f594cab134932b0b3169d632b5f792e99f1d42c339ca), uint256(0x2a6ccd2ca739e10cf5a6ed13184228844bebac3dd0cadea6959be397c78836af));
        vk.gamma_abc[52] = Pairing.G1Point(uint256(0x1e2ba1400a9d9331bf0567dcc3fe5d279c87559cac23e2dc40ee59767ee21700), uint256(0x2bcad82398371c2086341613eb6be1a41f8c947a7458e78492566e8631469307));
        vk.gamma_abc[53] = Pairing.G1Point(uint256(0x1a3e4b7652fc1b274291d8f396358e6f045bfca98c1d06d4b09b02a406142e00), uint256(0x00a31c7bcf3458ea6df51386a06fddc17b71f5258b048a92e2d743fe4091861e));
        vk.gamma_abc[54] = Pairing.G1Point(uint256(0x1e06e70c7d494ed7ecb3cce80bb58cecc98d21df75d54068f9435c89c9f47444), uint256(0x28ba8077a27ec2f760b6fad8c2f10d28b918bd79b8017528220f5f2e616a087b));
        vk.gamma_abc[55] = Pairing.G1Point(uint256(0x29db9abb311c6002ff586b3cceee598f16314e46e4b4f211022075f2cf429170), uint256(0x13dca9a15f2d5f714c738be82a7481445b98d8cdb66ab0807e5e94039464fbf2));
        vk.gamma_abc[56] = Pairing.G1Point(uint256(0x11015cd4405d3dfa39d5fe1c0090728ca4c69ff3810d3a22cabb9255d94fcaca), uint256(0x2fced67e3c04d1036b7cbe31e6dd01f308033b489aeb50ffcb7fc34fb5929a23));
        vk.gamma_abc[57] = Pairing.G1Point(uint256(0x3057ac5bc71135d3b5c69d95e28a8ef2088f0a9f2b74559bcec02461389c4a52), uint256(0x1dc4ca1e526cc9b6db77115126818f5ba4b0182721eab44c2f965738b69b8ca2));
        vk.gamma_abc[58] = Pairing.G1Point(uint256(0x1b61dca4cf589aa87b9a377d894d60e00b43c8caffdc8853e18410b117762115), uint256(0x2fd896ac309ff8aa52986e8415c8cc6a32897789f84f9518961df8a4cf46d289));
        vk.gamma_abc[59] = Pairing.G1Point(uint256(0x14d8d4b723e5c6f474dcf69a3ed7962f8b8d6253da2e5c378651cc182ac58fdb), uint256(0x1b9430aa0616d667b5bcf0e2e89bdf6e405243dcb656cf78e1bbed4ab4d0130b));
        vk.gamma_abc[60] = Pairing.G1Point(uint256(0x1e266cb2d06c324220a911806b0879858e471169b94641c8de8e29a3e1b054c6), uint256(0x0c183767b3153702f3ecba70257c7c040acd212c8409a239960a82974120c145));
        vk.gamma_abc[61] = Pairing.G1Point(uint256(0x2f80b92040db8698d1ac7cc346209f21f61bb66d6b39a0b964e73d93542d3323), uint256(0x2356832d50e06bb1873e4b7449d708ddb850506f0c5cd762ab42661fa0ce96f4));
        vk.gamma_abc[62] = Pairing.G1Point(uint256(0x254d645a3b7c9bb7805112723a675d3b285cffb06789836632967065a825cf69), uint256(0x24d502a99117c216c5e5b3da59d2bb6840ccd361a5ea694c29c8b67591023190));
        vk.gamma_abc[63] = Pairing.G1Point(uint256(0x04eac67f2f46f45ebedf98fdcc3386a58fa0d94c9613bcb783c060c10b44f1d0), uint256(0x129b0a0e533a44c5add74db0c618bfac36b9f4c178a42c40cae9500c43c8882b));
        vk.gamma_abc[64] = Pairing.G1Point(uint256(0x1003ffd9dca9d5746e24c1d449e4813e1f48964a572e9bff4c84c93eb13e854c), uint256(0x1de29e7252e6f9e1b1bd0161fbfad97200cd69455faf018533d22693d97faf15));
        vk.gamma_abc[65] = Pairing.G1Point(uint256(0x08393021894feb68155160104fa929e8992c37dbc6adce7f9492bec53ee32b14), uint256(0x012e92cdd6083e44a2e0265717d115c5440952ccf80b9eb0e1fd941afc691258));
        vk.gamma_abc[66] = Pairing.G1Point(uint256(0x07bec5ab083571f2093477bfe6af3ac7b51e9826ccf18f949ee9e7cba2d81460), uint256(0x275c8ac08e652800163f7087803b09d67a7c073a48013ae0216a481115bbf5d3));
        vk.gamma_abc[67] = Pairing.G1Point(uint256(0x0f78bf01c1d4bc864a82ae15f5d21fa1474995a13e44c448a9e69db96eb2dbf5), uint256(0x0d5ec3228d16a7e13e03abc3a2c594b99d12827d14bc63c340e77df698c8991e));
        vk.gamma_abc[68] = Pairing.G1Point(uint256(0x16ae4d4a85775b0d07f6f66aa8ed83e874ff762bba3d5a5c375283455cd60427), uint256(0x2cad5ab317d64b6e7553c6f3c5d0acae9bb3f3f6a3b8fb1b8abbcc8d34e96200));
        vk.gamma_abc[69] = Pairing.G1Point(uint256(0x270b193173d9950c98603e82ee017b5f6d5e33af8782959b5dec33e8e9989c7a), uint256(0x2a4c5da3826394f6d7dc066e18b1fb4703aee9bf409b9d376d70e09d088a735a));
        vk.gamma_abc[70] = Pairing.G1Point(uint256(0x0192bd87fb2f8ed1e6a84ca978293aad4f78a7e545697e976616aa4df439601f), uint256(0x2d0aa1c81703a4156272cb5daeb7fe1018efac9bc9258718f009b0cffa3a8ba0));
        vk.gamma_abc[71] = Pairing.G1Point(uint256(0x2c001c43c41a7cf6efe62ec3e9261f0c738a5f4ac936458a2d7831eafe98a2bd), uint256(0x16613566b0e3a5f256cf7698bd2743f1c4bf9c9e408e70b6fc3cf68835606012));
        vk.gamma_abc[72] = Pairing.G1Point(uint256(0x20629cc9b8a38469dc2631dfbe9fd5d871d57a448aba6094e54ac2e8337db4f2), uint256(0x29df921db9a1932aa14b5bfce822ef4e0603e280db5b9c5479a99e0a08122d4a));
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
            Proof memory proof, uint[72] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](72);

        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }

    function update(int32[SIZE] calldata weights, Proof memory proof, uint[72] memory input) public {
        if (verifyTx(proof, input)){
            blockNumber = block.number;
            emit Update(blockNumber);
        }
    }

    function get() public view returns (uint) {
        return blockNumber;
    }
}
