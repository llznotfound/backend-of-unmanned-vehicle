class FogController < ApplicationController

  def update
    head :ok

    id = params[:id] || 0
    FogComputingNode.update id
  end

  def alives
    nodes = FogComputingNode.all_alive
    render json: {data: nodes}
  end
end
