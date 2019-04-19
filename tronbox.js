require('dotenv').config()
const port = process.env.HOST_PORT || 9090

module.exports = {
  networks: {
    mainnet: {
      // Don't put your private key here:
      privateKey: process.env.PRIVATE_KEY_MAINNET,
      /*
        Create a .env file (it must be gitignored) containing something like
        export PRIVATE_KEY_MAINNET=4E7FECCB71207B867C495B51A9758B104B1D4422088A87F4978BE64636656243
        Then, run the migration with:
        source .env && tronbox migrate --network mainnet
      */
      userFeePercentage: 100,
      feeLimit: 1e8,
      fullHost: "https://api.trongrid.io",
      network_id: "1"
    },
    shasta: {
      // from: 'TS9MTtGe6z1csY7z33V2Mi3i8441YfouKe',
      privateKey: '8e0145af26cee3a398f7fa5cf9cdcba0656df85da6060b3887272227d35dfe0f',
      userFeePercentage: 30,
      feeLimit: 1e8,
      fullHost: "https://api.shasta.trongrid.io",
      network_id: "2"
    },
    development: {
      // For trontools/quickstart docker image
      privateKey: 'da146374a75310b9666e834ee4ad0866d6f4035967bfc76217c5a495fff9f0d0',
      userFeePercentage: 30,
      feeLimit: 1e8,
      fullHost: 'http://127.0.0.1:' + port,
      network_id: "9"
    },
    production: {
        privateKey: '8e0145af26cee3a398f7fa5cf9cdcba0656df85da6060b3887272227d35dfe0f',
        consume_user_resource_percent: 30,
        fee_limit: 100000000,
        fullNode: "https://api.shasta.trongrid.io",
        solidityNode: "https://api.shasta.trongrid.io",
        network_id: "322"
    },
  }
}
