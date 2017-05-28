require './MyFile'
require 'benchmark'

# -F "%f[6]\n" mecabオプション

def split_text(text,char_size)
  array = []
  char_count = Hash.new(0)
  loop_count = text.length - char_size + 1
  loop_count.times do |n|
    s = text[n, char_size]
    array << s if char_count[s] == 0
    char_count[s] += 1
  end

  sum_cnt = char_count.values.inject { |sum, val| sum + val }
  char_count = Hash[char_count.map { |key, val| [key, val.to_f / sum_cnt]}]
  return array.sort, Hash[char_count.sort_by{ |k, v| k }]
end

def calc_idf(ngrams, tf)
  count = Hash.new(0)
  transp = Hash.new{ |hash, key| hash[key] = [] }
  docs_size = ngrams.size
  ngrams.each do |ngram|
    ngram.each do |elm|
      next if count[elm] != 0
        tf.each_with_index do |t, n|
        unless t[elm].nil?
          transp[elm] << (n + 1)
          count[elm] += 1
        end
      end
      count[elm] = 1 if count[elm] == 0
    end
  end
  return Hash[count.map { |k, v| [k, Math.log(docs_size / v.to_f) + 1] }], transp
end

docs = MyFile::file_load()
ngrams = []
tf = Array.new(docs.size){{}}

split_time = Benchmark.realtime do
  (docs.size).times do |n|
    ngrams[n], tf[n] = split_text(docs[n], ARGV[0].to_i) # N分割
  end
end
puts "split_time: #{split_time}"

idf = {}
transp = {}
idf_time = Benchmark.realtime do
  idf, transp = calc_idf(ngrams, tf)
end
puts "idf_time: #{idf_time}"

(docs.size).times do |n|
  file_name = ''
  if docs.size == n + 1
    file_name = "#{n + 1}.txt"
  else
    file_name = ('0' * ((docs.size).to_s.length - (n + 1).to_s.length)) + "#{n + 1}.txt" #ファイル名
  end
  File.open("result-character/#{file_name}", 'w') do |file|
    ngrams[n].each do |key|
      tfidf = tf[n][key] * idf[key]
      file.puts("#{key}\t #{tfidf}")
    end
  end
end

loop do
  print "\n"
  puts "検索したい文字列を入力してください。"
  key = STDIN.gets.chomp
  puts "#{key}:\t #{transp[key]}"
end
