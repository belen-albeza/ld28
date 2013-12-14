class Game < Gosu::Window
  def initialize
    super 800, 600, false
    self.caption = 'LD28 by ladybenko'
  end

  def button_up(key)
    self.close if key == Gosu::KbEscape
  end
end
