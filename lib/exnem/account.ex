defmodule Exnem.Account do
  alias Exnem.Node

  def find(address) do
    normalized = Exnem.normalize_address(address)

    with {:ok, account_info} <- Node.get("account/#{normalized}") do
      Exnem.DTO.AccountInfo.new(account_info)
    end
  end

  def balance(%Exnem.DTO.AccountInfo{} = account_info, mosaic_id) when is_integer(mosaic_id) do
    with {:ok, account} <- Map.fetch(account_info, :account),
         {:ok, mosaics} <- Map.fetch(account, :mosaics) do
      mosaic = Enum.find(mosaics, nil, &(&1.id == mosaic_id))

      case mosaic do
        nil ->
          0

        mosaic ->
          mosaic.amount
      end
    end
  end
end
