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

  def draw
    @map.draw
    @hero.draw
  end

  def update
    @hero.update
  end

  def button_down(key)
    case key
    when Gosu::KbA then @hero.jump
    end
  end

  def button_up(key)
    case key
    when Gosu::KbEscape then $game.close
    end
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

  def clamp_x(inc_x, x, y)
    res = 0
    0.upto(inc_x.abs) do |i|
      if self.phy_tile(x + i * inc_x.sign, y) == :solid
        break
      else
        res = i * inc_x.sign
      end
    end
    res
  end

  def clamp_y(inc_y, x, y)
    res = 0
    0.upto(inc_y.abs) do |i|
      if self.phy_tile(x, y + i * inc_y.sign) == :solid
        break
      else
        res = i * inc_y.sign
      end
    end
    res
  end

  def clamp_inc_x(inc_x)
    spots = self.hotspots
    res = 0
    if inc_x > 0 # moving right
      res = [clamp_x(inc_x, *spots[:right_top]),
             clamp_x(inc_x, *spots[:right]),
             clamp_x(inc_x, *spots[:right_bottom])].min
    elsif inc_x < 0 # moving left
      res = [clamp_x(inc_x, *spots[:left_top]),
             clamp_x(inc_x, *spots[:left]),
             clamp_x(inc_x, *spots[:left_bottom])].max
    end
    res
  end

  def clamp_inc_y(inc_y)
    spots = self.hotspots
    res = 0
    if inc_y > 0 # moving down
      res = [clamp_y(inc_y, *spots[:left_bottom]),
             clamp_y(inc_y, *spots[:bottom]),
             clamp_y(inc_y, *spots[:right_bottom])].min
    elsif inc_y < 0 # moving up
      res = [clamp_y(inc_y, *spots[:left_top]),
             clamp_y(inc_y, *spots[:top]),
             clamp_y(inc_y, *spots[:right_top])].max
    end
    res
  end

  def update_physics
    inc_x = self.clamp_inc_x(@speed_x * $game.delta)
    @x += inc_x
    @speed_x = 0 if inc_x.zero?

    inc_y = self.clamp_inc_y(@speed_y * $game.delta)
    @y += inc_y

    @speed_y = 0 if self.is_on_ground? and @speed_y > 0
    @speed_y = 0 if self.is_under_ground? and @speed_y < 0
  end

  def is_under_ground?
    spots = self.hotspots
    [:left_top, :top, :right_top].each do |name|
      return true if self.phy_tile(spots[name][0], spots[name][1] - 1) == :solid
    end
    false
  end

  def is_on_ground?
    spots = self.hotspots
    [:left_bottom, :bottom, :right_bottom].each do |name|
      return true if self.phy_tile(spots[name][0], spots[name][1] + 1) == :solid
    end
    false
  end

  protected

  def phy_tile(x, y)
    col, row = @map.screen_to_map(x, y)
    @map.phy_tile(col, row)
  end

  def hotspots
    left = @x - @width / 2
    right = @x + (@width / 2) - 1
    top = @y - @height / 2
    bottom = @y + (@height / 2) - 1

    {
      :left_top => [left, top],
      :top => [@x, top],
      :right_top => [right, top],
      :right => [right, @y],
      :right_bottom => [right, bottom],
      :bottom => [@x, bottom],
      :left_bottom => [left, bottom],
      :left => [left, @y]
    }
  end
end

class Hero
  include Entity
  MAX_SPEED_X = 300
  MAX_SPEED_Y = 600

  def initialize(map)
    @image = $game.images[:hero]
    @map = map
    @width = @image.width
    @height = @image.height

    @x = 48
    @y = 96
    @speed_x = 0
    @speed_y = 0
    @accel_x = 0
    @accel_y = 0
  end

  def draw
    @image.draw_rot @x, @y, 1, 0
  end

  def jump
    @speed_y = -MAX_SPEED_Y
  end

  def update
    self.update_horizontal_speed
    self.update_vertical_speed

    self.update_physics
  end

  protected

  def update_vertical_speed
    # gravity
    @accel_y = 900

    @speed_y += @accel_y * $game.delta
    @speed_y = [@speed_y, MAX_SPEED_Y].min if @speed_y > 0
    @speed_y = [@speed_y, -MAX_SPEED_Y].max if @speed_y < 0
  end

  def update_horizontal_speed
    if $game.button_down?(Gosu::KbRight)
      @accel_x = 300
    elsif $game.button_down?(Gosu::KbLeft)
      @accel_x = -300
    else
      @accel_x = 0
    end

    if @accel_x.abs > 0
      @speed_x += @accel_x
    else
      if @speed_x > 0
        @speed_x = [@speed_x - 900 * $game.delta, 0].max
      elsif @speed_x < 0
        @speed_x = [@speed_x + 900 * $game.delta, 0].min
      end
    end

    @speed_x = [@speed_x, MAX_SPEED_X].min if @speed_x > 0
    @speed_x = [@speed_x, -MAX_SPEED_X].max if @speed_x < 0
  end
end
