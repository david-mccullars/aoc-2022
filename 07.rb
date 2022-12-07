require_relative './solve'

EXAMPLE = <<-END
$ cd /
$ ls
dir a
14848514 b.txt
8504156 c.dat
dir d
$ cd a
$ ls
dir e
29116 f
2557 g
62596 h.lst
$ cd e
$ ls
584 i
$ cd ..
$ cd ..
$ cd d
$ ls
4060174 j
8033020 d.log
5626152 d.ext
7214296 k
END

class DeviceCleaner

  def initialize(lines)
    cwd = [""]
    @dir_sizes = Hash.new(0)
    lines.each do |line|
      case line
      when "$ cd .."
        cwd.pop
      when /^\$ cd (.+)/
        cwd << File.join(cwd.last, $1)
      when /^(\d+)/
        cwd.each do |dir|
          @dir_sizes[dir] += $1.to_i
        end
      end
    end
  end

  def small_directories
    @dir_sizes.values.select do |size|
      size <= 100000
    end.sum
  end

  def best_directory_to_delete
    needed = @dir_sizes.fetch("/") - 40_000_000
    @dir_sizes.values.select do |size|
      size >= needed
    end.min
  end

end

solve_with(DeviceCleaner, EXAMPLE => 95437) do |cleaner|
  cleaner.small_directories
end

solve_with(DeviceCleaner, EXAMPLE => 24933642) do |cleaner|
  cleaner.best_directory_to_delete
end
