require 'singleton'

class Character
  include Singleton
  attr_accessor :humans, :wolves, :opposite
end
