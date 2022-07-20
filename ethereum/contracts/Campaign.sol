// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract CampaignFactory {
    Campaign[] public deployedCampaigns;

    // Deploys a new instance of a Campaign and stores the resulting address
    function createCampaign(uint minimum) public {
        Campaign newCampaign = new Campaign(minimum, msg.sender);
        deployedCampaigns.push(newCampaign);
    }
    // Returns a list of all deployed campaigns
    function getDeployedCampaigns() public view returns (Campaign[] memory) {
        return deployedCampaigns;
    }
}

contract Campaign {
    struct Request {
        string description;
        uint value;
        address payable recipient;
        bool complete;
        mapping (address => bool) approvals;
        uint approvalCount;
    }

    address public manager;
    uint public minimumContribution;
    // address[] public approvers; arrays aren't scalable - use mappings for O(1) lookups. Mappings need to be initialised to return an undefined value though
    mapping(address => bool) public approvers;
    uint public approversCount;
    uint public numRequests;
    mapping (uint => Request) public requests;


    modifier restrictedToManager() {
        assert(msg.sender == manager);
        _;
    }

    constructor(uint minimum, address creator) {
        manager = creator;
        minimumContribution = minimum;
    }

    function contribute() public payable {
        require(msg.value > minimumContribution);
        approvers[msg.sender] = true; //only the value true gets stored inside the mapping - not the address
        approversCount ++;
    }

    // Called by the manager to create a new 'spending' request
    function createRequest(string memory description, uint value, address payable recipient) public restrictedToManager {
        // get last index of requests from storage
       Request storage newRequest = requests[numRequests];
       // increase requests counter
       numRequests ++;
       // add information about new request
       newRequest.description = description;
       newRequest.value = value;
       newRequest.recipient = recipient;
       newRequest.complete = false;
       newRequest.approvalCount = 0;
    }

    // Called by each contributor to approve a spending request (voting)
    function approveRequest(uint index) public {
        // get request at provided index from storage
        Request storage request = requests[index];
        // sender needs to have contributed to Campaign
        require(approvers[msg.sender]);
        // sender must not have voted yet
        require(!request.approvals[msg.sender]);
        // add sender to addresses who have voted
        request.approvals[msg.sender] = true;
        // increment approval count
        request.approvalCount ++;
    }

    // After a request has gotten enough approvals, the manager can call this to get money sent to the vendor
    function finalizeRequest(uint index) public restrictedToManager {
        Request storage request = requests[index];
        require(!request.complete);
        require(request.approvalCount > (approversCount / 2));
        request.recipient.transfer(request.value);
        request.complete = true;
    }

    function getSummary() public view returns (uint, uint, uint, uint, address) {
        return (
          minimumContribution,
          address(this).balance,
          numRequests,
          approversCount,
          manager
        );
    }

    function getRequestsCount() public view returns (uint) {
        return numRequests;
    }

}
