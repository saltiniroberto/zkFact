pragma solidity ^0.4.14;

import "./verifier.sol";

contract zkFact is Verifier
{
    uint fact_value;
    
    /**
     * @param _fact_value The account that provides a zk proof for an integer
     *                    n such that factorial(n) = _fact_value receives the amount held
     *                    in the contract.
     */
    function zkFact(uint _fact_value) payable
    {
        fact_value=_fact_value;
    }
    
    /**
     * Stats new "game round"
     * Allows to set a new _fact_value if the contract balance is 0.
     */
    function startNewRound(uint _fact_value) public payable
    {
        require(address(this).balance == msg.value);
        fact_value=_fact_value;
    }
    
    event PaidOut(string);
    event WrongAnswer(string);
    /**
     * Function used to withdraw the amount held in the contract if the zk proof
     * provided in input is valid, i.e. the sender knows an integer n such that 
     * factorial(n) = _fact_value
     */
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
        )  public
        {

        
        if(verifyTx(a,a_p,[[b1[0],b1[1]],[b2[0],b2[1]]],b_p,c,c_p,h,k,[fact_value]))
        {
            msg.sender.transfer(address(this).balance);
            emit PaidOut("PaidOut");
        }
        else
        {

            emit WrongAnswer("WrongAnswer");
        }
    }
}


