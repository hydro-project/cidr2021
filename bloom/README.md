# Bloom Prototypes of Hydrologic Examples
This directory hosts Bloom implementations of the Hydrologic Program semantics facets from the CIDR 2021 paper [New Directions in Cloud Programming](https://arxiv.org/abs/2101.01159).

To get started with Bloom, install a recent version of Ruby and run 
```bash 
gem install bud
```
Then you should be ready to run the code in the `bloom` subdirectory. 

Documentation for Bloom is available [in the Bloom repo](https://github.com/bloom-lang/bud/tree/master/docs); the syntax of the language is covered pretty fully in the extensive [cheat sheet](https://github.com/bloom-lang/bud/blob/master/docs/cheat.md).

Each subdirectory has a shell script `test.sh` for trying out the code. For the distributed examples you will have to install [tmux](https://github.com/tmux/tmux/wiki) to run many processes in a single terminal. Alternatively you can open a number of terminals by hand and copy/paste the commands found in the `test.sh` files.
