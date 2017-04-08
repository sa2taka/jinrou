class Player
  attr_accessor :name
  def initialize(name)
    @name = name
  end
  def wolf?
    Conifg.wolf.include?(@name)
  end
end
