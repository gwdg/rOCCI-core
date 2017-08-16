Dir[File.join(File.dirname(__FILE__), 'monkey_island', '*.rb')].each { |file| require file.gsub('.rb', '') }
