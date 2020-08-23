# frozen_string_literal: true

# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class TopbarChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'topbar'
    ActionCable.server.broadcast 'topbar', commit: CurrentCommit
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
