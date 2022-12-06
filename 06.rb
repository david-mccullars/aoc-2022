require_relative './solve'

EXAMPLE = <<-END
mjqjpqmgbljsphdztnvjfqwrcgsmlb
END

def start_of_packet(text, length:)
  (length ... text.size).detect do |i|
    text[i-length ... i].chars.uniq.size == length
  end
end

# 4 times faster but a lot harder to read!
def start_of_packet_fast(text, length:)
  found = 0
  last_seen = {}
  text.chars.each_with_index do |c, i|
    prev_i = last_seen[c]
    if prev_i && i - prev_i <= found
      found = i - prev_i
    else
      found += 1
      return i+1 if found == length
    end
    last_seen[c] = i
  end
end

solve_with_text(EXAMPLE => 7) do |text|
  start_of_packet(text, length: 4)
end

solve_with_text(EXAMPLE => 19) do |text|
  start_of_packet(text, length: 14)
end
