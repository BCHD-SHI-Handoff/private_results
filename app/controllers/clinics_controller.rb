class ClinicsController < ApplicationController
  def index
    @clinics = Clinic.all
  end
end
