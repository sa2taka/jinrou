require "./voting.rb"
require "./character.rb"

class Player
  attr_accessor :name, :role
  @@names = []
  def initialize(role, name)
    @name = name
    @@names << name
    @role = role
  end

  def wolf?
    if(Character.instance.opposite.include?(@role)) then
      !Character.instance.wolves.include?(@role)
    else
      Character.instance.wolves.include?(@role)
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

  def self.names
    @@names
  end

  def self.reset_names
    @@names = []
  end
end

class Normal < Player
  def action()
    puts "投票先を選択してください"
    dest = ""
    while(dest.empty? or @names == dest or !Player.names.include?(dest)) do
      dest = gets.chomp
    end
    if(wolf?)
      puts "1〜3の値を入力してください"
      value = -1
      while(value <= 0 or value > 3) do
        value = gets.to_i
      end
      Voting.instance.wolf_voting_place[dest] += value
    else
      Voting.instance.human_voting_place[dest] += 1
    end
  end
end
