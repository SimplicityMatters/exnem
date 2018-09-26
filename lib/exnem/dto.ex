defmodule Exnem.DTO do
  def parse_transaction(%{"transaction" => %{"type" => type}} = data) do
    case Exnem.transaction_name(type) do
      :modify_multisig -> Exnem.DTO.MultisigModifyTransaction.new(data)
      :aggregate_bonded -> Exnem.DTO.AggregateTransaction.new(data)
      :aggregate_complete -> Exnem.DTO.AggregateTransaction.new(data)
      :register_namespace -> Exnem.DTO.RegisterNamespaceTransaction.new(data)
      :mosaic_supply_change -> Exnem.DTO.MosaicSupplyChangeTransaction.new(data)
      :mosaic_definition -> Exnem.DTO.MosaicDefinitionTransaction.new(data)
      :transfer -> Exnem.DTO.TransferTransaction.new(data)
      :lock -> Exnem.DTO.HashlockTransaction.new(data)
    end
  end
end
