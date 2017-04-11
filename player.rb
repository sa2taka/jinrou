require "./voting.rb"
require "./character.rb"

class Player
  attr_accessor :name, :role
  def initialize(role, name)
    @name = name
    @role = role
  end

  def wolf?
    if(Character.instance.opposite.include?(@role)) then
      !Character.instance.wolf.include?(@role)
    else
      Character.instance.wolf.include?(@role)
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
