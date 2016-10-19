pragma solidity ^0.4.0;

/// @title Prisoners dilemma in solidity
contract PrisonersDilemma {
    uint public MutualBetrayalSentenceInMinutes;
    uint public SingleBetrayalSentenceInMinutes;
    uint public SingleSilenceSentenceInMinutes;
    uint public MutualSilenceSentenceInMinutes;

    enum Choice { None, Betray, Silence }
    enum Status { accepting, revealing, ended}
    Status public status = Status.accepting;
    address[] PrisonerAddresses;
    mapping(address => bytes32) public BlindedPrisonersChoice;
    mapping(address => Choice) public PrisonersChoice;
    mapping(address => uint) public Sentence;

    //bool ended;
    //bool revealing;

    event DilemmaStarted();
    event ChoiceMade(address Prisoner);
    event AllChoicesMade();
    event Revealed(address Prisoner, Choice choice);
    event DilemmaEnded();
    event Sentences(uint prisoner1, uint prisoner2);

    modifier onlyBeforeRevealing() { if( status >= Status.revealing ) throw; _; }
    modifier onlyAfterChoicesMade() { if ( PrisonerAddresses.length != 2 ) throw; _; }
    modifier onlyAfterBothRevealed() { if( (PrisonersChoice[PrisonerAddresses[0]] == Choice.None) || (PrisonersChoice[PrisonerAddresses[1]] == Choice.None) ) throw; _; }
    modifier onlyBeforePrisonersSelected() {      
        //if we already have two prisoners, check if sender is already a prisoner
        if(PrisonerAddresses.length == 2) {
            if( (PrisonerAddresses[0] != msg.sender) && (PrisonerAddresses[1] != msg.sender) )
                throw;
        }
        _;
    }
    modifier onlyPrisoners() { if( (PrisonerAddresses[0] != msg.sender) && (PrisonerAddresses[1] != msg.sender) ) throw; _; }
    modifier onlyBeforeEnded() { if( status >= Status.ended ) throw; _; }
    modifier onlyAfterEnded() { if( status < Status.ended) throw; _; }

    /**
     * @notice Create a Prisoner dilemma, where you want to get the smallest sentence possible
     * @param _MutualBetrayalSentenceInMinutes Time a mutual betrayal will net you, e.g. 10
     * @param _SingleBetrayalSentenceInMinutes Time which you'll get when only you betray the other prisoner, e.g. 3
     * @param _SingleSilenceSentenceInMinutes Time which you'll get when you stay silent and the other prisoner betrays you, e.g. 8
     * @param _MutualSilenceSentenceInMinutes Time both of you get if you stay silent, e.g. 5
     */
    function PrisonersDilemma(uint _MutualBetrayalSentenceInMinutes, 
                              uint _SingleBetrayalSentenceInMinutes, 
                              uint _SingleSilenceSentenceInMinutes, 
                              uint _MutualSilenceSentenceInMinutes)
                              {
                                  MutualBetrayalSentenceInMinutes = _MutualBetrayalSentenceInMinutes * 1 minutes;
                                  SingleBetrayalSentenceInMinutes = _SingleBetrayalSentenceInMinutes * 1 minutes;
                                  SingleSilenceSentenceInMinutes =  _SingleSilenceSentenceInMinutes * 1 minutes; 
                                  MutualSilenceSentenceInMinutes = _MutualSilenceSentenceInMinutes * 1 minutes;
                                  DilemmaStarted();
                              }

                              /**
                              * @notice Make your blinded choice, see helper contract to create hash
                              */
                              function makeChoice(bytes32 _blindedChoice) 
                              onlyBeforePrisonersSelected
                              onlyBeforeRevealing
                              {
                                  BlindedPrisonersChoice[msg.sender] = _blindedChoice;

                                  if( (PrisonerAddresses.length == 0 ) || ( (PrisonerAddresses.length == 1) && ( PrisonerAddresses[0] != msg.sender ) ) )
                                      PrisonerAddresses.push(msg.sender);
                                  ChoiceMade(msg.sender);
                                  if( PrisonerAddresses.length == 2 ) 
                                      AllChoicesMade();     

                              }

                              /**
                              * @notice Reveal both choices with your actual choice and a randomly chosen "salt"
                              */
                              function RevealChoices(Choice _choice, uint32 _random) 
                              onlyAfterChoicesMade 
                              onlyPrisoners 
                              onlyBeforeEnded
                              {
                                  if( BlindedPrisonersChoice[msg.sender] == sha3(_choice, _random) ) {
                                      if( (_choice != Choice.Betray) && (_choice != Choice.Silence) )
                                          throw;
                                      //Save the revealed choice
                                      PrisonersChoice[msg.sender] = _choice;
                                      Revealed(msg.sender, _choice);
                                      status = Status.revealing;
                                  }
                              }

                              /**
                              * @notice Cast sentence, if one of the parties has not yet revealed their choice,
                              * we consider this as "silence". 
                                  * So only call this sentence after you gave the other party a chance to reveal their sentence 
                                  */
                              function castSentence()
                              onlyAfterChoicesMade
                              onlyAfterBothRevealed
                              onlyBeforeEnded
                              {
                                  var prisoner1 = PrisonerAddresses[0];
                                  var prisoner2 = PrisonerAddresses[1];
                                  if( (PrisonersChoice[prisoner1] == Choice.Silence) && (PrisonersChoice[prisoner2]== Choice.Silence) ) {
                                      Sentence[prisoner1] =  Sentence[prisoner2] = now + MutualSilenceSentenceInMinutes;
                                  } else {
                                      if( (PrisonersChoice[prisoner1] == Choice.Betray) && (PrisonersChoice[prisoner2]== Choice.Betray) ) {
                                          Sentence[prisoner1] =  Sentence[prisoner2] = now + MutualBetrayalSentenceInMinutes;
                                      } else {
                                          //one prisoner betrayed the other
                                          if(PrisonersChoice[prisoner1] == Choice.Betray) {
                                              Sentence[prisoner1] =  now + SingleBetrayalSentenceInMinutes;
                                              Sentence[prisoner2] =  now + SingleSilenceSentenceInMinutes;
                                          }
                                          else {
                                              Sentence[prisoner1] =  now + SingleSilenceSentenceInMinutes;
                                              Sentence[prisoner2] =  now + SingleBetrayalSentenceInMinutes;
                                          } 
                                      }
                                  }


                                  DilemmaEnded();
                                  status = Status.ended;
                                  Sentences(Sentence[prisoner1], Sentence[prisoner2]);
                                  restart();

                              }

                              function restart()
                              onlyAfterEnded
                              {
                                  status = Status.accepting;
                                  for( uint i = 0; i < 2; i++)
                                  {
                                      BlindedPrisonersChoice[PrisonerAddresses[i]] = 0;
                                      PrisonersChoice[PrisonerAddresses[i]] = Choice.None;
                                      Sentence[PrisonerAddresses[i]] = 0;
                                  }
                                  delete PrisonerAddresses;
                                  DilemmaStarted();
                              }


                              //dummy function top prevent accidental ether sending
                              function() payable {
                                  throw;
                              }


}
