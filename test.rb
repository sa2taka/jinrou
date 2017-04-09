require "./jinrou.rb"
wolves = ["wolf", "multiple"]
humans = ["citizen", "diviner"]

Character.instance.wolves = wolves
Character.instance.humans = humans

game = Jinrou.new
game.players = []
game.players << "a"
p game.instance_variables
