class Numeric
  def sign
    self >= 0 ? 1 : -1
  end
end

class PlayScene < Scene
  def initialize
    super
    @map = Map.new
    @hero = Hero.new(@map)
  end

  def button_up(key)
    $game.close if key == Gosu::KbEscape
  end

  def draw
    @map.draw
    @hero.draw
  end

  def update
    @hero.update
  end
end

class Map
  SIZE = 48

  def initialize
    @images = $game.images
    @tiles = [
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],

    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],

    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
    ]
  end

  def draw
    self.rows.times do |row|
      self.cols.times do |col|
        img = self.gfx_tile(col, row)
        img.draw(col * SIZE, row * SIZE, 0) unless img.nil?
      end
    end
  end

  def gfx_tile(col, row)
    case @tiles[row][col]
    when 1 then @images[:grass]
    else nil
    end
  end

  def phy_tile(col, row)
    if col < self.cols and col >= 0 and row < self.rows and row >= 0
      case @tiles[row][col]
      when 1 then :solid
      else :void
      end
    else
      nil
    end
  end

  def screen_to_map(x, y)
    [x / SIZE, y / SIZE]
  end

  def rows
    @tiles.size
  end

  def cols
    @tiles.first.size
  end
end

module Entity
  @x = 0
  @y = 0
  @map = nil
  @width = Map::SIZE
  @height = Map::SIZE

  def clamp_inc(inc_x, inc_y)
    # clamp x
    clamped_inc_x = 0
    if inc_x != 0
      0.upto(inc_x.abs) do |i|
        if self.phy_tile(@x + i * inc_x.sign, @y) == :solid
          break
        else
          clamped_inc_x = i * inc_x.sign
        end
      end
    end

    # clamp y
    clamped_inc_y = 0
    if inc_y != 0
      0.upto(inc_y.abs) do |i|
        if self.phy_tile(@x, @y + i * inc_y.sign) == :solid
          break
        else
          clamped_inc_y = i * inc_y.sign
        end
      end
    end

    [clamped_inc_x, clamped_inc_y]
  end

  def phy_tile(x, y)
    col, row = @map.screen_to_map(x, y)
    @map.phy_tile(col, row)
  end
end

class Hero
  include Entity

  def initialize(map)
    @image = $game.images[:hero]
    @map = map
    @x = 0
    @y = 0
  end

  def draw
    @image.draw_rot @x, @y, 1, 0
  end

  def update
    if $game.button_down?(Gosu::KbRight)
      inc_x = 300 * $game.delta
    elsif $game.button_down?(Gosu::KbLeft)
      inc_x = -300 * $game.delta
    else
      inc_x = 0
    end

    if $game.button_down?(Gosu::KbDown)
      inc_y = 300 * $game.delta
    elsif $game.button_down?(Gosu::KbUp)
      inc_y = -300 * $game.delta
    else
      inc_y = 0
    end

    inc_x, inc_y = self.clamp_inc(inc_x, inc_y)
    @x += inc_x
    @y += inc_y
  end
end
