#meta example
#
{
  table: :patients,
  custom_types: [
    {
      name: 'patient_deceased',
      columns: [{}]
    }
  ],
  columns: [
    {name: 'id', type: 'uuid'},
    {name: 'deceased', type: 'patient_deceased'},
    {name: 'bith_date', type: 'time'}
  ],
  embeds: [
    {
      name: 'matrial_status', type: 'codable_concept',
      referenced_by: [{
        table_name: 'patient_matrial_status_codings',
        columns: []
      }]
    }
  ],
  referenced_by: [
    {
      table: 'patient_contacts',
      columns: [
        {name: 'name', type: 'human_name'}
      ]
    }
  ]
}
