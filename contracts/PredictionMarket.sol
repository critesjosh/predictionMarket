pragma solidity ^0.4.4;

contract PredictionMarket {

	address public owner;

	mapping (address => bool) public admins;
	mapping (bytes32 => Question) public questions;
	mapping (address => uint) public balances;

	struct Question {
		bool public initialized = false;
		bool public resolved = false;
		bool public result = false;
		uint public costPerBet;
		uint public balance = 0;
		mapping (address => bool) public guesses;
	}

	event LogNewAdmin(address _address);
	event LogNewQuestion(bytes32 question, bytes32 id);
	event LogGuess(address responder, bytes32 id, bool answer);
	event LogQuestionResolved(address resolver, bytes32 id, bool result);

	modifier isAdmin {
		require(administrators[msg.sender] == true);
		_;
	}

	function PredictionMarket(){
		owner = msg.sender;
	}

	function getIsAdmin(address _address)
		public
		constant
		returns(bool isIndeed)
	{
		returns admins[_address];
	}

	function addQuestion(string question, uint costPerBet)
		public
		isAdmin
		returns(bool success)
	{
		bytes32 id = keccak256(question);
		require(questions[id].initialized == false);
		require(costPerBet > 0);
		questions[id] = Question(true, false, costPerBet);
		// use log for question storage, don't need to use state variables since 
		// it won't change
		LogNewQuestion(question, id);
		return true;
	}

	function resolveQuestion(bytes32 id, bool result)
		public
		isAdmin
		returns(bool success)
	{
		require(questions[id].initialized == true); // make sure it was added
		questions[id].resolved = true;
		LogQuestionResolved(msg.sender, id, result);
		return true;
	}

	function getPayout(bytes32 id)
		public
		returns(bool success)
	{
		require(questions[id].resolved == true);
		require(questions[id].guesses[msg.sender] == questions[id].result);
	}

	function answer(bytes32 id, bool guess)
		public
		returns(bool success)
	{
		Question question = questions[id];
		require(question.initialized == true);
		require(msg.value > question.costPerBet);
		question.balance += costPerBet;
		question.guesses[msg.sender] = guess;

		msg.sender.transfer(msg.value - costPerBet);
		LogGuess(msg.sender, id, guess);
		return true;
	}
}