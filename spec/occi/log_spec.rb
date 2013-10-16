module Occi
  describe Log do

    context 'logging to files' do
      testIO = StringIO.new
      logger = Occi::Log.new(testIO)
      Occi::Log.info("Test Info Text")
      Occi::Log.warn("Test Warning Text")
      Occi::Log.error("Test Error Text")
      Occi::Log.fatal("Test Fatal Text")
      logger.level=Occi::Log::ERROR
      Occi::Log.info("Second Info Text")
      Occi::Log.warn("Second Warning Text")
      Occi::Log.error("Second Error Text")
      Occi::Log.fatal("Second Fatal Text")
      logger.close

      it 'logs correctly with prioritiy INFO' do
        expect(testIO.string).to match (/I.*INFO.*Test Info Text/)
      end

      it 'logs correctly with prioritiy WARN' do
        expect(testIO.string).to match (/W.*WARN.*Test Warning Text/)
      end

      it 'logs correctly with prioritiy ERROR' do
        expect(testIO.string).to match (/E.*ERROR.*Test Error Text/)
      end

      it 'logs correctly with prioritiy FATAL' do
        expect(testIO.string).to match (/F.*FATAL.*Test Fatal Text/)
      end

      it 'does not log prioritiy INFO with log level set to ERROR' do
        expect(testIO.string).to_not match (/I.*INFO.*Second Info Text/)
      end

      it 'does not log prioritiy WARN with log level set to ERROR' do
        expect(testIO.string).to_not match (/W.*WARN.*Second Warning Text/)
      end

      it 'still logs with prioritiy ERROR' do
        expect(testIO.string).to match (/E.*ERROR.*Second Error Text/)
      end

      it 'still logs with prioritiy FATAL' do
        expect(testIO.string).to match (/F.*FATAL.*Second Fatal Text/)
      end

      it 'tells log lines apart correctly' do #This tests the correctness of the testing procedure rather than the code itself
        expect(testIO.string).to_not match (/E.*ERROR.*Test Fatal Text/)
      end

    end

    it 'copes with read-only log file' do
      (contents = "locked file contents").freeze
      testIO = StringIO.open(contents)
      logger = Occi::Log.new(testIO)
      expect(Occi::Log.fatal("New content")).to eq nil
      logger.close
    end

    context 'logging to a pipe' #do
#			def log_and_test(priority)
#        r, w = IO.pipe
#        logger = Occi::Log.new(w)
#        logger.level = priority
#        Occi::Log.info("Test")
#        line=r.readline
#        expect(line).to include("Test")
#        logger.close
#			end

#      it 'logs with priority INFO' #do
#				log_and_test(Occi::Log::INFO)
#      end

#      it 'logs with priority WARN'# do
#				log_and_test(Occi::Log::WARN)
#      end

#      it 'logs with priority ERROR'
#      it 'logs with priority FATAL'

#    end

  end
end
