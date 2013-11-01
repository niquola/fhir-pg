
module Gen
  module Db
    def db(version=nil)
      @db ||= doc.xpath('//Profile/structure/element').each_with_object({}) do |el, acc|
        acc[Meta.path(el)] = el
      end
    end

    def doc
      parse_doc(Pth.from_root_path("vendor/profiles-resources.xml"))
    end

    def parse_doc(path)
      raise "No such file #{path}" unless File.exists?(path)
      Nokogiri::XML(open(path).read).tap do |doc|
        doc.remove_namespaces!
      end
    end
    extend self
  end
end
