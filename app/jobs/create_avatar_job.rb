# frozen_string_literal: true

class CreateAvatarJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    ActiveStorage::Current.host = build_host_url
    record = User.find(user_id)

    avatar = record.avatar_url
    avatar.variant(resize: '50x50>').processed.url
    avatar.variant(resize: '100x100>').processed.url
    avatar.variant(resize: '200x200>').processed.url
    avatar.variant(resize: '500x500>').processed.url
    avatar.variant(resize: '1000x1000>').processed.url
  end

  def build_host_url
    User.thumbnail_host_url
  end
end
