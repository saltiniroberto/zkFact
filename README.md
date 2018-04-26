# zkFact


1. Run the Zokrates docker image mapping the local folder cotaining the Zokrates source file (.code) to the /root/zkfact folder of the docker image
   ```
   docker run -it -v <local folder>:/root/zkfact zokrates
   ```
1. `cd zkfact`
1. Compile the Zokrates code, generate the keys and the verifier contract
   1. Compile the Zokrate factorial source file (zkfact.code)
      ```
      ../ZoKrates/target/release/zokrates compile -i zkFact.code
      ```
   1. Generate the prover and verifier keys. Please note tha this repo already contains the set of prover and verifier keys used to gnerated the verifier.sol verifier contract included in the repo. Once the setup command is execute, the prover an verifier keys will be replaced with new keys and the verifier.sol contract will have to be generated again as explained below  
      ```
      ../ZoKrates/target/release/zokrates setup
      ```
   1. Generate the Verifier contract (verifier.sol)
      ````
      ../ZoKrates/target/release/zokrates export-verifier
      ````
1. Generate the zk proof
   1. Execute the compiled code provide the `main` input vlaue
      ```
      ../ZoKrates/target/release/zokrates compute-witness -a <input value>
      ```
      e.g.
      ```
      ../ZoKrates/target/release/zokrates compute-witness -a 4
      ```
   1. Generate the zk proof for the input value just provided
      ```
      ../ZoKrates/target/release/zokrates compute-witness -a 4
      ````
   1. Copy the lines from `A = ...` to `K = ...` to the Dapp Zokrates Proof field
1. The Dapp can be accessed from the following link: https://rawgit.com/saltiniroberto/zkFact/master/dapp/index.html#
