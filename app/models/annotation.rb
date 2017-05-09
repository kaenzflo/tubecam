class Annotation < ApplicationRecord
  belongs_to :sequence
  belongs_to :user
  belongs_to :annotations_lookup_table
end
