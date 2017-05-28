module Weighting
  def self.calc_tf(ngram)
    count = Hash.new(0)
    ngram.each do |ary|
      count[ary] += 1
    end
    sum_cnt = count.values.inject { |sum, val| sum + val }
    Hash[count.map { |key, val| [key, val.to_f / sum_cnt] }]
  end

  def self.calc_idf(ngrams, tf)
    count = Hash.new(0)
    transp = Hash.new{ |hash, key| hash[key] = [] }
    docs_size = ngrams.size
    ngrams.each do |ngram|
      ngram.each do |ary|
        next if count[ary] != 0
        tf.each_with_index do |t, n|
          unless t[ary].nil?
            transp[ary] << (n + 1)
            count[ary] += 1
          end
        end
        count[ary] = 1 if count[ary] == 0
      end
    end
    return Hash[count.map { |k, v| [k, Math.log(docs_size / v.to_f) + 1] }], transp
  end
end
