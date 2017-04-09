require "./player.rb"

class Jinrou
  attr_accessor :players

  def initialize 
    Character.instance.wolves.each do |wolf|
      instance_variable_set("@#{wolf}", 0)
    end
    Character.instance.humans.each do |human|
      instance_variable_set("@#{human}", 0)
    end
  end
end
