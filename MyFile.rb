module MyFile
  def self.file_load()
    dirs = Dir.glob("../data/**")
    docs = [] # 文書の内容をStringで保存するもの
    dirs.each do |file_name|
      str = ""
      File.open(file_name) do |file|
        file.each_line do |text|
          str << text.chomp
        end
      end
      docs << str
    end
    docs
  end
end
