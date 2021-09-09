// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract WageManager{
    
    // Events
    event WageReceived(string _name, uint amount);
    
    
    // Structures
    struct Contractor{
        address contractorAddress;
        string name;
        uint reservedMoney;
        bool enableWithdrawal;
        bool enabled;
    }
    
    // Datas
    address platform;
    Contractor[] contractors;
    mapping (string =>  uint) contractorsByName;
    mapping (address => uint) contractorsByAddress;
    
    // Modifiers
    /*
    * Onyl the contract owner can perform this singole operation
    */
    modifier onlyPlatform(){
        require(msg.sender == platform);
        _;
    }
    
    modifier onlyContractorEnabledByName(string memory name){
        require(contractors[contractorsByName[name]].enabled, "Contractor has been disabled");
        _;
    }
    
    // Functions
    
    /*
    * Add a Contractor to the list of payable contractors. Starts with 0 as balance and not withdrawable
    */
    function addContractor(address _contractorAddress, string memory _name) public onlyPlatform {
        require(contractorsByName[_name] == 0, "Username already used");
        contractors.push(Contractor(_contractorAddress, _name, 0, false, true));
        uint id = contractors.length;
        contractorsByName[_name] = id;
        contractorsByAddress[_contractorAddress] = id;
    }
    
    /*
    * Reserve money for a specific contractor. Not enable withdrawals
    */
    function sendMoney(string memory _name) public payable onlyContractorEnabledByName(_name){
        uint id = contractorsByName[_name];
        contractors[id].reservedMoney = contractors[id].reservedMoney + msg.value;
    }
    
    /*
    * Enable Withdrawals for a specific contractor
    */
    function enableWithdraw(string memory _name) public onlyPlatform {
        uint id = contractorsByName[_name];
        contractors[id].enableWithdrawal = true;
    }

    /*
    * Disable Withdrawals for a specific contractor
    */
    function disableWithdraw(string memory _name) public onlyPlatform  onlyContractorEnabledByName(_name) {
        uint id = contractorsByName[_name];
        contractors[id].enableWithdrawal = false;
    }
    
    /*
    * Enable a specific contractor
    */
    function enableContractor(string memory _name) public onlyPlatform  onlyContractorEnabledByName(_name) {
        uint id = contractorsByName[_name];
        contractors[id].enabled = true;
    }
    /*
    * Disable a specific contractor
    */
    function disableContractor(string memory _name) public onlyPlatform  onlyContractorEnabledByName(_name) {
        uint id = contractorsByName[_name];
        contractors[id].enabled = false;
    }
    
    /*
    * Send the money to the specific contractor. 
    * Can be executed only by the contractor itself.
    * Restart at 0 the available money for the contractor.
    * Reset as not withdrawable for the contractor.
    * Emits WageReceived.
    */
    function receiveMoney() public {
        require(contractors[contractorsByAddress[msg.sender]].enableWithdrawal, "You can't withdraw money");
        uint id = contractorsByAddress[msg.sender];
        uint money = contractors[id].reservedMoney;
        contractors[id].reservedMoney = 0;
        contractors[id].enableWithdrawal = false;
        emit WageReceived(contractors[id].name, money);
        payable(msg.sender).transfer(money);
    }
}
