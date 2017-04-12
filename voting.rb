require 'singleton'

class Voting
  include Singleton
  attr_accessor :human_voting_place, :wolf_voting_place, :normal_voting_place

  def initialize
    reset
  end

  def reset
    @human_voting_place = {}
    @wolf_voting_place = {}
    @normal_voting_place = {}
  end

  def add_user(user)
    @human_voting_place.store(user, 0)
    @wolf_voting_place.store(user, 0)
    @normal_voting_place.store(user, 0)
  end

  def rem_user(user)
    @human_voting_place.delete(user)
    @wolf_voting_place.delete(user)
    @normal_voting_place.delete(user)
  end
end
