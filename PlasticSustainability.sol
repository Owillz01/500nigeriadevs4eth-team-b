pragma solidity >=0.5.0 <0.7.0;

//SafeMath library
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

contract PlasticSustainability{

    using SafeMath for uint;            // calls SafeMath library

    //State variables
    address internal owner;             //owner address
    uint public adminIndex = 0;         //admin index
    uint public participantIndex = 0;    //participant index
    uint public agentIndex = 0;         //collection agent index
    uint public wasteBinCount = 0;      //number of waste bins

    //Structs
    struct Admin {
        uint adminIndex;
        bool isAdmin;
    }

    struct CollectionAgent {
        string fullName;                //agent name
        uint8 phoneNumber;              //agent phone number
        string location;                //agent location
        uint agentIndex;              //collection agent index
        bool isAuthorized;              //if agent has authorization
    }

    struct Participant {
        string fullName;                //participant's name
        string email;                   //participant's email
        uint8 phoneNumber;              //participant's phone number
        uint id;                        //participant's id
        uint plasticPicked;             //amount of plastics picked
        bool paid;                      //remaining balance
        bool isAuthorized;               //if participant is authorized
    }

    struct WasteBin {
        string location;                //waste bin location
        uint binIndex;                  //waste bin index
        bool isFull;                    //reserved space
        uint Weight;                    //bin weigth
    }

    //Mapppings
    mapping (address => Admin) public admins;
    mapping (address => CollectionAgent) public collectionAgents;
    mapping (uint => WasteBin) public wasteBins;
    mapping (address => Participant) public participants;

    event AdminAdded(string msg, address newAdmin, uint indexed adminIndex);
    event AdminRemoved(address adminAddress, uint indexed adminIndex);
    event CollectionAgentAdded(string msg, string fullName, string specialty, uint agentIndex);
    event CollectionAgentRemoved(string msg, address indexed collectionAgentAddress);
    event ParticipantAdded(string msg, string fullName, string email);
    event ParticipantRemoved(string msg, address indexed  participantAddress);

    //Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, 'Access denied: Not owner');
        _;
    }

    modifier onlyAdmins() {
        require(admins[msg.sender].isAdmin == true, 'Only admins can call this function');
        _;
    }

    //Constructor function
    constructor() public {
        owner = msg.sender;
        addAdmin(owner);
    }

    //Add admin function
    function addAdmin(address _newAdmin) public onlyOwner {
        Admin memory _adminStruct;
        require(admins[_newAdmin].isAdmin == false, 'Admin alreadty exists');
        admins[_newAdmin] = _adminStruct;
        _adminStruct.isAdmin = true;
        adminIndex = adminIndex.add(1);
        emit AdminAdded('New expert added:', _newAdmin, adminIndex);
    }

    //Remove admin function
    function removeAdmin(address _adminAddress) public onlyOwner {
        Admin memory _adminStruct;
        require(adminIndex > 1, 'Cannot operate without an admin');
        require(_adminStruct.isAdmin == true, 'Not an admin');
        require(_adminAddress != owner, 'Cannot remove owner');
        delete admins[_adminAddress];
        adminIndex = adminIndex.sub(1);
        emit AdminRemoved(_adminAddress, adminIndex);
    }

    //Add CollectionAgent function
    function addCollectionAgent(
        string memory _fullName,
        uint8 _phoneNumber,
        string memory _location
        ) public onlyAdmins
        {
        CollectionAgent memory _collectionAgentStruct;
        require(_collectionAgentStruct.isAuthorized == false, 'CollectionAgent already exists');
        _collectionAgentStruct.fullName = _fullName;
        _collectionAgentStruct.phoneNumber = _phoneNumber;
        _collectionAgentStruct.location = _location;
        _collectionAgentStruct.agentIndex = agentIndex.add(1);
        _collectionAgentStruct.isAuthorized = true;
        emit CollectionAgentAdded('New CollectionAgent added:', _fullName, _location, agentIndex);
    }

    //Remove CollectionAgent function
    function removeCollectionAgent (address _collectionAgentAddress) public onlyAdmins {
        CollectionAgent memory _collectionAgentStruct;
        require(_collectionAgentStruct.isAuthorized == true, 'Not an agent');
        require(_collectionAgentAddress != owner, 'Cannot remove owner');
        delete collectionAgents[_collectionAgentAddress];
        _collectionAgentStruct.agentIndex = agentIndex.sub(1);
        emit CollectionAgentRemoved('CollectionAgent removed:',_collectionAgentAddress);
    }

    //Add participant function
    function addParticipant(
        string memory _fullName,
        string memory _email,
        uint8 _phoneNumber
        ) public onlyAdmins
        {
        Participant memory _participantStruct;
        require(_participantStruct.isAuthorized = false,'Participant already exist');
        _participantStruct.fullName = _fullName;
        _participantStruct.email = _email;
        _participantStruct.phoneNumber = _phoneNumber;
        _participantStruct.id = participantIndex.add(1);
        _participantStruct.plasticPicked = 0;
		_participantStruct.paid = false;
        _participantStruct.isAuthorized = true;
        emit ParticipantAdded('New participant added:', _fullName, _email);
    }

    //Remove participant function
    function removeParticipant(address _participantAddress) public onlyAdmins {
        Participant memory _participantStruct;
        require(_participantStruct.isAuthorized == true, 'Not a participant');
        require(_participantAddress != owner, 'Cannot remove owner');
        delete participants[_participantAddress];
        participantIndex = participantIndex.sub(1);
        emit ParticipantRemoved('Participant removed:', _participantAddress);
    }


}