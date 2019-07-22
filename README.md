# Blitz Tactics

A fast-paced chess tactics trainer that helps you develop speed and accuracy by drilling tactical patterns into your mind... in a fun way!

Solve every puzzle quickly and precisely to unlock the next level.

<div align="center">
  <br>
  <a href="https://blitztactics.com" target="_blank">
    <img src="https://blitztactics.com/demo.gif">
  </a>
  <br><br>
</div>

## Install Instruccions

1. Git clone the repo to your local computer:
	`git clone https://github.com/linrock/blitz-tactics
2. Run `bundle install`. If you run into issues please have in mind that **postgresql** is required and for **ffi** please check [this](https://www.reddit.com/r/ruby/comments/a8brq3/an_error_occurred_while_installing_ffi_1925_and/).
3. Edit `config/database.yml` with your postgres enviroment creds. Maybe you'll like to set the same config for the three env to avoid errors like ´fe_sendauth: no password supplied´.
4. Run `bin/setup`.
5. Run `bin/webpack-server-dev` or `bin/webpack`. Your local env is ready!


## Special thanks

* [chess.js](https://github.com/jhlywa/chess.js) - javascript library used for the chessboard
* [Stepmania](http://www.stepmania.com/) - inspiration for the game mechanics
* [lichess](https://lichess.org/) - tactics puzzles and awesome community's feedback


## License

MIT License
