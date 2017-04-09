require 'singleton'

class Voting
  include Singleton
  attr_accessor :human_voting_place, :wolf_voting_place, :normal_voting_place
  @human_voting_place = {}
  @wolf_voting_place = {}
  @normal_voting_place = {}

  def reset
    @human_voting_place = {}
    @wolf_voting_place = {}
    @normal_voting_place = {}
  end
end
