require "./player.rb"

class Jinrou
  attr_accessor :player_num, :wait_time

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
    loop do
      action_in_night
      action_after_night
      break if end_game?
      action_in_noon
      break if end_game?
    end
    action_in_game_end
  end

  # キャラクターの人数の初期化関数, trueを返すまで続く
  def character_init
    puts "プレイヤーの人数を指定してください"
    do_action_in_safe do
      @player_num = gets.to_i
      @player_num > 0 and @player_num <= 9
    end
    remaining = @player_num
    # 人狼は必ず存在するので特別枠
    puts "人狼の人数を指定してください"
    do_action_in_safe do
      @wolf = gets.to_i
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
        @#{wolf} >= 0 and @#{wolf} <= 2 and @#{wolf} <= remaining
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
        @#{human} >= 0 and @#{human} <= 2 and @#{human} <= remaining
        ")
      end
      eval("remaining -= @#{human}")
    end
    # 市民も特別な枠とする
    @citizen = remaining
    instance_variables.each do |variable|
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
    roles.shuffle!
    @players_name.each_index do |index|
      if Character.instance.wolves.key?(roles[index].to_sym) then
        eval("#{Character.instance.wolves[roles[index].to_sym]}.new(roles[index], @players_name[index])")
      else
        eval("#{Character.instance.humans[roles[index].to_sym]}.new(roles[index], @players_name[index])")
      end
    end
    true # 特に意味もないけど他との整合性を取るために
  end

  # 昼の会話時間の設定
  def time_init
    puts "昼の会話の時間を設定してください[分](小数点可, デフォルト2分)"
    @wait_time = gets.to_f * 60
    @wait_time = 2 * 60 if @wait_time <= 0.0
  end

  # プレイヤーに確認させるための表示関数
  def first_contact
    confirm_players do |player|
      puts "あなたの役職は...#{player.role}です"
      puts "確認したらEnterキーを押してください"
      gets
    end
  end

  # ブロックがtrueを返すまで動作を続ける
  def do_action_in_safe
    until(yield) do  end # FIXME {}で治したい
    end

    # 画面をクリアする
    def clear_screen
      system "clear" or system "cls"
    end

    # プレイヤー一人ひとりに確認して特定の動作を行う
    def confirm_players
      Player.players.each do |player|
        do_action_in_safe do
          clear_screen
          puts "プレイヤー一覧"
          Player.players.each do |player|
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
      max_value = 1
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

    def action_in_night
      Player.reset_in_night
      confirm_players do |player|
        puts "あなたは#{player.role}です。"
        puts "これから夜のアクションを行ってください"
        player.action
      end
    end

    # 夜の行動が終わったあとの動作
    def action_after_night
      # 守られた人を殺さないための処理
      Voting.instance.wolf_voting_place.each_key do |key|
        Voting.instance.wolf_voting_place[key] = 0 if Player.saved_person.include?(key)
      end
      # 最も投票された人のうち一人をランダムに殺す処理
      died = key_has_max_value(Voting.instance.wolf_voting_place)
      died.shuffle!
      if died.length != 0 then
        kill_player(died[0])
        puts "昨晩なくなった人は... #{died[0]}さん です"
      else
        puts "昨晩亡くなった人は...いませんでした。"
      end

      # 疑われている人を表示する処理
      doubt = key_has_max_value(Voting.instance.human_voting_place)
      if doubt.empty?
        puts "疑われている人はいません"
      else
        print "疑われているのは "
        doubt.each { |item| print item, "さん "}
        puts "です"
      end
      puts "確認したらEnterを押してください"
      gets
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
      if punished.length > 1 then
        temp_voting_place = {}
        punished.each do |one|
          temp_voting_place[one] = 0
        end
        clear_screen
        temp_voting_place.each_key { |name| print "#{name}, " }
        print "\n"
        puts "以上の人が選択されました。この中から更に処刑する人を選んでください"
        sleep(2)
        confirm_players do |player|
          if temp_voting_place.key?(player.name) then
            puts "あなたに選択の権利はありません"
            sleep(2)
            next
          end
          puts "処刑される人々の選択肢"
          temp_voting_place.each_key { |name| print "#{name}, " }
          print "\n"
          if player.real_wolf? then
            puts "殺すべき人間を処刑しましょう"
          else
            puts "人狼だと思われる人を処刑しましょう"
          end
          do_action_in_safe do
            dest = gets.chomp
            while dest.empty? or player.name == dest or !temp_voting_place.key?(dest) do
              puts "もう一度入力してください"
              dest = gets.chomp
            end
            temp_voting_place[dest] += 1
          end
        end
        punished = key_has_max_value(temp_voting_place)
        punished.shuffle!
        if punished.length == 0
          punished << temp_voting_place.keys.shuffle[0]
        end
      end
      punished_one = punished[0]
      kill_player(punished[0])
      puts "処刑された人は... #{punished_one}さん です"
      puts "確認したらEnterを押してください"
      gets
    end

    def action_in_game_end
      if count_wolf_num.zero?
        puts "Human's team win!"
      else
        puts "Wolf's team win!"
      end
      puts "亡くなった人(上から亡くなった順)"
      Player.dead_names_and_roles.each { |name, role| puts "#{name} : #{role}" }
      puts "生きている人(上から登録順)"
      Player.players.each { |player| puts "#{player.name} : #{player.role}" }
      puts "Game end"
    end

    def kill_player(player_name)
      Player.players.delete_if { |player| player.name == player_name }
      Voting.instance.rem_user(player_name)
      Player.rem_user(player_name)
    end

    def end_game?
      wolf_num = count_wolf_num
      wolf_num.zero? or wolf_num >= Player.players.length - wolf_num
    end

    def count_wolf_num
      wolf_num = 0
      Player.players.each { |player| wolf_num += 1 if player.role.to_s == "wolf" }
      wolf_num
    end
  end
