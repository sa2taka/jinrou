require "./jinrou.rb"
wolves = {wolf: :Friend}
humans = {citizen: :Normal}

Character.instance.wolves = wolves
Character.instance.humans = humans
Character.instance.opposite = []

game = Jinrou.new
