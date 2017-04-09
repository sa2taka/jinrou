require 'singleton'

class Character
  include Singleton
  attr_accessor :humans, :wolves, :opposite
  def initialize()
    @humans = []
    @wolves = []
  end
end
