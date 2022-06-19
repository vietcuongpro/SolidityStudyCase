This is an example of using 'Minimal Proxy Contract'

- What is Minimal Proxy Contract?    
    - In some case we want user deploy the contract
        - we compile contract, put bytecode in frontend & make user deploy. However this is  inefficient & gas costly. If contract is large & complex, deployment cost is very high & we are bombarding the chain with huge amounts of storage
        - Solution for this: implement minimal proxy standard
    
    - So minmal proxy contract -> cheaply clone contract functionality as the base contract but with its own storage state.
    The way this happen is through the low-level delegate-call

- In this project, we demonstrate a way of user deploy contract using minimal proxy contract
    - => User call CloneFactory._clone() which clone implementation of the contract that has logic we want, we keep track of all deployments through a mapping 'allClones'