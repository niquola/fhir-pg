
module Gen
  module Db
    def db(version=nil)
      build_type(elements, 'Patient')
    end

    def elements
      @elements ||= elements_doc.xpath('//Profile/structure/element').each_with_object({}) do |el, acc|
        acc[Meta.path(el)] = el
      end
    end

    def resources
      @resources ||= elements_doc.xpath('//Profile/structure')
      .each_with_object({}) do |el, acc|
        type = el.xpath('./type').first[:value]
        acc[type] = el
      end
    end

    def datatypes
      @datatypes ||= {}.tap do |res|
        datatypes_doc.xpath('//simpleType').each do |el|
          res[el[:name]] = el
        end

        datatypes_doc.xpath('//complexType').each do |el|
          res[el[:name]]= el
        end
      end
    end

    def datatypes_doc
      @datatypes_doc ||= parse_doc(Pth.from_root_path("vendor/fhir-base.xsd"))
    end

    def elements_doc
      @elements_doc ||= parse_doc(Pth.from_root_path("vendor/profiles-resources.xml"))
    end

    def build_type(db, path)
      type = {
        path: path,
        attributes: [],
        types: []
      }

      db.each do |p, el|
        next unless direct_parent?(path, p, el)
        puts p
        p Meta.attr(el, 'min')
        p Meta.attr(el, 'max')
      end
    end

    def direct_parent?(path, p, el)
      if p.start_with?(path) && p !~ /extension$/
        (p.split('.') - path.split('.')).size == 1
      end
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
