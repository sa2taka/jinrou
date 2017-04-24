require "./jinrou.rb"
wolves = { wolf: :Friend }
humans = { citizen: :Normal, 騎士: :Knight}

Character.instance.wolves = wolves
Character.instance.humans = humans
Character.instance.opposite = []

Jinrou.new
