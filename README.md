# BlockBlaster          
          
> On-chain turn-based shooting game built in Solidity      
          
![screenshot](https://dummyimage.com/600x200/000/fff&text=BlockBlaster+on-chain+game)    
        
## 🎮 Overview        
**BlockBlaster** is a simple yet strategic shooting game played on a 5x5 grid, where two players compete by deploying targets and firing limited shots. Everything happens **on-chain**, secured by smart contracts. 
             
- 🔫 3 shots per player             
- 🎯 5x5 target grid               
- 🧠 Strategic gameplay       
- ⛓️ 100% on-chain logic             
- 💡 Perfect starter project for learning game logic in Solidity       
   
## 🛠️ How It Works      
1. **Player 1** creates a game and submits their hidden grid of targets.    
2. **Player 2** joins with their own grid.          
3. Each player submits 3 shots.         
4. The smart contract compares shots vs targets.    
5. The player with the most hits wins.     
   
## 🧱 Game Mechanics     
- Each target grid is a `uint8[5][5]` matrix (0 = empty, 1 = target).   
- Each shot is submitted as a flattened index: `(x * 5 + y)`.   
- The game finishes when both players fire all 3 shots.     
- Draws are possible. 
 
## 🔐 Security & Fairness    
- To keep things simple, this version does not use commit-reveal (target grids are visible).  
- In a future version, commit-reveal or zk proofs can be added for fairness.       

## 📄 Contracts
- `BlockBlaster.sol` — main game contract

## 🧪 Tests
Testing can be done using [Hardhat](https://hardhat.org/) or [Foundry](https://book.getfoundry.sh/):

```bash
forge test
```

## 📦 Deploy
You can deploy with your favorite Solidity framework:

```bash
forge create BlockBlaster --rpc-url $RPC_URL --private-key $PRIVATE_KEY
```

## 📘 License
MIT — feel free to fork, play, and build on it.

---

> 💬 Built for fun by web3 builders. Add commit-reveal and turn it into a full battle game!
