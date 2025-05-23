# 定数管理クラス
class Constants
  # ステータス
  HP_MIN = 0           # HP最小値
  ATTACK_VARIANCE = 3  # こうげき力のブレ幅

  # 行動選択
  ACTION_ATTACK = 1  # こうげき
  ACTION_ESCAPE = 2  # 逃げる

  # こうげきタイプ
  ATTACK_TYPE_NORMAL = 1  # 通常
  ATTACK_TYPE_MAGIC = 2   # 魔法こうげき
end

# キャラクタークラス
class Character
  # アクセサ
  attr_accessor :name, :hp, :attack_damage, :attack_type, :is_player, :is_alive

  # キャラクターの初期設定を行う
  def initialize(name, hp, attack_damage, attack_type, is_player = false)
    @name = name                    # キャラクター名
    @hp = hp                        # HP
    @attack_damage = attack_damage  # こうげき力
    @attack_type = attack_type      # こうげきタイプ
    @is_player = is_player          # プレイヤーフラグ
    @is_alive = true                # 生存フラグ
  end

  # ダメージ計算処理
  def calculate_damage
    # ランダムダメージ(こうげき力±振れ幅)
    rand(@attack_damage - Constants::ATTACK_VARIANCE..@attack_damage + Constants::ATTACK_VARIANCE)
  end

  # ダメージ反映処理
  def receive_damage(damage)
    @hp -= damage  # ダメージ処理

    # 戦闘不能処理
    if @hp <= Constants::HP_MIN
      @hp = Constants::HP_MIN   # HPが0未満にならないよう調整
      @is_alive = false         # 生存フラグを下ろす
    end
  end
end

# ゲームを進行するクラス
class Game
  # ゲームの初期設定を行う
  def initialize
    @escape_flg = false  # 逃げるフラグ

    puts "↓勇者の名前を入力してください↓"
    hero_name = gets.chomp  # 入力受付

    # キャラクターを作成
    @heroes = create_heroes(hero_name)
    @monsters = create_monsters()
  end

  # ゲーム開始処理
  def start
    round = 0   # ラウンド数

    # 開始メッセージ
    puts "\n◆◆◆ モンスターが現れた！ ◆◆◆"

    loop do
      # ラウンド数
      round += 1
      puts "\n=== ラウンド #{round} ==="

      # ステータス表示
      @heroes.each { |character| display_status(character) }    # 勇者パーティ表示
      @monsters.each { |character| display_status(character) }  # モンスターパーティ表示

      # 勇者パーティのターン
      process_heroes_turn()

      # 逃げた場合
      break if @escape_flg

      # どちらかが全滅していたらループを抜ける
      break if party_destroyed?(@heroes) || party_destroyed?(@monsters)

      # モンスターのターン
      process_monsters_turn()

      # どちらかが全滅していたらループを抜ける
      break if party_destroyed?(@heroes) || party_destroyed?(@monsters)
    end

    if party_destroyed?(@monsters)
      puts "勇者パーティの勝利！"
      return
    elsif party_destroyed?(@heroes)
      puts "勇者たちは力尽きてしまった！"
    end

    puts "◆◆◆ GAME OVER ◆◆◆"
  end

  private

  # 勇者パーティの作成
  def create_heroes(hero_name)
    [
      Character.new(hero_name, 30, 6, Constants::ATTACK_TYPE_NORMAL, true),  # プレイヤーが操作する勇者
      Character.new('魔法使い', 20, 8, Constants::ATTACK_TYPE_MAGIC)          # 魔法使い(CPU)
    ]
  end

  # モンスターパーティの作成
  def create_monsters
    [
      Character.new('オーク', 30, 8, Constants::ATTACK_TYPE_NORMAL),    # オーク(CPU)
      Character.new('ゴブリン', 25, 6, Constants::ATTACK_TYPE_NORMAL)   # ゴブリン(CPU)
    ]
  end

  # こうげき共通
  def execute_attack(attacker, defender)  # (行動をするキャラクター, こうげき対象)
    # こうげきメッセージ
    case attacker.attack_type
    when Constants::ATTACK_TYPE_NORMAL
      puts "#{attacker.name}のこうげき！"
    when Constants::ATTACK_TYPE_MAGIC
      puts "#{attacker.name}の魔法こうげき！"
    end

    # ダメージ処理
    damage = attacker.calculate_damage()  # ダメージ計算
    defender.receive_damage(damage)       # ダメージ反映

    puts "#{defender.name} に #{damage} のダメージ！"  # ダメージ処理

    puts "#{defender.name} はたおれた！" unless defender.is_alive # 戦闘不能メッセージ
  end

  # 逃げる
  def execute_escape(character)
    puts "#{character.name}は逃げ出した！"
    @escape_flg = true # 逃げるフラグを立てる
  end

  # ステータス表示
  def display_status(character)
    puts "・【#{character.name}】 HP：#{character.hp} こうげき力：#{character.attack_damage}"
  end

  # 勇者パーティのターン
  def process_heroes_turn
    @heroes.each do |character|    #　@heroesの各オブジェクトを呼び出す
      next unless character.is_alive    # is_aliveがfalseなら以下の処理を行わない
      loop do
        # 行動選択
        if character.is_player
          # プレイヤー（勇者）のとき
          puts "\n↓行動を選択してください↓"
          puts "【#{Constants::ACTION_ATTACK}】こうげき"
          puts "【#{Constants::ACTION_ESCAPE}】逃げる"

          choice = gets.to_i  # 行動の入力を整数で受け付ける
        else
          # それ以外のとき
          choice = Constants::ACTION_ATTACK # デフォルトの選択
        end

        # 行動
        case choice
        when Constants::ACTION_ATTACK
          # こうげき
          target_character = @monsters.select(&:is_alive).sample            # 対象を絞る
          execute_attack(character, target_character) if target_character   # こうげき処理
          break   # ループを抜ける
        when Constants::ACTION_ESCAPE
          # 逃げる
          execute_escape(character)   # 逃げる処理
          return  # メソッドを抜ける
        else
          # 無効な選択
          puts "無効な選択肢です"
        end
      end
    end
  end

  # モンスターのターン
  def process_monsters_turn
    @monsters.each do |monster|
      next unless monster.is_alive
      target_character = @heroes.select(&:is_alive).sample          # 対象を絞る
      execute_attack(monster, target_character) if target_character # (行動をするキャラクター, こうげき対象)
    end
  end

  # パーティの全滅チェック
  def party_destroyed?(party)
    party.none?(&:is_alive)  # 全滅ならtrue
  end
end

# ゲーム開始
game = Game.new
game.start()