require 'singleton'

class Character
  include Singleton
  attr_accessor :humans, :wolves
end
