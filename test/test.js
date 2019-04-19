var Test = artifacts.require("./Test.sol");
contract('Test', function(accounts) {
	it("Calling method f()", function() {
		Test.deployed().then(function(instance) {
			return instance.send('f');
		}).then(function(result) {
			assert.equal("true", result[0], "is not call method f");
		});
	});
	it("Calling method g()", function() {
		Test.deployed().then(function(instance) {
			return instance.call('g');
		}).then(function(result) {
			assert.equal("method g()", result[0], "is not call method g");
		});
	});
});