var app = angular.module('oracleApp', []);

app.config(function($locationProvider){
	$locationProvider.html5Mode({
		enabled:true,
		requireBase:false
	});
});

// Objectives:
// 
// + as an administrator, you can add a yes/no question.
// + as a regular user you can bet on an outcome of the question.
// + as a trusted source, you can resolve the question.
// + as a regular user, you can trigger the mutual-based payouts.

// future features:
// access to oracles.
// market-making.

app.controller("oracleController",
	['$scope', '$location', '$http', '$q', '$window', '$timeout',

	function($scope, $location, $http, $q, $window, $timeout) {

		Storefront.deployed()
		.then(function(_instance){
			$scope.contract = _instance;
			console.log("The contract:", $scope.contract);


			return $scope.getOwnerStatus();
		});

	// get block number
	$scope.getCurrentBlockNumber = function(){
		web3.eth.getBlockNumber(function(err, bn){
			if(err) {
				console.log('error', err);
			} else {
				console.log('current block:', bn);
				$scope.blockNumber = bn;
				$scope.$apply();
			}
		});
	}

	$scope.getOwnerStatus = function() {
		return $scope.contract.owner({from: $scope.account})
		.then(function(_owner){
			$scope.isOwner = (_owner === $scope.account);
			console.log("i am the contract owner:", $scope.isOwner);
			$scope.$apply();
			return $scope.getAdminStatus();
		});
	}

	$scope.getAdminStatus = function(){
		return $scope.contract.getAdmin({from: $scope.account})
		.then(function(_admins){
			console.log("admins", _admins);
			$scope.isAdmin = _admins;
			$scope.$apply();
		});
	}

	//work with first account
	web3.eth.getAccounts(function(err, accs){
		if(err != null){
			alert("there was an error fetching your accounts.");
			return;
		}
		if(accs.length == 0) {
			alert("Couldn't find any accounts.");
			return;
		}
		$scope.accounts = accs;
		$scope.account = $scope.accounts[0];
		console.log("using account", $scope.account);

		web3.eth.getBalance($scope.account, function(err, _balance){
			$scope.balance = _balance.toString(10);
			console.log("balance", $scope.balance);
			$scope.balanceInEth = web3.fromWei($scope.balance, "ether");
			$scope.$apply();
			//return $scope.contract.owner({from: $scope.account});
		});

	});	

}]);