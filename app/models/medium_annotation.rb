class MediumAnnotation < ApplicationRecord
  belongs_to :medium
  belongs_to :user
  belongs_to :annotation_lookup_table
end
