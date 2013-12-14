class Game < Gosu::Window
  attr_reader :delta, :images

  def initialize
    super 800, 600, false
    self.caption = 'LD28 by ladybenko'

    @current_scene = Scene.new
    @old_timestamp = 0

    load_images
  end

  def button_up(key)
    @current_scene.button_up(key)
  end

  def draw
    @current_scene.draw
  end

  def update
    self.update_delta
    @current_scene.update
  end

  def switch_scene(scene_class)
    @current_scene = scene_class.new
  end

  protected

  def load_images
    @images = {
      :grass => Gosu::Image.new(self, 'gfx/tiles/grass.png', true),
      :hero => Gosu::Image.new(self, 'gfx/chara.png')
    }
  end

  def update_delta
    now = Gosu::milliseconds
    @delta = [(now - @old_timestamp) / 1000.0, 0.25].min
    @old_timestamp = now
  end
end

class Scene
  def update
  end

  def draw
  end

  def button_up(key)
  end
end
