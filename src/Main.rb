require 'rubygems'
require 'gosu'

require_relative 'core'
require_relative 'world'

$game = Game.new
$game.switch_scene(PlayScene)
$game.show
