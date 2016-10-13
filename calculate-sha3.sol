contract HashTest {
        enum Choice { Betray, Silence }
          function testSha3() returns (bytes32) {
                    

                    Choice choice = Choice.Betray;
                       uint32 random = 2;


                          return sha3(choice, random); 
                           }
}
