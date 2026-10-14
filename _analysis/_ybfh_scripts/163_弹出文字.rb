#==============================================================================
# ■ module RPG
#------------------------------------------------------------------------------
# 　修改内部脚本 SPRITE
#==============================================================================
module RPG
  class Sprite < ::Sprite
    def initialize(viewport = nil)
      super(viewport)
      @_whiten_duration = 0
      @_appear_duration = 0
      @_escape_duration = 0
      @_collapse_duration = 0
      @_damage_duration = 0
  
      @_word_duration = 0
  
      @_animation_duration = 0
      @_blink = false
    end
    def dispose
      dispose_damage
      dispose_animation
      dispose_loop_animation

      dispose_word

      super
    end

    def word(value)
      dispose_word
      bitmap = Bitmap.new(250, 48)
      bitmap.font.name = "黑体"
      bitmap.font.size = 20
      bitmap.font.color.set(0, 0, 0)
      bitmap.draw_text(-1, 12-1, 250, 36, value, 1)
      bitmap.draw_text(+1, 12-1, 250, 36, value, 1)
      bitmap.draw_text(-1, 12+1, 250, 36, value, 1)
      bitmap.draw_text(+1, 12+1, 250, 36, value, 1)
      case $word_color
      when 0 #白色
        bitmap.font.color.set(255, 255, 255)
      when 1 #红色
        bitmap.font.color.set(255, 0, 0)
      when 2 #绿色
        bitmap.font.color.set(0, 255, 0)
      when 3 #蓝色
        bitmap.font.color.set(126, 204, 244)
      when 4 #黄色
        bitmap.font.color.set(255, 255, 0)
      end
      bitmap.draw_text(0, 12, 250, 36, value, 1)
      @_word_sprite = ::Sprite.new(self.viewport)
      @_word_sprite.bitmap = bitmap
      @_word_sprite.ox = 105
      @_word_sprite.oy = 15
      @_word_sprite.x = self.x - self.ox
      @_word_sprite.y = self.y - self.oy
      @_word_sprite.z = 3001
      @_word_duration = 40
    end
    def dispose_word
      if @_word_sprite != nil
        @_word_sprite.bitmap.dispose
        @_word_sprite.dispose
        @_word_sprite = nil
        @_word_duration = 0
      end
    end

    def update
      super
      if @_whiten_duration > 0
        @_whiten_duration -= 1
        self.color.alpha = 128 - (16 - @_whiten_duration) * 10
      end
      if @_appear_duration > 0
        @_appear_duration -= 1
        self.opacity = (16 - @_appear_duration) * 16
      end
      if @_escape_duration > 0
        @_escape_duration -= 1
        self.opacity = 256 - (32 - @_escape_duration) * 10
      end
      if @_collapse_duration > 0
        @_collapse_duration -= 1
        self.opacity = 256 - (48 - @_collapse_duration) * 6
      end
  
      if @_word_duration > 0
        @_word_duration -= 1
        case @_word_duration
        when 38..39
          @_word_sprite.y -= 4
        when 36..37
          @_word_sprite.y -= 3
        when 34..35
          @_word_sprite.y -= 2
        when 28..33
          @_word_sprite.y -= 1
        end
        @_word_sprite.opacity = 256 - (12 - @_word_duration) * 32
        if @_word_duration == 0
          dispose_word
        end
      end
 
      if @_damage_duration > 0
        @_damage_duration -= 1
        case @_damage_duration
        when 38..39
          @_damage_sprite.y -= 4
        when 36..37
          @_damage_sprite.y -= 2
        when 34..35
          @_damage_sprite.y += 2
        when 28..33
          @_damage_sprite.y += 4
        end
        @_damage_sprite.opacity = 256 - (12 - @_damage_duration) * 32
        if @_damage_duration == 0
          dispose_damage
        end
      end
      if @_animation != nil and (Graphics.frame_count % 2 == 0)
        @_animation_duration -= 1
        update_animation
      end
      if @_loop_animation != nil and (Graphics.frame_count % 2 == 0)
        update_loop_animation
        @_loop_animation_index += 1
        @_loop_animation_index %= @_loop_animation.frame_max
      end
      if @_blink
        @_blink_count = (@_blink_count + 1) % 32
        if @_blink_count < 16
          alpha = (16 - @_blink_count) * 6
        else
          alpha = (@_blink_count - 16) * 6
        end
        self.color.set(255, 255, 255, alpha)
      end
      @@_animations.clear
    end
  end
end
