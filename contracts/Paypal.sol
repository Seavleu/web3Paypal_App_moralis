// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

//  define the contract
contract Paypal {
    // TODO: Define the Owner of the smart contract 
    address public owner;

    constructor(){
        owner= msg.sender;
    }

    // TODO: Create Struct and Mapping for request, transaction and name 
    struct request {
        address requestor;
        uint256 amount;
        string message;
        string name;
    }
    struct sendRecieve {
        string action;
        uint256 amount;
        string message;
        address otherPartyAdress;
        string otherPartyName;
    }
    struct userName {
        string name;
        bool hasName;
    }

    // Map wallet to the structs
    mapping(address => userName) public names; //anyone could read
    mapping(address => request[]) requests; //anyone could read
    mapping(address => sendRecieve[]) history; //anyone could read

    // TODO: Add a name to wallet address
    function setUserName(string memory _name) public{
        // require(!names[msg.sender].hasName,"You already have a Name");
        userName storage newUserName = names[msg.sender];
        newUserName.name = _name;
        newUserName.hasName = true;
        // names[msg.sender] = userName(_name,true);
    }
    
    // TODO: Create a Request
    function createRequest(address user, uint256 _amount, string memory _message) public{
        request memory newRequest;
        newRequest.requestor= msg.sender;
        newRequest.amount = _amount;
        newRequest.message = _message;
        if(names[msg.sender].hasName){
            newRequest.name = names[msg.sender].name;
        }
        requests[user].push(newRequest);

    }

    // TODO: Pay a Request
    function payRequest(uint256 _request) public payable{
        require(_request < requests[msg.sender].length, "No Such Request");
        request[] storage myRequests = requests[msg.sender];
        request storage payableRequest = myRequests[_request];

        uint256 toPay= payableRequest.amount * 1000000000000000000;
        require(msg.value == toPay, "Pay Correct Amount");

        payable(payableRequest.requestor).transfer(msg.value);

        addHistory(msg.sender, payableRequest.requestor, payableRequest.amount, payableRequest.message);

        myRequests[_request] = myRequests[myRequests.length-1];
        myRequests.pop();
    
    }

    function addHistory (address sender, address reciever, uint256 _amount, string memory _message) private {
        sendRecieve memory newSend;
        newSend.action = "-";
        newSend.amount = _amount;
        newSend.message = _message;
        newSend.otherPartyAdress = reciever;
        if(names[reciever].hasName){
            newSend.otherPartyName = names[reciever].name;
        }
        history[sender].push(newSend);

        sendRecieve memory newRecieve;
        newRecieve.action = "+";
        newRecieve.amount = _amount;
        newRecieve.message = _message;
        newRecieve.otherPartyAdress = sender;
        if (names[sender].hasName) {
            newRecieve.otherPartyName = names[sender].name;
        }
        history[reciever].push(newRecieve);
    }


    // TODO: Get all requests sent to a User
    function getMyRequest (address _user) public view returns (
        address[] memory,
        uint256[] memory,
        // messenger
        string[] memory,
        // user name
        string[] memory
        ) 
        {

            address[] memory addrs = new address[](requests[_user].length);
            uint256[] memory amnt = new uint256[](requests[_user].length);
            string[] memory msge = new string[](requests[_user].length);
            string[] memory nme = new string[](requests[_user].length);

            for (uint i = 0; i<requests[_user].length; i++)
            {
                request storage myRequests = requests[_user][i];
                addrs[i] = myRequests.requestor;
                amnt[i] = myRequests.amount;
                msge[i] = myRequests.message;
                nme[i] = myRequests.name;
            } 
            return (addrs , amnt , msge, nme);       
    } 
        

    // TODO:  Get all historic transaction user has been apart of
    function getMyHistory(address _user) public view returns(sendRecieve[] memory) {
        return history[_user];
    }

    function getMyName (address _user) public view returns( userName memory) {
        return names[_user];
    }
}