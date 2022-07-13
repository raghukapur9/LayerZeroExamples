// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma abicoder v2;

import "NonblockingLzApp.sol";

/// @title A LayerZero example sending a cross chain message from a source chain to a destination chain to increment a counter
contract OmniCounter is NonblockingLzApp {
    uint public counter;

    constructor(address _lzEndpoint) NonblockingLzApp(_lzEndpoint) {}

    function _nonblockingLzReceive(uint16, bytes memory, uint64, bytes memory) internal override {
        counter += 1;
    }

    function incrementCounter(uint16 _dstChainId, address _dstPingPongAddr) public payable {
        // use adapterParams v1 to specify more gas for the destination
        uint16 version = 1;
        uint gasForDestinationLzReceive = 350000;
        bytes memory adapterParams = abi.encodePacked(version, gasForDestinationLzReceive);

        // get the fees we need to pay to LayerZero for message delivery
        (uint messageFee, ) = lzEndpoint.estimateFees(_dstChainId, address(this), bytes(""), false, adapterParams);
        require(address(this).balance >= messageFee, "address(this).balance < messageFee. fund this contract with more ether");
    
        lzEndpoint.send{value: messageFee}(_dstChainId,abi.encodePacked(_dstPingPongAddr), bytes(""), payable(msg.sender), address(0x0), adapterParams);
    }
    // allow this contract to receive ether
    receive() external payable {}
}