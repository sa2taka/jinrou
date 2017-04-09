require "./player.rb"

class Jinrou
  attr_accessor :players, :player_num

  def initialize
    Character.instance.wolves.each do |wolf|
      instance_variable_set("@#{wolf}", 0)
    end
    Character.instance.humans.each do |human|
      instance_variable_set("@#{human}", 0)
    end
    do_action_in_safe{ game_init }
  end

  #コマンドライン用の初期化関数
  def game_init
    puts "プレイヤーの人数を指定してください"
    do_action_in_safe do
      @player_num = gets.to_i()
      @player_num > 0 and @player_num <= 9
    end
    remaining = @player_num
    # 人狼は必ず存在するので特別枠
    puts "人狼の人数を指定してください"
    do_action_in_safe do
      @wolf = gets.to_i()
      @wolf > 0 and @wolf <= @player_num / 3
    end
    remaining -= @wolf
    # 人狼チームの人数取得
    Character.instance.wolves.each do |wolf|
      next if(wolf == "wolf")
      puts "#{wolf}の人数を指定してください"
      do_action_in_safe do
        eval("
          @#{wolf} = gets.to_i()
          @#{wolf} >= 0 and @#{wolf} <= 2 and remaining + @#{wolf} <= @player_num
        ")
      end
      eval("remaining -= @#{wolf}")
    end
    # 人間側チームの人数取得
    Character.instance.humans.each do |human|
      next if(human == "citizen")
      puts "#{human}の人数を指定してください"
      do_action_in_safe do
        eval("
          @#{human} = gets.to_i()
          @#{human} >= 0 and @#{human} <= 2 and remaining + @#{human} <= @player_num
        ")
      end
      eval("remaining -= @#{human}")
    end
    #市民も特別な枠とする
    @citizen = remaining
    self.instance_variables.each do |variable|
      puts "#{variable.to_s.gsub!(/@/, "")} : #{instance_variable_get(variable)}"
    end
    puts "でよろしいでしょうか?(y/N)"
    gets.chomp == "y"
  end

  def do_action_in_safe
    while(!yield)do end
  end
end
