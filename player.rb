require "./voting.rb"
require "./character.rb"

class Player
  attr_accessor :name, :player_name
  def initialize(name, player_name)
    @name = name
    @player_name = player_name
  end

  def wolf?
    if(Character.instance.opposite.include?(@name)) then
      !Character.instance.wolf.include?(@name)
    else
      Character.instance.wolf.include?(@name)
    end
  end

  def night_vote(user)
    if(Voting.instance.normal_voting_place.has_key(user))
      Voting.instance.normal_voting_place[user] += 1
      true
    else
      false
    end
  end
end

class Normal < Player
  def action(user, value = 1)
    if(Voting.instance.normal_voting_place.has_key(user))
      if(wolf?)
        Voting.instance.wolf_voting_place[user] += value
      else
        Voting.instance.hunam_voting_place[user] += value
      end
      true
    else
      false
    end
  end
end
