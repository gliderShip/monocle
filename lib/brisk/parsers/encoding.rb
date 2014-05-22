module Brisk
  module Parsers
    module Encoding extend self

      def encode(str)

        if str
          if str.encoding.to_s.downcase == 'iso-8859-1'
            ec    = ::Encoding::Converter.new("iso-8859-1", "utf-8")
            str  = ec.convert(str);
          elsif str.encoding.to_s.downcase == 'windows-1252'
            ec    = ::Encoding::Converter.new("windows-1252", "utf-8")
            str  = ec.convert(str);
          elsif str.encoding.to_s.downcase == "ascii-8bit"
            # rilindjademokratike
            #ec    = ::Encoding::Converter.new("ascii-8bit", "utf-8")
            #str  = ec.convert(str);
            # ec = ::Encoding::Converter.new("ascii-8bit", "utf-8", :undef => :replace)
            # ec = ::Encoding::Converter.new("ascii-8bit", "utf-8", :undef => :replace)
            # ec.replacement = "ë"
          end
        end

        return str
        # str.gsub!("ë", "e")
        # str.gsub!("Ë", "E")
        # str.gsub!("ç", "c")
        # str.gsub!("Ç", "C")
      end
    end
  end
end
