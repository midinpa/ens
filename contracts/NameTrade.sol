pragma solidity ^0.4.13;

import './AbstractENS.sol';

contract NameTrade {

    AbstractENS ens;
    mapping (bytes32 => sellInfo) public nodeSellInfo;

    struct sellInfo {
      address originOwner;
      uint price;
    }

    event SellNode(bytes32 indexed node, uint indexed price, address indexed originOwner);
    event BuyNode(bytes32 indexed node, address indexed originOwner, address indexed newOwner);

    modifier onlyOwner(bytes32 node) {
      require(ens.owner(node) == msg.sender);
      _;
    }

    function NameTrade(AbstractENS _ens){
      ens = _ens;
    }

    function getNodeOwner(bytes32 node) constant returns (address) {
      return ens.owner(node);
    }

    function sellNode(bytes32 node, uint price) onlyOwner(node) {
      require(price > 0);

      sellInfo info = nodeSellInfo[node];
      info.originOwner = msg.sender;
      info.price = price;

      SellNode(node, price, msg.sender);
    }

    function buyNode(bytes32 node) payable {
      require(ens.owner(node) == address(this));

      sellInfo info = nodeSellInfo[node];

      require(info.price > 0);
      require(info.price < msg.value);

      info.originOwner.transfer(info.price);
      uint toReturn = msg.value - info.price;

      if(toReturn > 0) {
        msg.sender.transfer(toReturn);
      }

      ens.setOwner(node,msg.sender);
      BuyNode(node, info.originOwner, msg.sender);
    }
}
