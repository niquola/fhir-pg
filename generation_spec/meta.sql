---
:table: patients
:columns:
  :text:
    :name: text
    :path: patient.text
    :kind: :complex_type
    :type: narrative
    :columns:
      :status:
        :name: status
        :path: patient.text.status
        :type: narrative_status
        :kind: :enum
        :requied: true
        :collection: false
      ! ':':
        :name: ''
        :path: patient.text.
        :type: ''
        :kind: :complex_type
        :requied: true
        :collection: false
  :gender:
    :name: gender
    :path: patient.gender
    :kind: :complex_type
    :type: codeable_concept
    :columns:
      :text:
        :name: text
        :path: patient.gender.text
        :type: string
        :kind: :primitive
        :requied: false
        :collection: false
    :referenced_by:
      :coding:
        :name: coding
        :path: patient.gender.coding
        :type: coding
        :kind: :complex_type
        :requied: false
        :collection: true
  :birth_date:
    :name: birth_date
    :path: patient.birth_date
    :kind: :primitive
    :type: date_time
  :deceased:
    :name: deceased
    :path: patient.deceased[x]
    :kind: :polimorphic
    :type:
    - boolean
    - date_time
  :marital_status:
    :name: marital_status
    :path: patient.marital_status
    :kind: :complex_type
    :type: codeable_concept
    :columns:
      :text:
        :name: text
        :path: patient.marital_status.text
        :type: string
        :kind: :primitive
        :requied: false
        :collection: false
    :referenced_by:
      :coding:
        :name: coding
        :path: patient.marital_status.coding
        :type: coding
        :kind: :complex_type
        :requied: false
        :collection: true
  :multiple_birth:
    :name: multiple_birth
    :path: patient.multiple_birth[x]
    :kind: :polimorphic
    :type:
    - boolean
    - integer
  :animal:
    :name: animal
    :path: patient.animal
    :kind: :nested_type
    :table: patient_animals
    :columns:
      :species:
        :name: species
        :path: patient.animal.species
        :kind: :complex_type
        :required: true
        :type: codeable_concept
        :columns:
          :text:
            :name: text
            :path: patient.animal.species.text
            :type: string
            :kind: :primitive
            :requied: false
            :collection: false
        :referenced_by:
          :coding:
            :name: coding
            :path: patient.animal.species.coding
            :type: coding
            :kind: :complex_type
            :requied: false
            :collection: true
      :breed:
        :name: breed
        :path: patient.animal.breed
        :kind: :complex_type
        :type: codeable_concept
        :columns:
          :text:
            :name: text
            :path: patient.animal.breed.text
            :type: string
            :kind: :primitive
            :requied: false
            :collection: false
        :referenced_by:
          :coding:
            :name: coding
            :path: patient.animal.breed.coding
            :type: coding
            :kind: :complex_type
            :requied: false
            :collection: true
      :gender_status:
        :name: gender_status
        :path: patient.animal.gender_status
        :kind: :complex_type
        :type: codeable_concept
        :columns:
          :text:
            :name: text
            :path: patient.animal.gender_status.text
            :type: string
            :kind: :primitive
            :requied: false
            :collection: false
        :referenced_by:
          :coding:
            :name: coding
            :path: patient.animal.gender_status.coding
            :type: coding
            :kind: :complex_type
            :requied: false
            :collection: true
    :referenced_by: {}
  :active:
    :name: active
    :path: patient.active
    :kind: :primitive
    :type: boolean
:referenced_by:
  :identifier:
    :name: identifier
    :path: patient.identifier
    :kind: :complex_type
    :collection: true
    :type: identifier
    :columns:
      :use:
        :name: use
        :path: patient.identifier.use
        :type: identifier_use
        :kind: :enum
        :requied: false
        :collection: false
      :label:
        :name: label
        :path: patient.identifier.label
        :type: string
        :kind: :primitive
        :requied: false
        :collection: false
      :system:
        :name: system
        :path: patient.identifier.system
        :type: uri
        :kind: :primitive
        :requied: false
        :collection: false
      :value:
        :name: value
        :path: patient.identifier.value
        :type: string
        :kind: :primitive
        :requied: false
        :collection: false
      :period:
        :name: period
        :path: patient.identifier.period
        :type: period
        :kind: :complex_type
        :requied: false
        :collection: false
        :columns:
          :start:
            :name: start
            :path: patient.identifier.period.start
            :type: date_time
            :kind: :primitive
            :requied: false
            :collection: false
          :end:
            :name: end
            :path: patient.identifier.period.end
            :type: date_time
            :kind: :primitive
            :requied: false
            :collection: false
      :assigner:
        :name: assigner
        :path: patient.identifier.assigner
        :type: resource_reference
        :kind: :complex_type
        :requied: false
        :collection: false
        :columns:
          :reference:
            :name: reference
            :path: patient.identifier.assigner.reference
            :type: string
            :kind: :primitive
            :requied: false
            :collection: false
          :display:
            :name: display
            :path: patient.identifier.assigner.display
            :type: string
            :kind: :primitive
            :requied: false
            :collection: false
  :name:
    :name: name
    :path: patient.name
    :kind: :complex_type
    :collection: true
    :type: human_name
    :columns:
      :use:
        :name: use
        :path: patient.name.use
        :type: name_use
        :kind: :enum
        :requied: false
        :collection: false
      :text:
        :name: text
        :path: patient.name.text
        :type: string
        :kind: :primitive
        :requied: false
        :collection: false
      :period:
        :name: period
        :path: patient.name.period
        :type: period
        :kind: :complex_type
        :requied: false
        :collection: false
        :columns:
          :start:
            :name: start
            :path: patient.name.period.start
            :type: date_time
            :kind: :primitive
            :requied: false
            :collection: false
          :end:
            :name: end
            :path: patient.name.period.end
            :type: date_time
            :kind: :primitive
            :requied: false
            :collection: false
    :referenced_by:
      :family:
        :name: family
        :path: patient.name.family
        :type: string
        :kind: :primitive
        :requied: false
        :collection: true
      :given:
        :name: given
        :path: patient.name.given
        :type: string
        :kind: :primitive
        :requied: false
        :collection: true
      :prefix:
        :name: prefix
        :path: patient.name.prefix
        :type: string
        :kind: :primitive
        :requied: false
        :collection: true
      :suffix:
        :name: suffix
        :path: patient.name.suffix
        :type: string
        :kind: :primitive
        :requied: false
        :collection: true
  :telecom:
    :name: telecom
    :path: patient.telecom
    :kind: :complex_type
    :collection: true
    :type: contact
    :columns:
      :system:
        :name: system
        :path: patient.telecom.system
        :type: contact_system
        :kind: :enum
        :requied: false
        :collection: false
      :value:
        :name: value
        :path: patient.telecom.value
        :type: string
        :kind: :primitive
        :requied: false
        :collection: false
      :use:
        :name: use
        :path: patient.telecom.use
        :type: contact_use
        :kind: :enum
        :requied: false
        :collection: false
      :period:
        :name: period
        :path: patient.telecom.period
        :type: period
        :kind: :complex_type
        :requied: false
        :collection: false
        :columns:
          :start:
            :name: start
            :path: patient.telecom.period.start
            :type: date_time
            :kind: :primitive
            :requied: false
            :collection: false
          :end:
            :name: end
            :path: patient.telecom.period.end
            :type: date_time
            :kind: :primitive
            :requied: false
            :collection: false
  :address:
    :name: address
    :path: patient.address
    :kind: :complex_type
    :collection: true
    :type: address
    :columns:
      :use:
        :name: use
        :path: patient.address.use
        :type: address_use
        :kind: :enum
        :requied: false
        :collection: false
      :text:
        :name: text
        :path: patient.address.text
        :type: string
        :kind: :primitive
        :requied: false
        :collection: false
      :city:
        :name: city
        :path: patient.address.city
        :type: string
        :kind: :primitive
        :requied: false
        :collection: false
      :state:
        :name: state
        :path: patient.address.state
        :type: string
        :kind: :primitive
        :requied: false
        :collection: false
      :zip:
        :name: zip
        :path: patient.address.zip
        :type: string
        :kind: :primitive
        :requied: false
        :collection: false
      :country:
        :name: country
        :path: patient.address.country
        :type: string
        :kind: :primitive
        :requied: false
        :collection: false
      :period:
        :name: period
        :path: patient.address.period
        :type: period
        :kind: :complex_type
        :requied: false
        :collection: false
        :columns:
          :start:
            :name: start
            :path: patient.address.period.start
            :type: date_time
            :kind: :primitive
            :requied: false
            :collection: false
          :end:
            :name: end
            :path: patient.address.period.end
            :type: date_time
            :kind: :primitive
            :requied: false
            :collection: false
    :referenced_by:
      :line:
        :name: line
        :path: patient.address.line
        :type: string
        :kind: :primitive
        :requied: false
        :collection: true
  :photo:
    :name: photo
    :path: patient.photo
    :kind: :complex_type
    :collection: true
    :type: attachment
    :columns:
      :content_type:
        :name: content_type
        :path: patient.photo.content_type
        :type: code
        :kind: :primitive
        :requied: true
        :collection: false
      :language:
        :name: language
        :path: patient.photo.language
        :type: code
        :kind: :primitive
        :requied: false
        :collection: false
      :data:
        :name: data
        :path: patient.photo.data
        :type: base64_binary
        :kind: :primitive
        :requied: false
        :collection: false
      :url:
        :name: url
        :path: patient.photo.url
        :type: uri
        :kind: :primitive
        :requied: false
        :collection: false
      :size:
        :name: size
        :path: patient.photo.size
        :type: integer
        :kind: :primitive
        :requied: false
        :collection: false
      :hash:
        :name: hash
        :path: patient.photo.hash
        :type: base64_binary
        :kind: :primitive
        :requied: false
        :collection: false
      :title:
        :name: title
        :path: patient.photo.title
        :type: string
        :kind: :primitive
        :requied: false
        :collection: false
  :contact:
    :name: contact
    :path: patient.contact
    :kind: :nested_type
    :collection: true
    :table: patient_contacts
    :columns:
      :name:
        :name: name
        :path: patient.contact.name
        :kind: :complex_type
        :type: human_name
        :columns:
          :use:
            :name: use
            :path: patient.contact.name.use
            :type: name_use
            :kind: :enum
            :requied: false
            :collection: false
          :text:
            :name: text
            :path: patient.contact.name.text
            :type: string
            :kind: :primitive
            :requied: false
            :collection: false
          :period:
            :name: period
            :path: patient.contact.name.period
            :type: period
            :kind: :complex_type
            :requied: false
            :collection: false
            :columns:
              :start:
                :name: start
                :path: patient.contact.name.period.start
                :type: date_time
                :kind: :primitive
                :requied: false
                :collection: false
              :end:
                :name: end
                :path: patient.contact.name.period.end
                :type: date_time
                :kind: :primitive
                :requied: false
                :collection: false
        :referenced_by:
          :family:
            :name: family
            :path: patient.contact.name.family
            :type: string
            :kind: :primitive
            :requied: false
            :collection: true
          :given:
            :name: given
            :path: patient.contact.name.given
            :type: string
            :kind: :primitive
            :requied: false
            :collection: true
          :prefix:
            :name: prefix
            :path: patient.contact.name.prefix
            :type: string
            :kind: :primitive
            :requied: false
            :collection: true
          :suffix:
            :name: suffix
            :path: patient.contact.name.suffix
            :type: string
            :kind: :primitive
            :requied: false
            :collection: true
      :address:
        :name: address
        :path: patient.contact.address
        :kind: :complex_type
        :type: address
        :columns:
          :use:
            :name: use
            :path: patient.contact.address.use
            :type: address_use
            :kind: :enum
            :requied: false
            :collection: false
          :text:
            :name: text
            :path: patient.contact.address.text
            :type: string
            :kind: :primitive
            :requied: false
            :collection: false
          :city:
            :name: city
            :path: patient.contact.address.city
            :type: string
            :kind: :primitive
            :requied: false
            :collection: false
          :state:
            :name: state
            :path: patient.contact.address.state
            :type: string
            :kind: :primitive
            :requied: false
            :collection: false
          :zip:
            :name: zip
            :path: patient.contact.address.zip
            :type: string
            :kind: :primitive
            :requied: false
            :collection: false
          :country:
            :name: country
            :path: patient.contact.address.country
            :type: string
            :kind: :primitive
            :requied: false
            :collection: false
          :period:
            :name: period
            :path: patient.contact.address.period
            :type: period
            :kind: :complex_type
            :requied: false
            :collection: false
            :columns:
              :start:
                :name: start
                :path: patient.contact.address.period.start
                :type: date_time
                :kind: :primitive
                :requied: false
                :collection: false
              :end:
                :name: end
                :path: patient.contact.address.period.end
                :type: date_time
                :kind: :primitive
                :requied: false
                :collection: false
        :referenced_by:
          :line:
            :name: line
            :path: patient.contact.address.line
            :type: string
            :kind: :primitive
            :requied: false
            :collection: true
      :gender:
        :name: gender
        :path: patient.contact.gender
        :kind: :complex_type
        :type: codeable_concept
        :columns:
          :text:
            :name: text
            :path: patient.contact.gender.text
            :type: string
            :kind: :primitive
            :requied: false
            :collection: false
        :referenced_by:
          :coding:
            :name: coding
            :path: patient.contact.gender.coding
            :type: coding
            :kind: :complex_type
            :requied: false
            :collection: true
    :referenced_by:
      :relationship:
        :name: relationship
        :path: patient.contact.relationship
        :kind: :complex_type
        :collection: true
        :type: codeable_concept
        :columns:
          :text:
            :name: text
            :path: patient.contact.relationship.text
            :type: string
            :kind: :primitive
            :requied: false
            :collection: false
        :referenced_by:
          :coding:
            :name: coding
            :path: patient.contact.relationship.coding
            :type: coding
            :kind: :complex_type
            :requied: false
            :collection: true
      :telecom:
        :name: telecom
        :path: patient.contact.telecom
        :kind: :complex_type
        :collection: true
        :type: contact
        :columns:
          :system:
            :name: system
            :path: patient.contact.telecom.system
            :type: contact_system
            :kind: :enum
            :requied: false
            :collection: false
          :value:
            :name: value
            :path: patient.contact.telecom.value
            :type: string
            :kind: :primitive
            :requied: false
            :collection: false
          :use:
            :name: use
            :path: patient.contact.telecom.use
            :type: contact_use
            :kind: :enum
            :requied: false
            :collection: false
          :period:
            :name: period
            :path: patient.contact.telecom.period
            :type: period
            :kind: :complex_type
            :requied: false
            :collection: false
            :columns:
              :start:
                :name: start
                :path: patient.contact.telecom.period.start
                :type: date_time
                :kind: :primitive
                :requied: false
                :collection: false
              :end:
                :name: end
                :path: patient.contact.telecom.period.end
                :type: date_time
                :kind: :primitive
                :requied: false
                :collection: false
  :communication:
    :name: communication
    :path: patient.communication
    :kind: :complex_type
    :collection: true
    :type: codeable_concept
    :columns:
      :text:
        :name: text
        :path: patient.communication.text
        :type: string
        :kind: :primitive
        :requied: false
        :collection: false
    :referenced_by:
      :coding:
        :name: coding
        :path: patient.communication.coding
        :type: coding
        :kind: :complex_type
        :requied: false
        :collection: true
  :link:
    :name: link
    :path: patient.link
    :kind: :nested_type
    :collection: true
    :table: patient_links
    :columns:
      :type:
        :name: type
        :path: patient.link.type
        :kind: :primitive
        :required: true
        :type: code
    :referenced_by: {}
