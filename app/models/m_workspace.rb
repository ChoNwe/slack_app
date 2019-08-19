#require 'composite_primary_keys'
class MWorkspace < ApplicationRecord
    #validates :workspace_name,  uniqueness: { case_sensitive: false }
    #self.primary_keys = :id, :user_id
end
