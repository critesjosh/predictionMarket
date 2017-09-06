pragma solidity ^0.4.4;

import './PredictionMarket.sol';

contract Hub is Stoppable {

	address[] public markets;
	mapping(address => bool) public marketExists;

	modifier onlyIfMarket(address market) {
		require(marketExists[market] == true);
		_;
	}

	event LogNewMarket(address marketAddress, address marketCreator);
	event LogMarketClosed(address sender, address marketAddress);
	event LogMarketOpen(address sender, address marketAddress);
	event LogMarketOwnerChanged(address sender, address market, address newOwner);

	function getMarketCount()
		public
		constant
		returns(uint storeCount)
	{
		return markets.length;
	}

	function createMarket()
		public
		returns(address marketContract)
	{
		PredictionMarket trustedMarket = new PredictionMarket();
		markets.push(trustedMarket);
		marketExists[trustedMarket] = true;
		LogNewStorefront(trustedMarket, msg.sender);
		return trustedMarket;
	}

	// pass through admin controls

	function closeMarket(address marketAddress)
		onlyOwner
		onlyIfMarket(marketAddress)
		returns(bool success)
	{
		PredictionMarket trustedMarket = Storefront(marketAddress);
		LogMarketClosed(msg.sender, trustedStorefront);
		return (trustedMarket.runSwitch(false));
	}

	function openStore(address marketAddress)
		onlyOwner
		onlyIfMarket(marketAddress)
		returns(bool success)
	{
		PredictionMarket trustedMarket = Storefront(marketAddress);
		LogMarketOpen(msg.sender, trustedStorefront);
		return (trustedMarket.runSwitch(true));
	}

	function changeStoreOwner(address marketAddress, address newOwner)
		onlyOwner
		onlyIfMarket(marketAddress)
		returns(bool success)
	{
		PredictionMarket trustedMarket = Storefront(marketAddress);
		LogMarketOwnerChanged(msg.sender, trustedStorefront, newOwner);
		return(trustedMarket.transferOwnership(newOwner));
	}

}