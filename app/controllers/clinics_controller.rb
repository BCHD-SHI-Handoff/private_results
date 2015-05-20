class ClinicsController < ApplicationController
  use_growlyflash
  respond_to :html, :js
  before_action :find_clinic, only: [:edit, :update, :destroy]
  before_filter :verify_is_admin

  def index
    @clinics = Clinic.all
  end

  def new
    @clinic = Clinic.new({
      hours_in_english: "Monday to Friday, 9am to 5pm",
      hours_in_spanish: "Lunes a Viernes, 9am a 5pm"
    })
  end

  def create
    @clinic = Clinic.new(clinic_params)
    @clinic.code.upcase!

    if @clinic.save
      flash[:success] = "Successfully added '#{@clinic.name}'"
    else
      render 'new'
    end
  end

  def update
    if @clinic.update_attributes(clinic_params)
      flash[:success] = "Successfully updated '#{@clinic.name}'"
    else
      render 'edit'
    end
  end

  def destroy
    if !@clinic.destroy()
      flash[:error] = "Failed to delete '#{@clinic.name}'"
    else
      flash[:success] = "'#{@clinic.name}' has been removed"
    end
  end

  private

  def clinic_params
    params.require(:clinic).permit(:name, :code, :hours_in_english, :hours_in_spanish)
  end

  def find_clinic
    @clinic = Clinic.find(params[:id])
  end
end
