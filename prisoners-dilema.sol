pragma solidity ^0.4.0;

/// @title Prisoners dilemma in solidity

contract PrisonersDilemma {
    uint public MutualBetrayalSentenceInMinutes;
    uint public SingleBetrayalSentenceInMinutes;
    uint public SingleSilenceSentenceInMinutes;
    uint public MutualSilenceSentenceInMinutes;

    enum Choice { Betray, Silence }
    struct BlindedChoice {
        address prisoner;
        uint32  blindedChoice;
    }
    //   BlindedChoice[2] public BlindedPrisonersChoice;
    address[] PrisonerAddresses;
    mapping(address => bytes32) public BlindedPrisonersChoice;
    mapping(address => Choice) public PrisonersChoice;
    mapping(address => uint) public Sentence;

    bool ended;

    event ChoiceMade(address Prisoner);
    event AllChoicesMade();
    event Revealed(address Prisoner, Choice choice);
    event DilemmaEnded();
    event Sentences(uint prisoner1, uint prisoner2);

    modifier onlyAfterChoicesMade() { if ( (PrisonerAddresses[0] == 0) || (PrisonerAddresses[1] == 0) ) throw; _; }
    modifier onlyPrisoners() { if(! ( (PrisonerAddresses[0] == msg.sender) || (PrisonerAddresses[1] == msg.sender) ) ) throw; _; }

    ///Create a new PrisonersDilemma
    function PrisonersDilemma(uint _MutualBetrayalSentenceInMinutes, 
                              uint _SingleBetrayalSentenceInMinutes, 
                              uint _SingleSilenceSentenceInMinutes, 
                              uint _MutualSilenceSentenceInMinutes)
                              {
                                  MutualBetrayalSentenceInMinutes = _MutualBetrayalSentenceInMinutes * 1 minutes;
                                  SingleBetrayalSentenceInMinutes = _SingleBetrayalSentenceInMinutes * 1 minutes;
                                  SingleSilenceSentenceInMinutes =  _SingleSilenceSentenceInMinutes * 1 minutes; 
                                  MutualSilenceSentenceInMinutes = _MutualSilenceSentenceInMinutes * 1 minutes;
                              }

                              function makeChoice(bytes32 _blindedChoice) payable {
                                  if(ended) {
                                      throw;
                                  }

                                  if(PrisonerAddresses.length > 2) {
                                      throw;
                                  }
                                  BlindedPrisonersChoice[msg.sender] = _blindedChoice;
                                  PrisonerAddresses.push(msg.sender);
                                  ChoiceMade(msg.sender);
                                  if(PrisonerAddresses.length == 2)
                                      AllChoicesMade();
                              }

                              ///Reveal both choices with your actual choice and a randomly chosen "salt"
                              function RevealChoices(Choice _choice, uint32 _random) 
                              onlyAfterChoicesMade 
                              onlyPrisoners 
                              {
                                  if( BlindedPrisonersChoice[msg.sender] == sha3(_choice, _random) ) {
                                      //Save the revealed choice
                                      PrisonersChoice[msg.sender] = _choice;
                                      Revealed(msg.sender, _choice);
                                  }
                              }

                              ///Cast sentence, if one of the parties has not yet revealed their choice,
                              /// we consider this as "silence". 
                              /// So only call this sentence after you gave the other party a chance to reveal their sentence
                              function castSentence()
                              onlyAfterChoicesMade
                              onlyPrisoners
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
                                  Sentences(Sentence[prisoner1], Sentence[prisoner2]);

                              }

                              //dummy function top prevent accidental ether sending
                              function() payable {
                                  throw;
                              }


}
