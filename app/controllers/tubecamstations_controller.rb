class TubecamstationsController < ApplicationController
  before_action :set_tubecamstation, only: [:show, :edit, :update, :destroy]

  load_and_authorize_resource

  # GET /tubecamstations
  # GET /tubecamstations.json
  def index
    @tubecamstations = Tubecamstation.all
  end

  # GET /tubecamstations/1
  # GET /tubecamstations/1.json
  def show
  end

  # GET /tubecamstations/new
  def new
    @tubecamstation = Tubecamstation.new
  end

  # GET /tubecamstations/1/edit
  def edit
  end

  # POST /tubecamstations
  # POST /tubecamstations.json
  def create
    @tubecamstation = Tubecamstation.new(tubecamstation_params)

    respond_to do |format|
      if @tubecamstation.save
        format.html { redirect_to @tubecamstation, notice: 'Tubecamstation was successfully created.' }
        format.json { render :show, status: :created, location: @tubecamstation }
      else
        format.html { render :new }
        format.json { render json: @tubecamstation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tubecamstations/1
  # PATCH/PUT /tubecamstations/1.json
  def update
    respond_to do |format|
      if @tubecamstation.update(tubecamstation_params)
        format.html { redirect_to @tubecamstation, notice: 'Tubecamstation was successfully updated.' }
        format.json { render :show, status: :ok, location: @tubecamstation }
      else
        format.html { render :edit }
        format.json { render json: @tubecamstation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tubecamstations/1
  # DELETE /tubecamstations/1.json
  def destroy
    @tubecamstation.destroy
    respond_to do |format|
      format.html { redirect_to tubecamstations_url, notice: 'Tubecamstation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tubecamstation
      @tubecamstation = Tubecamstation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tubecamstation_params
      params.require(:tubecamstation).permit(:serialnumber, :status, :user_id, :description, :active)
    end
end
