pragma solidity ^0.4.14;

import "./verifier.sol";

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
            uint[2] b1,
            uint[2] b2,
            uint[2] b_p,
            uint[2] c,
            uint[2] c_p,
            uint[2] h,
            uint[2] k
        )  external {

        
        if(verifyTx(a,a_p,[[b1[0],b1[1]],[b2[0],b2[1]]],b_p,c,c_p,h,k,[fact_value]))
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


