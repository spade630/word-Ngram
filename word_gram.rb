#!/usr/bin/ruby
# -*- coding: utf-8 -*-

# 1万データ 870s
require 'MeCab'
require './Weighting'
require './MyFile'
require 'benchmark'

def generate_ngram(text, n)
  array = []
  tmp = []
  text.each_line do |line|
    line.chomp!
    next if line == 'EOS' || line == ''
    tmp << line
  end
  array = tmp.each_cons(n).to_a.sort
end

def generate_vec(b_tf, t_tf)
  d = []
  b_tf.each_with_index do |(key, val), i|
    if t_tf[key].nil?
      d[i] = 0
    else
      d[i] = val
    end
  end
  d
end

def calc_sim(vec1, vec2)
  dot = 0.0
  abs1, abs2 = 0.0, 0.0
  vec1.zip(vec2).each do |d1, d2|
    dot += d1 * d2
    abs1 += d1 * d1
    abs2 += d2 * d2
  end
  dot / (Math.sqrt(abs1) * Math.sqrt(abs2))
end

begin
  model = MeCab::Model.new(ARGV.join(" "))
  tagger = model.createTagger()

  docs = MyFile::file_load
  ngrams = []
  tf = Array.new(docs.size){{}}

  split_and_tf_time = Benchmark.realtime do
    (docs.size).times do |n|
      ngrams << generate_ngram(tagger.parse(docs[n]), ARGV[0].to_i)
    end
    (tf.size).times do |n|
      tf[n] = Weighting::calc_tf(ngrams[n])
    end
  end
  puts "split_and_tf_time: #{split_and_tf_time}"

  idf = {}
  transp = {}
  idf_time = Benchmark.realtime do
    idf, transp = Weighting::calc_idf(ngrams, tf) # 転置インデックスも作る
  end
  puts "idf_time: #{idf_time}"

  tfidf = Array.new(docs.size){{}}

  (docs.size).times do |n|
    file_name = ''
    if docs.size == n + 1
      file_name = "#{n + 1}.txt"
    else
      file_name = ('0' * ((docs.size).to_s.length - (n + 1).to_s.length)) + "#{n + 1}.txt" #ファイル名
    end
    File.open("result-word/#{file_name}", 'w') do |file|
      tf[n].each do |key, val|
        tfidf[n][key] = val * idf[key]
        key.each_with_index do |k ,i|
          file.print(' - ') if i != 0
          file.print(k)
        end
        file.puts("\t #{tfidf[n][key]}")
      end
    end
  end

  if ARGV[0].to_i == 1 # 単語Ngramの時のみ
    loop do
      print "\n"
      puts "入力した単語がある文書を探します"
      target = STDIN.gets.chomp
      ary = Array.new
      ary[0] = target
      puts "#{target}:\t #{transp[ary]}"
      print "\n"
      unless transp[ary].empty?
        b_tfidf = {}
        transp[ary].each do |n|
          b_tfidf[n] = tfidf[n - 1][ary]
        end
        base = Hash[b_tfidf.sort_by { |k, v| -v }].keys[0] #tf*idfが一番大きい文書のindexをとる
        sim = {}
        vec1 = Array.new
        vec2 = {}
        transp[ary].each do |n|
          if n == base
            vec1 = generate_vec(tfidf[base - 1], tfidf[base - 1])
          else
            vec2[n] = generate_vec(tfidf[base - 1], tfidf[n - 1])
          end
        end
        vec2.each do |key, vec|
          sim[key] = calc_sim(vec1, vec)
        end
        sim = Hash[sim.sort_by { |k, v| -v }]
        puts "類似度による並び替え"
        puts "基底文書: #{base}"
        sim.each do |key, val|
          puts "文書No.#{key}, 類似度: #{val}"
        end
      else
        puts "入力した単語を含む文書はありませんでした"
      end
    end
  end
rescue
  print "RuntimeError: ", $!, "\n";
end
