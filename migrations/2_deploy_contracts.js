var SCG = artifacts.require("./SCG.sol");
var Portal = artifacts.require("./Portal.sol");
var DiceTRX = artifacts.require("./DiceTRX.sol");

module.exports = function(deployer) {
	const _rtp = 985;
	const _rtpDivider = 1000;
	const _minBet = 1;
	const _maxBet = 10;

	return deployer
		.then(() => {
			return deployer.deploy(SCG);
		})
		.then(() => {
			return deployer.deploy(
				Portal,
				SCG.address
			);
		})
		.then(() => {
			return deployer.deploy(
				DiceTRX,
				Portal.address,
				_rtp,
				_rtpDivider,
				_minBet,
				_maxBet
			);
		});
};