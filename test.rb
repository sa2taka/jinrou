require "./jinrou.rb"
wolves = {wolf: :Normal}
humans = {citizen: :Normal}

Character.instance.wolves = wolves
Character.instance.humans = humans

game = Jinrou.new
