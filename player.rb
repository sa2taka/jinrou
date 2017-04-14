require "./voting.rb"
require "./character.rb"

class Player
  attr_accessor :name, :role
  @@names_and_roles = {}
  def initialize(role, name)
    @name = name
    @@names_and_roles[name] = role
    @role = role
  end

  def wolf?
    if Character.instance.opposite.include?(@role.to_sym) then
      !Character.instance.wolves.include?(@role.to_sym)
    else
      Character.instance.wolves.include?(@role.to_sym)
    end
  end

  def real_wolf?
    Character.instance.wolves.include?(@role.to_sym)
  end

  def confirmed
  end

  def after_noon_vote()
    dest = gets.chomp
    while(dest.empty? or @name == dest or !Player.names_and_roles.has_key?(dest)) do
      "もう一度入力してください"
      dest = gets.chomp
    end
    Voting.instance.normal_voting_place[dest] += 1
  end

  def self.names_and_roles
    @@names_and_roles
  end

  def self.reset
    @@names_and_roles = []
  end

  def self.rem_user(user)
    @@names_and_roles.delete_if{|key, value| key == user}
  end
end

# 村人(と多重人格)のみ
class Normal < Player
  def action()
    puts "あなたの夜のアクションは人狼だと疑う人に投票することです"
    puts "人狼だと疑う人を選択してください"
    dest = gets.chomp
    while(dest.empty? or @name == dest or !Player.names_and_roles.has_key?(dest)) do
      "もう一度入力してください"
      dest = gets.chomp
    end
    Voting.instance.human_voting_place[dest] += 1
  end
end


class Friend < Player
  attr_accessor :friends
  def initialize(role, name)
    super(role, name)
    @friends = []
  end

  def add_friend(name)
    friends << name
  end

  def confirmed
    puts "あなたの仲間一覧"
    friends.each do |friend|
      print "#{friend} "
    end
    print "仲間はいません" if friends.length == 0
    print "\n"
  end

  def action()
    print "あなたの夜のアクションは"
    if wolf? then
      puts "殺す人を投票で決めることです"
      print "殺したい"
    else
      puts "人狼である人を予想することです"
      print "人狼だと思う"
    end
    puts "人を選択してください"
    dest = gets.chomp
    while(dest.empty? or @name == dest or !Player.names_and_roles.has_key?(dest) or @friends.include?(dest)) do
      "もう一度入力してください"
      dest = gets.chomp
    end
    if wolf? then
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
