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

<<<<<<< HEAD
  def vote(user)
    Voting.instance.normal_voting_place[user] += 1
=======
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
>>>>>>> refs/remotes/origin/plottype
  end
end

# 村人(と多重人格)のみ
class Normal < Player
  def action()
    puts "投票先を選択してください"
    dest = gets.chomp
    while(dest.empty? or @name == dest or !Player.names.include?(dest)) do
      "もう一度入力してください"
      dest = gets.chomp
    end
    Voting.instance.human_voting_place[dest] += 1
  end
end

class Friend < Player
  attr_accessor: friends
  def initialize
    super
    friends = []
  end

  def add_friends(name)
    friends << name
  end

  def action()
    puts "投票先を選択してください"
    dest = gets.chomp
    while(dest.empty? or @name == dest or !Player.names.include?(dest)) do
      "もう一度入力してください"
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
