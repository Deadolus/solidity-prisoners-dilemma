pragma solidity ^0.4.0;

///Hashing contract to calculate choice hash. 
///Input this at e.g. https://ethereum.github.io/browser-solidity/
contract GenerateCoiceHash {
    enum Choice { None, Betray, Silence }
    function generateHash(Choice _choice, bytes32 _random) returns (bytes32) {
        if(_choice>Choice.Silence)
        throw;
        return sha3(_choice, _random); 
    }
}

//betray(1), 2: 0x8fa5e686e43185c105c30bbebcd43116da0ad7d255786c11dd777fd944dfaa8b
// is equal to 64973858151419717045263467517550949389636568819796684286811224219562127895179
//silence(2), 2: 0xc6ef2da351a8bfdbb5444c07de5fd9277923b7cfd84716394a6c231593268c04
// is equal to 89980535449625406194470317847071652620265794397825794665227851275585871842308

//betray(1), 0: 0x0d678e31a4b2825b806fe160675cd01dab159802c7f94397ce45ed91b5f3aac6
//silene(2), 0: 0x5da513e113e3f2fd0c7f9fdb338fc156917b82fe159806cc152be5bba89d8e7b

//Silence: 0x0000000000000000000000000000000000000000000000000000000000000002
//Betray: 0x0000000000000000000000000000000000000000000000000000000000000001

/*
contract HashTestWithString {
    enum Choice { Betray, Silence }
    function testSha3() returns (bytes32) {

        Choice choice = Choice.Betray;
        string memory random = "Hello World";

        return sha3(choice, random); 

    }
}
*/
