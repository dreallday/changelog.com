defmodule Changelog.EpisodeChannel do
  use Changelog.Web, :model

  schema "episode_channels" do
    field :position, :integer
    field :delete, :boolean, virtual: true

    belongs_to :channel, Changelog.Channel
    belongs_to :episode, Changelog.Episode

    timestamps()
  end

  @required_fields ~w(position)
  @optional_fields ~w(episode_id channel_id delete)

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> mark_for_deletion()
  end

  def by_position do
    from p in __MODULE__, order_by: p.position
  end

  defp mark_for_deletion(changeset) do
    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end
end
