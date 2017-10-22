# http://www.codewars.com/kata/the-position-of-a-digital-string-in-a-infinite-digital-string/train/ruby
#
def find_position(str)
  digits = str.chars.map(&:to_i)

  # Digits are increasing
  # if digits.each_cons(2).all? { |a, b| b == a + 1 }
  if digits.each_cons(2).all? { |a, b| (a + 1).to_s.start_with?(b.to_s) }
    puts "Simple increasing sequence of digits"
    return position(digits.first)
  end

  # Special case, starting with zero
  # if str =~ /^0/
  #     return -2
  # end

  (2..str.size).each do |chunk_size|
    # Chunk left to right
    res = chunk_ltr(str, chunk_size)
    return res if res

    # Chunk right to left
    res = chunk_rtl(str, chunk_size)
    return res if res
  end

  puts "--- FALLBACK ---"
  position(str.to_i)
end

def chunk_ltr(str, n)
  sslice = str[0, n]
  if sslice.start_with?("0")
    (1..9).each do |prefix|
      puts "Starts with 0, prepending #{prefix}"
      ssslice = "#{prefix}#{sslice}"
      if try_chunk(str, ssslice, true)
        puts "Found by chunking left to right in groups of #{n}"
        return position(ssslice.to_i, 1)
      end
    end
  elsif try_chunk(str, sslice)
    puts "Found by chunking left to right in groups of #{n}"
    return position(sslice.to_i)
  end

  false
end

def try_chunk(str, sslice, prefixed = false)
  slice = sslice.to_i
  newstr = [slice, slice + 1].join
  puts "...#{newstr}..."

  prefixed ? newstr[1..-1].start_with?(str) : newstr.start_with?(str)
end

def chunk_rtl(str, n)
  slice = str[-n, n].to_i
  newstr = [slice - 1, slice].join
  puts "RTL(#{n}): #{newstr}"
  if newstr.end_with?(str)
    puts "Found by chunking right to left in groups of #{n}"
    puts "...#{newstr}..."
    return position(slice - 1, newstr.index(str))
  end
  false
end

def position(n, offset=0)
  puts "position(#{n}, #{offset})"
  len(1..n) + offset
end

def len(range)
  # puts "len(#{range.inspect})"
  return range.size - 1 if range.end <= 9

  x = 10 ** Math.log10(range.end).floor
  range_1 = (range.begin..x-1)
  range_2 = (x..range.end)
  # s = (range_2.size * range_2.begin.to_s.length)
  # puts " --> #{range_2.inspect} = #{s}"
  len(range_1) + (range_2.size * range_2.begin.to_s.length) - 1
end

inputs_meta = {
  "456" => [4, 0],
  "454" => [45, 0],
  "455" => [54, 1],
  "910" => [9, 0],
  "9100" => [99, 1],
  "99100" => [99, 0],
  "00101" => [100, 1],
  "001" => [100, 1],
  "00" => [100, 1],
  "123456789" => [1, 0],
  "1234567891" => [1, 0],
  "123456798" => [123456798, 0],
  "10" => [10, 0],
  "53635" => [3536, 1],
  "040" => [400, 2],
  "11" => [11, 0],
  "99" => [89, 1],
  "667" => [66, 1],
  "0404" => [4040, 1],
  "58257860625" => [2578606259, -2]
}

inputs = {
  "456" => 3,
  "454" => 79,
  "455" => 98,
  "910" => 8,
  "9100" => 188,
  "99100" => 187,
  "00101" => 190,
  "001" => 190,
  "00" => 190,
  "123456789" => 0,
  "1234567891" => 0,
  "123456798" => 1000000071,
  "10" => 9,
  "53635" => 13034,
  "040" => 1091, # 400, offset 2
  "11" => 11,
  "99" => 168,
  "667" => 122,
  "0404" => 15050,
  "58257860625" => 24674951477 # 2582578606, offset by 1
}
tricky_inputs = {
  "00" => 190,
  "53635" => 13034,
  "040" => 1091,
  "99" => 168,
  "58257860625" => 24674951477
}

output = {}
tricky_inputs.each do |input, expected|
  puts "Searching for \"#{input}\""
  result = find_position(input)
  output[input] = [result, expected]
  puts result.inspect
  puts "------------"
  puts
end

passed, failed = output.partition { |_, (actual, expected)| actual == expected }
puts
passed.each do |input, (actual, _)|
  puts "[PASS] #{input} => #{actual}"
end
puts
failed.each do |input, (actual, expected)|
  pos, offset = inputs_meta[input]
  puts "[FAIL] #{input} => #{actual}, expected #{expected} (target number #{pos} offset by #{offset})"
end
