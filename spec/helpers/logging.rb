# Push all logging to /dev/null during tests
Yell.new do |l|
  l.adapter :file, filename: '/dev/null'
end
