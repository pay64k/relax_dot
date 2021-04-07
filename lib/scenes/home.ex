defmodule RelaxDot.Scene.Home do
  use Scenic.Scene
  require Logger

  alias Scenic.Graph
  alias Scenic.ViewPort

  import Scenic.Primitives

  @radius 10
  @move_interval 200
  @clear_interval 100
  @divisions 10

  @bg_color :white
  @dot_color :black

  @motions [:left_to_right, :diagonal_1, :left_to_right, :diagonal_2]

  @graph Graph.build(clear_color: @bg_color)
         |> circle(@radius, id: :dot, fill: {:color, @dot_color}, translate: {@radius, @radius})

  def init(_, opts) do
    {:ok, %ViewPort.Status{size: {width, height}}} = ViewPort.info(opts[:viewport])
    step_x = width / @divisions
    step_y = height / @divisions
    [active_motion | rem_motions] = @motions
    tref = Process.send_after(self(), :move, @move_interval)

    {:ok,
     %{
       tref: tref,
       step_x: step_x,
       step_y: step_y,
       width: width,
       height: height,
       x: @radius,
       y: @radius,
       active_motion: active_motion,
       rem_motions: rem_motions
     }, push: @graph}
  end

  # def handle_input(event, _context, state) do
  #   Logger.info("Received event: #{inspect(event)}")
  #   {:noreply, state}
  # end

  def handle_info(:move, state = %{x: x, y: y, step_x: step_x, step_y: step_y}) do
    new_data = {new_x, new_y, next_motion, rem_motions} =
      case state.active_motion do
        :left_to_right ->
          if x + step_x <= state.width do
            {x + step_x, y, state.active_motion, state.rem_motions}
          else
            [n | r] = state.rem_motions
            {state.width - @radius, y, n, r}
          end

        :diagonal_1 ->
          if x - step_x >= 0 and y + step_y <= state.height do
            {x - step_x, y + step_y, state.active_motion, state.rem_motions}
          else
            [n | r] = state.rem_motions
            {@radius, state.height - @radius, n, r}
          end

        :diagonal_2 ->
          if x - step_x >= 0 and y - step_y >= 0 do
            {x - step_x, y - step_y, state.active_motion, state.rem_motions}
          else
            [n | r] = state.rem_motions
            {@radius, @radius, n, r}
          end
      end

      Logger.info("new_data: #{inspect new_data}")

    # {next_motion, rem_motions} =
    #   case {new_x >= state.width, new_y >= state.height} do
    #     {false, false} ->
    #       {state.active_motion, state.rem_motions}
    #     {true, false} ->
    #       [n | r] = state.rem_motions
    #       {n, r}
    #   end

    # {new_x, new_y, next_motion, rem_motions} =
    # if new_x >= state.width or new_y >= state.height do
    #   [n | r] = state.rem_motions
    #   {state.width - @radius, state.height - @radius, n, r}
    # else
    #   {new_x, new_y, state.active_motion, state.rem_motions}
    # end

    graph =
      @graph
      |> Graph.modify(
        :dot,
        &circle(&1, @radius, fill: {:color, @dot_color}, translate: {new_x, new_y})
      )

    {:noreply,
     %{
       state
       | x: new_x,
         y: new_y,
         active_motion: next_motion,
         rem_motions: rem_motions,
         tref: Process.send_after(self(), :clear, @move_interval)
     }, [push: graph]}
  end

  def handle_info(:clear, state) do
    graph =
      @graph
      |> Graph.modify(:dot, &circle(&1, @radius, fill: {:color, @bg_color}))

    {:noreply, %{state | tref: Process.send_after(self(), :move, @clear_interval)}, [push: graph]}
  end
end
