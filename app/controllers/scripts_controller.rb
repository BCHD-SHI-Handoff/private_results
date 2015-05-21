class ScriptsController < ApplicationController
  use_growlyflash
  respond_to :html, :js
  before_action :find_script, only: [:edit, :update, :destroy]
  before_filter :verify_is_admin

  def index
    @scripts = Script.all
  end

  def new
    @script = Script.new(test_id: params['test_id'])
  end

  def create
    @script = Script.new(script_params)

    if @script.save
      flash[:success] = "Successfully added #{@script.description}"
    else
      puts @script.errors.inspect
      render 'new'
    end
  end

  def update
    if @script.update_attributes(script_params)
      flash[:success] = "Successfully updated #{@script.description}"
    else
      render 'edit'
    end
  end

  def destroy
    if !@script.destroy()
      flash[:error] = "Failed to delete #{@script.description}"
    else
      flash[:success] = "Successfully removed #{@script.description}"
    end
  end

  private

  def script_params
    params.require(:script).permit(:test_id, :status_id, :message, :language)
  end

  def find_script
    @script = Script.find(params[:id])
  end
end
