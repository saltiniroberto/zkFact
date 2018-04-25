// This file is MIT Licensed.
//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

pragma solidity ^0.4.14;
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
    function P1() internal returns (G1Point) {
        return G1Point(1, 2);
    }
    /// @return the generator of G2
    function P2() internal returns (G2Point) {
        return G2Point(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
             10857046999023057135944570762232829481370756359578518086990519993285655852781],
            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
             8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );
    }
    /// @return the negation of p, i.e. p.add(p.negate()) should be zero.
    function negate(G1Point p) internal returns (G1Point) {
        // The prime q in the base field F_q for G1
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0)
            return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }
    /// @return the sum of two points of G1
    function add(G1Point p1, G1Point p2) internal returns (G1Point r) {
        uint[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        assembly {
            success := call(sub(gas, 2000), 6, 0, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid }
        }
        require(success);
    }
    /// @return the product of a point on G1 and a scalar, i.e.
    /// p == p.mul(1) and p.add(p) == p.mul(2) for all points p.
    function mul(G1Point p, uint s) internal returns (G1Point r) {
        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        assembly {
            success := call(sub(gas, 2000), 7, 0, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid }
        }
        require (success);
    }
    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] p1, G2Point[] p2) internal returns (bool) {
        require(p1.length == p2.length);
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[0];
            input[i * 6 + 3] = p2[i].X[1];
            input[i * 6 + 4] = p2[i].Y[0];
            input[i * 6 + 5] = p2[i].Y[1];
        }
        uint[1] memory out;
        bool success;
        assembly {
            success := call(sub(gas, 2000), 8, 0, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid }
        }
        require(success);
        return out[0] != 0;
    }
    /// Convenience method for a pairing check for two pairs.
    function pairingProd2(G1Point a1, G2Point a2, G1Point b1, G2Point b2) internal returns (bool) {
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
            G1Point a1, G2Point a2,
            G1Point b1, G2Point b2,
            G1Point c1, G2Point c2
    ) internal returns (bool) {
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
            G1Point a1, G2Point a2,
            G1Point b1, G2Point b2,
            G1Point c1, G2Point c2,
            G1Point d1, G2Point d2
    ) internal returns (bool) {
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
contract Verifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G2Point A;
        Pairing.G1Point B;
        Pairing.G2Point C;
        Pairing.G2Point gamma;
        Pairing.G1Point gammaBeta1;
        Pairing.G2Point gammaBeta2;
        Pairing.G2Point Z;
        Pairing.G1Point[] IC;
    }
    struct Proof {
        Pairing.G1Point A;
        Pairing.G1Point A_p;
        Pairing.G2Point B;
        Pairing.G1Point B_p;
        Pairing.G1Point C;
        Pairing.G1Point C_p;
        Pairing.G1Point K;
        Pairing.G1Point H;
    }
    function verifyingKey() internal returns (VerifyingKey vk) {
        vk.A = Pairing.G2Point([0x2e966ed887a45bbfa2024e6f38b8bca1ef31d3676e8c0289d4a9b6d4148a7f62, 0x6b1eaa2dde1f7f4e767165e2f16a55a6dad9b2aa682ea6de3f915c8683c77dd], [0x9ac8a2a0add8b8cb10ce7b6e25d75b964f803572ae72c521fcdf41ebd8bd117, 0x9f4e396e4706b943d7bf65c766eb75d36ff994f39efd3329048149ec3296e5]);
        vk.B = Pairing.G1Point(0x22ee1eed88838683e934de38dcd17b23dbc766b0dd7029e07b296b6fcf466661, 0x1e96dda62ffa0e1ebd93c95c3c6d285ca84738f26350eeb43d89ada6a565114d);
        vk.C = Pairing.G2Point([0x1b06c3d6f929b9cc7aa9032778f0d3d9a5378ec97a8b265a609bcf57ad1857b, 0x2a60e9ad982e596df1b9b7732305d657441484987f1bc9fcc91676decf729d9e], [0x8480eb25f361c1ec4a8653557afa9ad01bfef1e3b424935370e83598dc36595, 0x1fcf42e28c0240af442b89f1b6916bb05cb75668f904654637a35e8ca874bd71]);
        vk.gamma = Pairing.G2Point([0x1eb19f75a5319f618722e183d993e9507f6a20f18f7fbcf0bc0ba9d8246a1aec, 0xf1c9ceb74c87c7917b4be3d5d22ecfdd262b4a4a12551871857e463c1fbd379], [0x294fe680c9eb4a06b0581bfea49aeda7108a9f1d13ddc02fb51d25ea608e235d, 0x26317b3e7414b10bc51154a61b28711bef98dcec236cf0ef227da9f34a881190]);
        vk.gammaBeta1 = Pairing.G1Point(0x4aedef673f1ec504d3e075aae0ca003d71259672c8ff0c4b575841df84602fc, 0x2817ab92397dc2c518ff6cc1d5fc862257f36f794602b6b51bcf96965bf36fb3);
        vk.gammaBeta2 = Pairing.G2Point([0x6f33af1caccd2d2f20c69249b11c425ccbcf4568bcd9fd747401fb6f0ff928e, 0x1306ac87bdae2c16a32052022cd8aae6a41093a479b699ab3ce86168ce757ef1], [0xe1a2f5edac2ee3d49336048a1e2d722f6e104bc64b6a6b3e4705a3512520b68, 0x1f25f5a3839ec65f9f77749e0e0f94b0aa9e92f00f72a6bd61081c620c4b367c]);
        vk.Z = Pairing.G2Point([0xdde69eb44fcd2d2b71df2968ef7b457fe64c28367b2f29d4d154e7cb12803, 0x1c1e2cf139b13c6d8854dc61972709e2870b52721e37731ad908cf3d4f7e908a], [0x9b6150c58043bf350656d60987b532cf1a0d20a8af99dbb6494ecdc97c2734f, 0x28c1a8a4abc53fec2d5e634034454351ef600bca36b3ee7a657492e18fe0a93e]);
        vk.IC = new Pairing.G1Point[](2);
        vk.IC[0] = Pairing.G1Point(0x1ac5d18d3bd2eed99db6c22b6710cbbd2c77bc8afb9fae40334ab9edbb59ba2f, 0x22b113bf37e5086f76e623cb952c39f08190c0f102582ef53249547c6b6be32d);
        vk.IC[1] = Pairing.G1Point(0x13d0b5586db9fbcf2c6413463787c0ed8ad1ca93b2e087182a23812917c1878b, 0x28a657b1ac5a108f53cba6afd6e61b432f69ddf138b1fc6a193f2af862142258);
    }
    function verify(uint[] input, Proof proof) internal returns (uint) {
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.IC.length);
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++)
            vk_x = Pairing.add(vk_x, Pairing.mul(vk.IC[i + 1], input[i]));
        vk_x = Pairing.add(vk_x, vk.IC[0]);
        if (!Pairing.pairingProd2(proof.A, vk.A, Pairing.negate(proof.A_p), Pairing.P2())) return 1;
        if (!Pairing.pairingProd2(vk.B, proof.B, Pairing.negate(proof.B_p), Pairing.P2())) return 2;
        if (!Pairing.pairingProd2(proof.C, vk.C, Pairing.negate(proof.C_p), Pairing.P2())) return 3;
        if (!Pairing.pairingProd3(
            proof.K, vk.gamma,
            Pairing.negate(Pairing.add(vk_x, Pairing.add(proof.A, proof.C))), vk.gammaBeta2,
            Pairing.negate(vk.gammaBeta1), proof.B
        )) return 4;
        if (!Pairing.pairingProd3(
                Pairing.add(vk_x, proof.A), proof.B,
                Pairing.negate(proof.H), vk.Z,
                Pairing.negate(proof.C), Pairing.P2()
        )) return 5;
        return 0;
    }
    
    function testa(int[2] a) pure returns(int)
    {
        return a[0];
    }
    
        function verifyTx2(
            uint[2] a,
            uint[2][2] b,
            uint[1] input) returns (bool )
            {
                return true;
            }
    
    event Verified(string);
    function verifyTx(
            uint[2] a,
            uint[2] a_p,
            uint[2][2] b,
            uint[2] b_p,
            uint[2] c,
            uint[2] c_p,
            uint[2] h,
            uint[2] k,
            uint[1] input
        ) returns (bool r) {
        Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.A_p = Pairing.G1Point(a_p[0], a_p[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.B_p = Pairing.G1Point(b_p[0], b_p[1]);
        proof.C = Pairing.G1Point(c[0], c[1]);
        proof.C_p = Pairing.G1Point(c_p[0], c_p[1]);
        proof.H = Pairing.G1Point(h[0], h[1]);
        proof.K = Pairing.G1Point(k[0], k[1]);
        uint[] memory inputValues = new uint[](input.length);
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            Verified("Transaction successfully verified.");
            return true;
        } else {
            return false;
        }
    }
}

contract zkFact is Verifier
{
    uint fact_value;
    
    function zkFact(uint _fact_value) payable
    {
        fact_value=_fact_value;
    }
    
    event PaidOut(string);
    event WrongAnswer(string);
    function withdraw(
            uint[2] a,
            uint[2] a_p,
            uint[2][2] b,
            uint[2] b_p,
            uint[2] c,
            uint[2] c_p,
            uint[2] h,
            uint[2] k
        )  external {
        uint[1] memory input;
        input[0]=fact_value;
        
        if(verifyTx(a,a_p,b,b_p,c,c_p,h,k,input))
        {
            msg.sender.transfer(this.balance);
            emit PaidOut("PaidOut");
        }
        else
        {

            emit WrongAnswer("WrongAnswer");
        }
    }
}

