require "./Character.rb"
require "./player.rb"

wolves = ["wolf"]
humans = ["citizen"]

Character.instance.wolves = wolves
Character.instance.humans = humans
puts Character.instance.wolves
puts Character.instance.humans
