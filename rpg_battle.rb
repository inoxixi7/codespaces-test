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
  attr_accessor :name, :hp, :attack_damage, :attack_type ,:is_player, :is_alive

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
      @hp = Constants::HP_MIN    # HPが0未満にならないよう調整
      @is_alive = false          # 生存フラグを下ろす
    end
  end
end

# ゲームを進行するクラス
class Game
  # ゲームの初期設定を行う
  def initialize
    @escape_flg = false     # 逃げるフラグ

    puts "↓勇者の名前を入力してください↓"
    hero_name = gets.chomp  # 入力受付

    # キャラクターを作成
    @heroes = create_heroes(hero_name)
    @monsters = create_monsters()
  end

  # ゲーム開始処理
  def start
    # 開始メッセージ
    puts "\n◆◆◆ モンスターが現れた！ ◆◆◆"

    # 最新*ステータス表示
    display_status(@heroes)    # 勇者パーティ表示
    display_status(@monsters)  # モンスターパーティ表示

    # 勇者パーティのターン
    process_heroes_turn()

    return if @escape_flg  # 逃げた場合は終了

    # モンスターのターン
    process_monsters_turn()
  end

  private

  # 勇者パーティの作成
  def create_heroes(hero_name)
    Character.new(hero_name, 30, 6, Constants::ATTACK_TYPE_NORMAL, true)  # プレイヤーが操作する勇者
  end

  # モンスターパーティの作成
  def create_monsters
    Character.new('オーク', 30, 8, Constants::ATTACK_TYPE_NORMAL)  # オーク(CPU)
  end

  # こうげき共通
  def execute_attack(attacker, defender)  # (行動するキャラクター, こうげき対象)
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

    puts "#{defender.name} はたおれた！" unless defender.is_alive  # 戦闘不能メッセージ
  end

  # 逃げる
  def execute_escape(character)
    puts "#{character.name}は逃げ出した！"
    @escape_flg = true  # 逃げるフラグを立てる
  end

  # ステータス表示
  def display_status(character)
    puts "・【#{character.name}】 HP：#{character.hp} こうげき力：#{character.attack_damage}"
  end

  # 勇者パーティのターン
  def process_heroes_turn
    loop do
      puts "\n↓行動を選択してください↓"
      puts "【#{Constants::ACTION_ATTACK}】こうげき"
      puts "【#{Constants::ACTION_ESCAPE}】逃げる"
      choice = gets.to_i  # 行動の入力を整数で受け付ける

      # 行動
      case choice
      when Constants::ACTION_ATTACK
        # こうげき
        execute_attack(@heroes, @monsters)  # こうげき処理
        break                               # ループを抜ける
      when Constants::ACTION_ESCAPE
        # 逃げる
        execute_escape(@heroes)  # 逃げる処理
        return                   # メソッドを抜ける
      else
        # 無効な選択
        puts "無効な選択肢です"
      end
    end
  end

  # モンスターのターン
  def process_monsters_turn
    execute_attack(@monsters, @heroes)  # (行動するキャラクター, こうげき対象)
  end
end

# ゲーム開始
game = Game.new
game.start()