# [Blitz Tactics](https://blitztactics.com)

A free and open-source website for playing fast-paced chess puzzles!

If you want to play random puzzles each time:

* [Three](https://blitztactics.com/three) - three minutes, three lives, three hints.
* [Haste](https://blitztactics.com/haste) - correct moves gain time, mistakes lose time.

These puzzles change daily:

* [Countdown](https://blitztactics.com/countdown) - solve puzzles before time runs out
* [Speedrun](https://blitztactics.com/speedrun) - solve puzzles as quickly as you can

For more ways to play:

* [Repetition](https://blitztactics.com/repetition) - solve every puzzle quickly and precisely to unlock the next level
* [Infinity](https://blitztactics.com/infinity) - play through endless puzzles and set your own difficulty

<div align="center">
  <br>
  <a href="https://blitztactics.com" target="_blank">
    <img src="https://blitztactics.com/demo.gif">
  </a>
  <br><br>
</div>

## Development

The backend uses [Rails 6](https://rubyonrails.org/), [Ruby 2.7.3](https://www.ruby-lang.org/en/news/2021/04/05/ruby-2-7-3-released/), and [Node 12.x LTS](https://nodejs.org/en/download/releases/). [Postgres 9](https://www.postgresql.org/) is used for the database. Chess puzzle data is imported into the database from [JSON data files](https://github.com/linrock/blitz-tactics-puzzles).

The frontend uses a modified version of [Chessground](https://github.com/ornicar/chessground) for the
interactive chessboard and [chess.js](https://github.com/jhlywa/chess.js) for chess logic. User interfaces are implemented with [Vue 3](https://vuejs.org/) and some legacy [Backbone.js](https://backbonejs.org/) code. [Webpack 4](https://v4.webpack.js.org/) and [Sprockets 4](https://github.com/rails/sprockets) are both used for asset compilation.

### Development instructions

First make sure your dev environment is set up for Ruby and Typescript development.
You'll need [Yarn](https://yarnpkg.com/) and maybe a Ruby version manager like
[chruby](https://github.com/postmodern/chruby) or [RVM](https://rvm.io/).
Then from within your git clone of the codebase, these steps will get you
a dev environment with the chess puzzles used on the site:

```bash
bundle install    # install ruby gems
yarn install      # install node_modules

rails db:create   # set up an empty postgres db: blitz-tactics_development
rails db:migrate  # sets up the db schema

yarn lichess:puzzles:fetch   # downloads ~125k lichess v1 puzzles as JSON files
yarn lichess:puzzles:import  # import puzzles from JSON into the db (15+ min)
yarn lichess:puzzles:check   # should confirm the puzzles were loaded

yarn blitz:game_modes:fetch  # downloads puzzles used on blitztactics.com as JSON files
yarn blitz:game_modes:import # imports game modes puzzles into the db (6+ min)
yarn blitz:game_modes:check  # prints the number of puzzles in the db for each game mode
```

* Run a rails dev server: `rails s`
* Run a webpack dev server: `yarn dev` or `./bin/webpack-dev-server`

Go to `http://localhost:3000/` and you'll see the Blitz Tactics homepage if all went well.

## Special thanks

* [Stepmania](http://www.stepmania.com/) - inspiration for the original game mechanics
* [lichess](https://lichess.org/) - tactics puzzles and awesome community's feedback
