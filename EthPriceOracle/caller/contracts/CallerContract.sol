pragma solidity >=0.5.0 <0.6.0;
import "./EthPriceOracleInterface.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
contract CallerContract is Ownable { // 2. Make the contract inherit from `Ownable`
    EthPriceOracleInterface private oracleInstance;
    address private oracleAddress;
    event newOracleAddressEvent(address oracleAddress);
    function setOracleInstanceAddress (address _oracleInstanceAddress) public onlyOwner{
      oracleAddress = _oracleInstanceAddress;
      oracleInstance = EthPriceOracleInterface(oracleAddress);
      emit newOracleAddressEvent(oracleAddress);
    }

    function updateEthPrice() public {
        uint256 id = oracleInstance.getLatestEthPrice();
        myRequests[id] = true;
        emit ReceivedNewRequestIdEvent(id);
    }
}
