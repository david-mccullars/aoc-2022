require 'matrix'

module ImageHelper

  module Colors
    TERRAIN = %w[
      16 67 16
      16 80 16
      17 94 17
      18 108 18
      19 121 19
      20 135 20
      21 149 21
      22 163 22
      23 176 23
      24 190 24
      25 204 25
      26 218 26
      26 218 26
      60 177 48
      95 136 70
      130 94 92
      130 94 92
      148 119 92
      166 145 92
      166 145 92
      196 165 117
      227 186 143
      227 186 143
      235 211 185
      244 237 228
      244 237 228
    ].each_slice(3).map do |values|
      Vector[*values.map(&:to_i), 255].freeze
    end.freeze

    PATH_START = Vector[0, 0, 0, 120].freeze
    PATH_END = Vector[0, 0, 0, 240].freeze
  end

  def grid_to_pixels(grid)
    rows = grid.keys.count { |y, x| x == 0 }
    cols = grid.keys.count { |y, x| y == 0 }

    pixels = Array.new(rows) { Array.new(cols) }
    grid.each do |(y, x), value|
      pixels[y][x] = value
    end
    pixels
  end

  def path_to_pixels(path, start_color = Colors::PATH_START, end_color = Colors::PATH_END)
    rows = path.map(&:first).max + 1
    cols = path.map(&:last).max + 1
    colors = gradient(start_color, end_color, steps: path.size).to_a

    pixels = Array.new(rows) { Array.new(cols) }
    path.zip(colors) do |(y, x), color|
      pixels[y][x] = color
    end
    pixels
  end

  def render_image(pixels, file:, background: :transparent)
    require 'chunky_png'
    case background
    when Symbol, String
     background = ChunkyPNG::Color.const_get(background.to_s.upcase)
    end

    png = ChunkyPNG::Image.new(pixels.first.size, pixels.size, background)
    pixels.each_with_index do |pixels_row, y|
      pixels_row.each_with_index do |color, x|
        png[x, y] = ChunkyPNG::Color.rgba(*color) if color
      end
    end
    png.save(file, interlace: true)
  end

  def expand_image(pixels, factor: nil, x_factor: nil, y_factor: nil)
    pixels = expand_1d(pixels, factor: x_factor || factor)
    expand_1d(pixels.transpose, factor: y_factor || factor).transpose
  end

  def overlay_images(*images)
    rows = images.first.size
    cols = images.first.first.size
    Parallel.map(rows.times) do |row|
      cols.times.map do |col|
        overlay_pixel(*images.map { |pixels| pixels[row][col] if pixels[row] }.compact)
      end
    end
  end

  private

  def expand_1d(pixels, factor: nil)
    return pixels if factor == 1
    raise ArgumentError, "Invalid expansion factor: #{factor.inspect}" if factor.nil? || factor % 2 == 0

    offset = factor / 2

    Parallel.map(pixels) do |row|
      expanded_row = row.first(1) * (offset + 1) \
                   + Array.new((row.size - 1) * factor) \
                   + row.last(1) * offset
      i = offset
      row.each_cons(2).each do |p1, p2|
        gradient(p1, p2, steps: factor).each do |p|
          expanded_row[i += 1] = p
        end
      end
      expanded_row
    end
  end

  def gradient(p1, p2, steps:)
    Enumerator.new do |e|
      1.upto(steps) do |step|
        if p1 == p2
          e << p1
        elsif step == steps
          e << p2
        elsif p1.nil?
          e << (step >= steps / 2 ? p2 : nil)
        elsif p2.nil?
          e << (step <= steps / 2 ? p1 : nil)
        else
          #pp1 = p1 || Vector[*p2.first(3), p2.to_a.last / 2]
          #pp2 = p2 || Vector[*p1.first(3), p1.to_a.last / 2]
          e << ((steps - step) * p1 + step * p2) / steps
        end
      end
    end
  end

  def overlay_pixel(*pixels)
    return pixels.last if pixels.size <= 1 || pixels.last[3] == 255

    r, g, b = 0.0, 0.0, 0.0
    opacity_remaining = 1.0
    pixels.reverse.each do |pixel|
      break if opacity_remaining <= 0.0
      r2, g2, b2, a2 = pixel.first(4)
      next unless a2

      opacity = a2 / 255.0 * opacity_remaining
      r += r2 * opacity
      g += g2 * opacity
      b += b2 * opacity
      opacity_remaining -= opacity
    end
    Vector[r.to_i, g.to_i, b.to_i, ((1.0 - opacity_remaining) * 255).to_i]
  end

end
