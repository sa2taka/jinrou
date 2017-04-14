require "./player.rb"

class Jinrou
  attr_accessor :players, :player_num, :wait_time

  def initialize
    Character.instance.wolves.each_key do |wolf|
      instance_variable_set("@#{wolf}", 0)
    end
    Character.instance.humans.each_key do |human|
      instance_variable_set("@#{human}", 0)
    end
    clear_screen
    do_action_in_safe{ character_init }
    do_action_in_safe do
      @players_name = []
      name_init
    end
    @players_name.each do |name|
      Voting.instance.add_user(name)
    end
    role_init
    time_init
    first_contact
    main_loop
  end

  private

  def main_loop
    confirm_players do |player|
      puts "あなたは#{player.role}です。"
      puts "これから夜のアクションを行ってください"
      player.action
    end
    action_after_night
    action_in_noon
    p players
  end

  #キャラクターの人数の初期化関数, trueを返すまで続く
  def character_init
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
    Character.instance.wolves.each_key do |wolf|
      next if wolf == :wolf
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
    Character.instance.humans.each_key do |human|
      next if human == :citizen
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

  # プレイヤーの名前の初期化関数、trueを返すまで続く
  def name_init
    puts "名前を順番に入力してください"
    @player_num.times do |i|
      do_action_in_safe do
        print "#{i + 1}番目の名前 : "
        name = gets.chomp
        is_include = @players_name.include?(name)
        @players_name << name unless is_include
        !is_include
      end
    end
    @players_name.each_index { |index| puts "#{index + 1} : #{@players_name[index]}" }
    puts "でよろしいでしょうか?(y/N)"
    gets.chomp == "y"
  end

  # 配役の初期化
  def role_init
    roles = []
    Character.instance.wolves.each_key do |wolf|
      eval("@#{wolf}.times { roles << '#{wolf}' } ")
    end
    Character.instance.humans.each_key do |human|
      eval("@#{human}.times { roles << '#{human}' } ")
    end
    @players = []
    roles.shuffle!
    @players_name.each_index do |index|
      if Character.instance.wolves.has_key?(roles[index].to_sym) then
        eval("@players << #{Character.instance.wolves[roles[index].to_sym]}.new(roles[index], @players_name[index])")
      else
        eval("@players << #{Character.instance.humans[roles[index].to_sym]}.new(roles[index], @players_name[index])")
      end
    end
    true # 特に意味もないけど他との整合性を取るために
  end

  # 昼の会話時間の設定
  def time_init
    puts "昼の会話の時間を設定してください[分](小数点可, デフォルト2分)"
    @wait_time = gets.to_f() * 60
    @wait_time = 2 * 60 if @wait_time <= 0.0
  end

  # プレイヤーに確認させるための表示関数
  def first_contact
    @players.each do |player|
      @players.each do |compare|
        next if compare.name == player.name
        player.add_friend(compare.name) if player.role == compare.role and player.kind_of?(Friend)
      end
    end
    confirm_players do |player|
      puts "あなたの役職は...#{player.role}です"
      puts "確認したらEnterキーを押してください"
      gets
    end
  end

  # ブロックがtrueを返すまで動作を続ける
  def do_action_in_safe
    while(!yield) do
      # FIXME こう書かないとエラーになるけど1行に収めたい(do endなら1行で収まる)
    end
  end

  # 画面をクリアする
  def clear_screen
    system "clear" or system "cls"
  end

  # プレイヤー一人ひとりに確認して特定の動作を行う
  def confirm_players
    @players.each do |player|
      do_action_in_safe do
        clear_screen
        puts "プレイヤー一覧"
        @players.each do |player|
          print "#{player.name} "
        end
        print "\n"
        puts "あなたは#{player.name}さんですか?(y/N)"
        gets.chomp == "y"
      end
      player.confirmed
      yield(player)
    end
  end

  # hash内のvalueが最も大きい( < 等で比べる)時のキーを返す
  def key_has_max_value(hash)
    max_value = 0
    res = []
    hash.each do |key, value|
      if max_value < value then
        res = []
        res << key
        max_value = value
      elsif max_value == value then
        res << key
      end
    end
    res
  end

  # 夜の行動が終わったあとの動作
  def action_after_night
    # 最も投票された人のうち一人をランダムに殺す処理
    died = key_has_max_value(Voting.instance.wolf_voting_place)
    died.shuffle!
    rem_user(died[0])
    players.each{|player| puts player.name}
    puts "昨晩なくなった人は... #{died[0]}さん です"

    # 疑われている人を表示する処理
    doubt = key_has_max_value(Voting.instance.human_voting_place)
    if doubt.empty?
      puts "疑われている人はいません"
    else
      print "疑われているのは "
      doubt.each{|item| print item, "さん "}
      puts "です"
    end
  end

  def action_in_noon
    puts "夜が明け昼になりました"
    puts "皆さんで情報を交換して人狼を見つけてください"
    puts "会話時間は約#{((@wait_time / 60) + 0.5).to_i}分です"
    sleep(@wait_time)
    confirm_players do |player|
      if player.real_wolf? then
        puts "殺すべき人間を処刑しましょう"
      else
        puts "人狼だと思われる人を処刑しましょう"
      end
      do_action_in_safe { player.after_noon_vote }
    end
    punished = key_has_max_value(Voting.instance.normal_voting_place)
    punished_one = ""
    if punished.length > 1 then
      temp_voting_place = {}
      punished.each do | one |
        temp_voting_place[one] = 0
      end
      clear_screen
      puts "処刑される人が二人以上になりましたのでもう一度投票してください"
      sleep(2)
      confirm_players do |player|
        if player.real_wolf? then
          puts "殺すべき人間を処刑しましょう"
        else
          puts "人狼だと思われる人を処刑しましょう"
        end
        do_action_in_safe do
          dest = gets.chomp
          while(dest.empty? or player.name == dest or !Player.names_and_roles.has_key?(dest)) do
            "もう一度入力してください"
            dest = gets.chomp
          end
          temp_voting_place[dest] += 1
        end
      end
      punished = key_has_max_value(temp_voting_place)
      punished.shuffle!
      punished_one = punished[0]
    else
      punished_one = punished[0]
    end
    rem_user(punished[0])
    puts "処刑された人は... #{punished_one}さん です"
  end

  def rem_user(user)
    players.delete_if{|player| player.name == user}
    Voting.instance.rem_user(user)
    Player.rem_user(user)
  end
end
