# frozen_string_literal: true

module Shakapacker::SriManifestExtensions
  def lookup(name, pack_type = {})
    asset = super

    augment_with_integrity asset, pack_type
  end

  def lookup_pack_with_chunks(name, pack_type = {})
    assets = super

    assets.map do |asset|
      augment_with_integrity asset, pack_type
    end
  end

  def augment_with_integrity(asset, _pack_type = {})
    if asset.respond_to?(:dig) && asset['integrity']
      {src: asset['src'], integrity: asset['integrity']}
    elsif asset.respond_to?(:dig)
      asset['src']
    else
      asset
    end
  end
end

if Shakapacker::Manifest.ancestors.map(&:name).exclude?(Shakapacker::SriManifestExtensions.name)
  Shakapacker::Manifest.prepend(Shakapacker::SriManifestExtensions)
end
