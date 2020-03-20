pragma solidity >=0.5.0 <0.7.0;

import "./SafeMath.sol";

contract PlasticSustainability {

    using SafeMath for uint;            // calls SafeMath library

    //State variables
    address internal owner;             //owner address
    uint public adminIndex = 0;         //admin index
    uint public participantIndex = 0;   //participant index
    uint public agentIndex = 0;         //collection agent index
    uint public wasteBinIndex = 0;      //number of waste bins
    uint public weightPicked = 0;

    //Structs
    struct CollectionAgent {
        string fullName;                //agent name
        uint phoneNumber;               //agent phone number
        string location;                //agent location
        bool isAuthorized;              //if agent has authorization
    }

    struct WasteBin {
        string location;                //waste bin location
        bool isFull;                    //reserved space
        uint capacity;                  //bin capacity
    }

    struct Participant {
        string fullName;                //participant's name
        string email;                   //participant's email
        uint phoneNumber;               //participant's phone number
        uint weightPicked;                    //amount of plastics picked
        bool paid;                      //remaining balance
    }

    //Mapppings
    mapping (address => bool) public admins;
    mapping (address => CollectionAgent) public collectionAgents;
    mapping (address => WasteBin) public wasteBins;
    mapping (address => Participant) public participants;

    event AdminAdded(string msg, address indexed _newAdmin, uint _adminIndex);
    event AdminRemoved(address indexed _address, uint indexed _adminIndex);
    event CollectionAgentAdded(string msg, string indexed _location, address indexed _agentIndex);
    event CollectionAgentRemoved(string msg, address indexed _address);
    event ParticipantAdded(string msg, address indexed _address);
    event ParticipantRemoved(string msg, address indexed  _address);
    event WasteBinAdded(string msg, string indexed location, uint indexed capacity, address indexed _address);
    event ParticipantDonated(string msg, address indexed _addressP, address indexed _addressW, uint indexed weight);

    //Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, 'Access denied: Not owner');
        _;
    }

    modifier onlyAdminOrOwner() {
        require(admins[msg.sender] == true, 'Only admins can call this function');
        _;
    }

    //Constructor function
    constructor() public {
        owner = msg.sender;
        addAdmin(owner);
    }

    //Add admin function
    function addAdmin(address _newAdmin) public onlyOwner {
        admins[_newAdmin] = true;
        adminIndex = adminIndex.add(1);
        emit AdminAdded('New expert added:', _newAdmin, adminIndex);
    }

    //Remove admin function
    function removeAdmin(address _adminAddress) public onlyOwner {
        require(adminIndex > 1, 'Cannot operate without an admin');
        require(_adminAddress != owner, 'Cannot remove owner');
        admins[_adminAddress] = false;
        adminIndex = adminIndex.sub(1);
        emit AdminRemoved(_adminAddress, adminIndex);
    }

    //Add CollectionAgent function
    function addCollectionAgent(
        string memory _fullName,
        uint _phoneNumber,
        string memory _location,
        address _address
        ) public onlyAdminOrOwner
    {
        CollectionAgent memory _collectionAgentStruct;
        require(_collectionAgentStruct.isAuthorized == false, 'CollectionAgent already exists');
        _collectionAgentStruct.fullName = _fullName;
        _collectionAgentStruct.phoneNumber = _phoneNumber;
        _collectionAgentStruct.location = _location;
        _collectionAgentStruct.isAuthorized = true;
        collectionAgents[_address] = _collectionAgentStruct;
        agentIndex = agentIndex.add(1);
        emit CollectionAgentAdded('New Collection Agent added:', _location, _address);
    }

    //Remove CollectionAgent function
    function removeCollectionAgent (address _address) public onlyAdminOrOwner {
        require(_address != owner, 'Cannot remove owner');
        delete collectionAgents[_address];
        agentIndex = agentIndex.sub(1);
        emit CollectionAgentRemoved('Collection Agent removed:',_address);
    }
    
    //Add Waste Bin function
    function addWasteBin (
        string memory _location,
        uint _capacity,
        address _address
        ) public onlyAdminOrOwner
    {
        WasteBin memory _wasteBinStruct;
        _wasteBinStruct.location = _location;
        _wasteBinStruct.isFull = false;
        _wasteBinStruct.capacity = _capacity;
        wasteBins[_address] = _wasteBinStruct;
        wasteBinIndex = wasteBinIndex.add(1);
        emit WasteBinAdded('New WasteBin added:', _location, _capacity, _address);
    }
    
    //Remove Waste Bin function
    function removeWasteBin (address _address) public onlyAdminOrOwner {
        require(_address != owner, 'Cannot remove owner');
        delete wasteBins[_address];
        wasteBinIndex = wasteBinIndex.sub(1);
        emit CollectionAgentRemoved('Waste Bin removed:',_address);
    }

    //Add participant function
    function addParticipant(
        string memory _fullName,
        string memory _email,
        uint _phoneNumber,
        address _address
        ) public {
        Participant memory _participantStruct;
        _participantStruct.fullName = _fullName;
        _participantStruct.email = _email;
        _participantStruct.phoneNumber = _phoneNumber;
        _participantStruct.weightPicked = 0;
		_participantStruct.paid = false;
		participants[_address] = _participantStruct;
        participantIndex = participantIndex.add(1);
        emit ParticipantAdded('New participant added:', _address);
    }

    //Remove participant function
    function removeParticipant(address _address) public onlyAdminOrOwner {
        require(_address != owner, 'Cannot remove owner');
        delete participants[_address];
        participantIndex = participantIndex.sub(1);
        emit ParticipantRemoved('Participant removed:', _address);
    }

    //Function to deposit plastic
    function depositPlastic(address _addressP, address _addressW, uint _weight) public {
        Participant memory participant;
        participants[_addressP] = participant;
        participant.weightPicked += _weight;
        participant.paid = false;
        WasteBin memory wasteBin;
        wasteBins[_addressW] = wasteBin;
        require(wasteBin.isFull == false, 'Waste Bin already full');
        require(wasteBin.capacity <= _weight, 'Waste Bin already full');
        wasteBin.capacity -= _weight;
        emit ParticipantDonated('Participant donated:', _addressP, _addressW, _weight);
    }
    
}