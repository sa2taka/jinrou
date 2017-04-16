require "./voting.rb"
require "./character.rb"

class Player
  attr_accessor :name, :role
  @@names_and_roles = {}
  @@dead_names_and_roles = {}
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

  def wolf?(role)
    if Character.instance.opposite.include?(role.to_sym) then
      !Character.instance.wolves.include?(role.to_sym)
    else
      Character.instance.wolves.include?(role.to_sym)
    end
  end

  def confirmed
  end

  def after_noon_vote
    dest = gets.chomp
    while(dest.empty? or @name == dest or !@@names_and_roles.has_key?(dest)) do
      "もう一度入力してください"
      dest = gets.chomp
    end
    Voting.instance.normal_voting_place[dest] += 1
  end

  class << self
    def names_and_roles
      @@names_and_roles
    end

    def dead_names_and_roles
      @@dead_names_and_roles
    end

    def reset
      @@names_and_roles = []
    end

    def rem_user(user)
      @@dead_names_and_roles[user] = @@names_and_roles[user]
      @@names_and_roles.delete_if{|key, value| key == user}
    end
  end
end

# 村人(と多重人格)のみ
class Normal < Player
  def action
    puts "あなたの夜のアクションは人狼だと疑う人に投票することです"
    puts "人狼だと疑う人を選択してください"
    dest = gets.chomp
    while dest.empty? or @name == dest or !@@names_and_roles.has_key?(dest) do
      "もう一度入力してください"
      dest = gets.chomp
    end
    Voting.instance.human_voting_place[dest] += 1
  end
end


class Friend < Player
  def initialize(role, name)
    super(role, name)
  end

  def confirmed
    puts "あなたの仲間一覧"
    @friends = []
    @@names_and_roles.each do |name, role|
      @friends << name if @name != name and @role == role
    end

    @friends.each do |friend|
      print "#{friend} "
    end
    print "仲間はいません" if @friends.length == 0
    print "\n"
  end

  def action
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
    # ここでの@friendsは必ずconfirmedの後に実行されるので更新されたデータが入る
    # 人のクラスの内部事情に詳しいFriendクラスを許して
    while dest.empty? or @name == dest or !@@names_and_roles.has_key?(dest) or @friends.include?(dest) do
      "もう一度入力してください"
      dest = gets.chomp
    end
    if wolf? then
      puts "1〜3の値を入力してください"
      value = -1
      while value <= 0 or value > 3 do
        value = gets.to_i
      end
      Voting.instance.wolf_voting_place[dest] += value
    else
      Voting.instance.human_voting_place[dest] += 1
    end
  end
end

class Diviner < Player
  attr_accessor :already_divined_persons

  def initialize(role, name)
    @already_divined_persons = {}
    super(role, name)
  end

  def confirmed
    puts "占った人一覧"
    @already_divined_persons.each do |name, role|
      puts "#{name} : #{role}"
    end
    if @already_divined_persons.length == 0 then
      puts "占った人がいません"
    end
  end

  def action
    puts "占う人の名前を入力してください"
    dest = gets.chomp
    while dest.empty? or
          @name == dest or
          !Player.names_and_roles.has_key?(dest) or
          @already_divined_persons.has_key?(dest) do
      puts "もう一度正しく入力してください"
      dest = gets.chomp
    end
    role = @@names_and_roles[dest]
    @already_divined_persons[dest] = role
    puts "#{dest} さんの役職は #{role} でした"
    puts "確認したらEnterキーを押してください"
    gets
  end
end

class SpiritMedium < Normal
  def confirmed
    puts "亡くなった人とその役職"
    @@dead_names_and_roles do |name, role|
      puts "#{name} : #{role}"
    end
    if @@dead_names_and_roles.length == 0 then
      puts "亡くなった人がいません"
    end
  end
end
