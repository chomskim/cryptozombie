module.exports = {
  networks: {
    development: {
      host: '127.0.0.1', // Localhost (default: none)
      port: 7545, // Standard Ethereum port (default: none)
      network_id: '*', // Any network (default: none)
      gas: 5000000,
    },
  },
  contracts_directory: './contracts/',
  contracts_build_directory: '../client-web3/artifacts',
  compilers: {
    solc: {
      version: '^0.8.4',
      settings: {
        optimizer: {
          enabled: true, // Default: false
          runs: 200, // Default: 200
        },
      },
    },
  },
}
