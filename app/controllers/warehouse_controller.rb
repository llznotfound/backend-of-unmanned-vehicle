class WarehouseController < ApplicationController

  def update
    head :ok

    id = params[:id] || 0
    WarehouseNode.update id
  end

  def alives
    nodes = WarehouseNode.all_alive
    render json: {data: nodes}
  end
end
