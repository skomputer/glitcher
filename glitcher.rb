class Glitcher
  attr_accessor :old_filename, :string, :animation_num, :animation_delay

  def initialize(filename, header_lines=10)
    @header_lines = header_lines
    @old_filename = filename
    @string = read_old_string
    @animation_num = 10
    @animation_delay = 10
  end

  def new_filename
    parts = old_filename.split(".")
    time = Time.now
    parts.each_with_index.collect do |part, i| 
      i + 2 == parts.count ? part + "_glitched_#{time.to_i}#{time.usec}" : part
    end.join(".")
  end

  def read_old_string
    @old_string ||= File.open(old_filename, "rb").read
  end
  
  def reset_string
    @string = @old_string
  end

  def lines
    @string.split("\n")
  end

  def header
    lines.take(@header_lines).join("\n")
  end

  def body
    lines.drop(@header_lines).join("\n")
  end

  def shuffle_lines(size=5)
    @string = header + lines.each_slice(size).to_a.shuffle.flatten
  end

  def replace_text(old, new, rarity=50)
    old_regexp = Regexp.escape(old)
    @string = string[0, 200] + string[200..-1].gsub(/(#{old_regexp})/) do
      rand(rarity) == 0 ? new : $1
    end    
  end

  def braid_text(old, rarity=50)
    old_regexp = Regexp.escape(old)
    @string = string[0, 200] + string[200..-1].gsub(/(.)(#{old_regexp})(.)/) do 
      rand(rarity) == 0 ? $2+$3+$1 : $1+$2+$3
    end
  end
  
  def write
    path = new_filename
    file = File.open(path, "wb")    
    file.write(@string)
    file.close
    print path + "\n" 
    path
  end

  def run_command(str)
    system(str)
    print str + "\n"
  end
  
  def animate(method_name, *args)
    files = []
    @animation_num.times do
      reset_string
      send(method_name.to_sym, *args)
      files << write
    end
    filename_list = files.join(" ")
    output_path = new_filename.split(".")[0..-2].join(".") + ".gif"
    run_command("convert -delay #{@animation_delay} -loop 0 #{filename_list} #{output_path}")
  end
end