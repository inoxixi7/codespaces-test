# ゲームを進行するクラス
class Game
  # ゲームの初期設定
  def initialize
    puts "↓勇者の名前を入力してください↓"
    hero_name = gets.chomp  # ユーザの入力を取得

    puts "勇者の名前は#{hero_name}です。"
  end
end

# ゲーム開始
Game.new