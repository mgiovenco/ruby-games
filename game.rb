require 'rubygems'
require 'gosu'

module ZOrder
  Background, Bird, Pipe, UI = *0..3
end

class Bird
  attr_reader :score, :x, :y, :vel_x, :vel_y

  def initialize(window)
    @image = Gosu::Image.new(window, "media/crappy-flappy-bird.png",false)
    @vel_x = 2.5
    @vel_y = 2.5
    @score = 0
  end

  def starting_position(x, y)
    @x = x 
    @y = y
  end

  def flap
    @y -= 10  
  end

  def gravity_loss
    @y += 3.5
  end

  def forward_movement
    if(@x < 500)
      @x += 0.3
    end
  end

  def pipe_collision(pipes)
    if pipes.reject! {|pipe| Gosu::distance(@x, @y, pipe.x, pipe.y) < 35 } then
      @score += 1
    end
  end

  def draw
    @image.draw_rot(@x, @y, ZOrder::Bird, 0)
  end
end

class Pipe
  attr_reader :score, :x, :y
  
  def initialize(window)
    @x = 1000
    @y = 800
    r = Random.new
    #2 two dots means it includes 1-2, three dots means it excludes 1
    i = r.rand(1..3)
    @image_top = Gosu::Image.new(window, "media/pipe-#{i}-1.png", false)
    @image_bottom = Gosu::Image.new(window, "media/pipe-#{i}-2.png", false)
  end

  def move
    @x -= 5  
  end

  def draw
    @image_top.draw_rot(@x, 800, ZOrder::Pipe, 0)
    @image_bottom.draw_rot(@x, 200, ZOrder::Pipe, 0)
    
  end
end

class GameWindow < Gosu::Window
  def initialize

    window_length = 1000
    window_height = 800
    super(window_length, window_height, false)
    self.caption = "Crappy Bird"
    
    @background_image = Gosu::Image.new(self, "media/happy-bird-background-with-clouds-and-forest.png", true)
    @bird = Bird.new(self)
    @bird.starting_position(0, 200)
    
    @pipe = Pipe.new(self)
    
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @pipes = Array.new
  end

  def update
    if button_down? Gosu::KbSpace or button_down? Gosu::GpButton0 then
      @bird.flap
    end

    @bird.gravity_loss
    @bird.forward_movement

    if rand(150) == 1 then
      @pipes.push(Pipe.new(self))
      
      end
  end

  def draw
    @background_image.draw(0, 0, ZOrder::Background)
    @bird.draw
    @font.draw("Score: #{@bird.score}", 50, 40, ZOrder::UI, 1.0, 1.0, 0xffffff00)
    @font.draw("x: #{@bird.x}", 50, 60, ZOrder::UI, 1.0, 1.0, 0xffffff00)
    @font.draw("y: #{@bird.y}", 50, 80, ZOrder::UI, 1.0, 1.0, 0xffffff00)
    @font.draw("vel_x: #{@bird.vel_x}", 50, 100, ZOrder::UI, 1.0, 1.0, 0xffffff00)
    @font.draw("vel_y: #{@bird.vel_y}", 50, 120, ZOrder::UI, 1.0, 1.0, 0xffffff00)

    @pipes.map do |pipe|
      pipe.draw
      pipe.move
    end
  end

  def button_down(id)
    if id == Gosu::KbEscape then
      close
    end
  end
end

window = GameWindow.new
window.show