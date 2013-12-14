class Game < Gosu::Window
  def initialize
    super 800, 600, true
    self.caption = 'LD28 by ladybenko'
    @current_scene = Scene.new(self)
  end

  def button_up(key)
    @current_scene.button_up(key)
  end

  def draw
    @current_scene.draw
  end

  def update
    @current_scene.update
  end

  def switch_scene(scene_class)
    @current_scene = scene_class.new(self)
  end
end

class Scene
  def initialize(window)
    @window = window
  end

  def update
  end

  def draw
  end
end
