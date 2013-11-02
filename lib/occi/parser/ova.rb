module Occi
  module Parser
    module Ova

      # @param [String] string
      # @return [Occi::Collection]
      def self.collection(string)
        Occi::Log.debug 'Parsing ova format'
        tar = Gem::Package::TarReader.new(StringIO.new(string))
        ovf = mf = cert = nil
        files = {}

        tar.each do |entry|
          tempfile = Tempfile.new(entry.full_name)
          tempfile.write(entry.read)
          tempfile.close
          files[entry.full_name] = tempfile.path

          ovf = tempfile.path if entry.full_name.end_with? '.ovf'
          mf = tempfile.path if entry.full_name.end_with? '.mf'
          cert = tempfile.path if entry.full_name.end_with? '.cert'
        end

        Occi::Log.debug "In ova found: #{ovf} #{mf} #{cert}"
        raise Occi::Errors::ParserInputError, 'No ovf file found' unless ovf

        File.read(mf).each_line do |line|
          line = line.scan(/SHA1\(([^\)]*)\)= (.*)/).flatten
          name = line.first
          sha1 = line.last

          Occi::Log.debug "SHA1 hash #{Digest::SHA1.hexdigest(files[name])}"
          raise Occi::Errors::ParserInputError, "SHA1 mismatch for file #{name}" unless Digest::SHA1.hexdigest(File.read(files[name])) == sha1
        end if mf

        Occi::Parser::Ovf.collection(File.read(ovf), files)
      end

    end
  end
end