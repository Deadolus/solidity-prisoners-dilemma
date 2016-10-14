contract HashTest {
    enum Choice { Betray, Silence }
    function testSha3() returns (bytes32) {

        Choice choice = Choice.Betray;
        uint32 random = 2;

        return sha3(choice, random); 
    }
}

//betray, 2: 0xb4c9eaf404872994677d9def95dee3fe36bfbcd9be2312670ef7be131a502f32
//silence, 2: 0x8fa5e686e43185c105c30bbebcd43116da0ad7d255786c11dd777fd944dfaa8b

//betray, 0: 0xc41589e7559804ea4a2080dad19d876a024ccb05117835447d72ce08c1d020ec
//silene, 0:0x0cb66f6e05387bcfc613a09c9a3fadb03218d2222342a3037275b1a196a6a520

//Silence: 0x0000000000000000000000000000000000000000000000000000000000000001
//Betray: 0x0000000000000000000000000000000000000000000000000000000000000000
