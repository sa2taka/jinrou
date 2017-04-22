require "./jinrou.rb"
wolves = { wolf: :Friend }
humans = { citizen: :Normal, 労働組合: :Diviner, お局様: :SpiritMedium}

Character.instance.wolves = wolves
Character.instance.humans = humans
Character.instance.opposite = []

Jinrou.new
