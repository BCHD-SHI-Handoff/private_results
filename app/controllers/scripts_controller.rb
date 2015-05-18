class ScriptsController < ApplicationController
  def index
    @scripts = Script.all
  end
end
